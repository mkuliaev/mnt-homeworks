# NGINX, Lighthouse, Clickhouse и Vector

## Что делает плейбук

на узле lighthouse-01

1. Загружает и устанавливает "epel"
2. Устанавливает NGINX
3. Копирует конфиг для NGINX
4. Загружает и устаналивает "git"
5. Копирует с гита lighthouse
6. Копирует конфиг для lighthouse
   
на узле Clickhouse-01

1. Устанавливает Clickhouse client , server , common
2. Запускает сервер и создает базу данных Clickhouse
   
на узле Vector-01

1. Устанавливает Vector
2.  Подтягивает настройки из vector.toml.j2
3.  Запускает Vector

## Запуск

Для запуска плейбука необходимо создать две машины под упроавлением centos 7+, настоить ssh подключение 
заполнить prod.yml именем машины и ip адресом, затем запустить команду на хосте 
```ansible-playbook site.yml -i ./inventory/prod.yml --diff```