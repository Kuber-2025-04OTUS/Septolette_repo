# Скриншот вывода команд "kubectl get node"
![alt text](images/image.png)

# Создание необходимых namespace
kubectl apply -f argocd-namespace.yaml
kubectl apply -f homework-namespace.yaml
kubectl apply -f homeworkhelm-namespace.yaml

# Установка argocd
helm upgrade --install argocd argo-cd/. -f argo-cd/values-new.yaml -n argocd
![alt text](images/image-1.png)

# Создание AppProject "otus"
kubectl apply -f appproject.yaml

# Создание Application "kubernetes-networks"
kubectl apply -f application1.yaml
![alt text](images/image-2.png)

# Создание Application "kubernetes-templating"
kubectl apply -f application2.yaml
![alt text](images/image-3.png)

# Проверка успешной установки приложений "kubernetes-networks" и "kubernetes-templating" в argocd
kubectl port-forward service/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
В браузере переходим по http://localhost:8080 -> Applications

Видим результат:

kubernetes-networks (примечание: homework-ingress находится в состоянии "Progressing", так как не установлен ingress-controller, способный обработать сущность ingress) 
![alt text](images/image-4.png)

kubernetes-templating
![alt text](images/image-5.png)