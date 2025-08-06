# Создание необходимых namespace
```
kubectl apply -f csi-s3-namespace.yaml
```

# Созданый S3-bucket
![alt text](image.png)

# Созданый ServiceAccount и static access key
![alt text](image-1.png)

# Установка csi-s3
```
helm upgrade --install csi-s3 csi-s3/. -n csi-s3
```
![alt text](image-2.png)

# Проверка secret c ключами для доступа к Object Storage
```
kubectl get secret csi-s3-secret -n csi-s3 -o yaml
```
![alt text](image-3.png)

# Проверка StorageClass
```
kubectl get storageclass csi-s3 -o yaml
```
![alt text](image-4.png)

# Создание PVC
```
kubectl apply -f pvc.yaml
kubectl get pvc -n csi-s3
kubectl get pv | grep csi-s3
```
![alt text](image-5.png)

# Создание Deployment
```
kubectl apply -f deployment.yaml
```
![alt text](image-6.png)

# Проверка файла в S3-bucket
![alt text](image-7.png)
![alt text](image-8.png)