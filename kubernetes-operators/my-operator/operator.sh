#!/bin/bash

FINALIZER_NAME="cleanup.finalizer.otus.homework"
SLEEP_INTERVAL=10

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Функция для создания ресурсов
create_resources() {
  local MYSQL_NAME=$1
  local NAMESPACE=$2
  local SIZE=$3
  local IMAGE=$4
  local ROOT_PASSWORD=$5

# Создание PVC
  if ! kubectl get pvc "$MYSQL_NAME-pvc" -n "$NAMESPACE" &>/dev/null; then
    log "Создаю PVC для MySQL '$MYSQL_NAME'"
    kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: "$MYSQL_NAME-pvc"
  namespace: "$NAMESPACE"
  labels:
    app: "$MYSQL_NAME"
    managed-by: mysql-operator
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: "$SIZE"
EOF
  fi

# Создание Deployment
  if ! kubectl get deployment "$MYSQL_NAME" -n "$NAMESPACE" &>/dev/null; then
    log "Создаю Deployment для MySQL '$MYSQL_NAME'"
    kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "$MYSQL_NAME"
  namespace: "$NAMESPACE"
  labels:
    app: "$MYSQL_NAME"
    managed-by: mysql-operator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: "$MYSQL_NAME"
  template:
    metadata:
      labels:
        app: "$MYSQL_NAME"
    spec:
      containers:
        - name: mysql
          image: "$IMAGE"
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: "$ROOT_PASSWORD"
          volumeMounts:
            - mountPath: /var/lib/mysql
              name: mysql-storage
      volumes:
        - name: mysql-storage
          persistentVolumeClaim:
            claimName: "$MYSQL_NAME-pvc"
EOF
  fi

# Создание Service
  if ! kubectl get svc "$MYSQL_NAME-service" -n "$NAMESPACE" &>/dev/null; then
    log "Создаю Service для MySQL '$MYSQL_NAME'"
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: "$MYSQL_NAME-service"
  namespace: "$NAMESPACE"
  labels:
    app: "$MYSQL_NAME"
    managed-by: mysql-operator
spec:
  selector:
    app: "$MYSQL_NAME"
  ports:
    - protocol: TCP
      port: 3306
      targetPort: 3306
EOF
  fi
}

# Функция для удаления ресурсов
delete_resources() {
  local MYSQL_NAME=$1
  local NAMESPACE=$2

  log "Удаляю Deployment, Service и PVC для MySQL '$MYSQL_NAME'"

  kubectl delete deployment -n "$NAMESPACE" -l app="$MYSQL_NAME",managed-by=mysql-operator --ignore-not-found
  kubectl delete svc -n "$NAMESPACE" -l app="$MYSQL_NAME",managed-by=mysql-operator --ignore-not-found
  kubectl delete pvc -n "$NAMESPACE" -l app="$MYSQL_NAME",managed-by=mysql-operator --ignore-not-found
}

# Основной цикл
while true; do
  CR_LIST=$(kubectl get mysqls.otus.homework --all-namespaces -o=json | jq -c '.items[]')

  if [[ -z "$CR_LIST" ]]; then
    log "Нет объектов MySQL. Ожидаю появления ресурсов..."
    sleep "$SLEEP_INTERVAL"
    continue
  fi

  while IFS= read -r item; do
    MYSQL_NAME=$(echo "$item" | jq -r '.metadata.name')
    NAMESPACE=$(echo "$item" | jq -r '.metadata.namespace')
    DELETION_TIMESTAMP=$(echo "$item" | jq -r '.metadata.deletionTimestamp')
    FINALIZERS=$(echo "$item" | jq -r '.metadata.finalizers[]?' 2>/dev/null)

    CR_JSON=$(kubectl get mysqls.otus.homework "$MYSQL_NAME" -n "$NAMESPACE" -o json)
    SIZE=$(echo "$CR_JSON" | jq -r '.spec.size')
    IMAGE=$(echo "$CR_JSON" | jq -r '.spec.image')
    ROOT_PASSWORD=$(echo "$CR_JSON" | jq -r '.spec.mysqlRootPassword')

    if [[ "$DELETION_TIMESTAMP" == "null" ]]; then
      if ! echo "$FINALIZERS" | grep -q "$FINALIZER_NAME"; then
        log "Добавляю Finalizer для MySQL '$MYSQL_NAME'"
        kubectl patch mysqls.otus.homework "$MYSQL_NAME" -n "$NAMESPACE" --type=json \
          -p "[{\"op\":\"add\",\"path\":\"/metadata/finalizers\",\"value\":[\"$FINALIZER_NAME\"]}]"
      else
        log "Создаю/обновляю ресурсы для MySQL '$MYSQL_NAME'"
        create_resources "$MYSQL_NAME" "$NAMESPACE" "$SIZE" "$IMAGE" "$ROOT_PASSWORD"
      fi
    else
      if echo "$FINALIZERS" | grep -q "$FINALIZER_NAME"; then
        log "Удаление MySQL '$MYSQL_NAME'. Удаляю ресурсы..."
        delete_resources "$MYSQL_NAME" "$NAMESPACE"

        log "Удаляю finalizer для MySQL '$MYSQL_NAME'"
        kubectl patch mysqls.otus.homework "$MYSQL_NAME" -n "$NAMESPACE" --type=json \
          -p "[{\"op\":\"remove\",\"path\":\"/metadata/finalizers/0\"}]"
      fi
    fi

  done <<< "$CR_LIST"

  sleep "$SLEEP_INTERVAL"
done
