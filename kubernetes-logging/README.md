# Скриншот вывода команд "kubectl get node"
![alt text](images/image-1.png)

# Создание необходимых namespace
kubectl apply -f loki-namespace.yaml
kubectl apply -f grafana-namespace.yaml

# Созданный S3-bucket
![alt text](images/image-5.png)

# Установка loki
helm install -i loki loki/. -f loki/values-new.yaml -n loki
![alt text](images/image-4.png)

# Установка promtail
kubectl apply -f promtail.yaml
![alt text](images/image-2.png)

# Установка grafana
kubectl create secret generic grafana-admin-secret \
  --from-literal=admin-user=admin \
  --from-literal=admin-password=admin \
  -n grafana
helm install grafana grafana/. -f grafana/values-new.yaml -n grafana
![alt text](images/image-3.png)

# Проверка успешного отображения логов в grafana
kubectl port-forward svc/grafana 8000:80 -n grafana
В браузере переходим по http://localhost:8000 -> Connections -> Data Sources -> loki -> Explore
Видим результат: ![alt text](images/image.png)
