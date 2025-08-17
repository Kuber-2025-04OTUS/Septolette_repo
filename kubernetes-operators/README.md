# Основное задание
При применении манифестов есть некоторые проблемы:

1. Всё будет работать только при применении cr.yaml в namespace default, так как в коде оператора присутствует это: 
![alt text](images/image.png)
Т.е. оператор всегда проверяет namespace default.

2. PV создаётся со storageClass "standard", а PVC c "hostpath":
![alt text](images/image-1.png)
![alt text](images/image-3.png)
![alt text](images/image-2.png)
Т.е. в PV приходится вручную прописывать необходимый storageClass.

Результаты проверки после создания cr.yaml:
![alt text](images/image-4.png)
![alt text](images/image-5.png)
![alt text](images/image-6.png)
![alt text](images/image-7.png)

Результаты проверки после удаления cr.yaml:
![alt text](images/image-8.png)

# Задание с *
Результаты проверки после создания cr.yaml:
![alt text](images/image-9.png)
![alt text](images/image-10.png)

Результаты проверки после удаления cr.yaml:
![alt text](images/image-11.png)

# Задание с **
Результаты проверки после создания cr.yaml:
![alt text](images/image-12.png)

Результаты проверки после удаления cr.yaml:
![alt text](images/image-13.png)