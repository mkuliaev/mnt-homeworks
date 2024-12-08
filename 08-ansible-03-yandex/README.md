# Домашнее задание к занятию 3 «Использование Ansible» - Mikhail Kuliaev

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.
2. Репозиторий LightHouse находится [по ссылке](https://github.com/VKCOM/lighthouse).

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает LightHouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику LightHouse, установить Nginx или любой другой веб-сервер, настроить его конфиг для открытия LightHouse, запустить веб-сервер.
4. Подготовьте свой inventory-файл `prod.yml`.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---

Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`

  ![Screnshot](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-03-yandex/png/yandex_vm.png)


Подготовка inventory-файла 

 ```YML
---
clickhouse:
  hosts:
    clickhouse-01: 
      ansible_host: 10.129.0.20
      ansible_user: kuliaev
vector:
  hosts:
    vector-01:
      ansible_host: 10.129.0.9
      ansible_user: kuliaev

lighthouse:
  hosts:
    lighthouse:
      ansible_host: 10.129.0.8
      ansible_user: kuliaev

 ```
Дополнение playbook для установки LightHouse

  ```YML
- name: Install and configure Lighthouse
  hosts: lighthouse
  tasks:
    - name: Ensure www-data group exists
      group:
        name: www-data
        state: present
        system: yes
      become: yes

    - name: Ensure www-data user exists
      user:
        name: www-data
        group: www-data
        system: yes
      become: yes

    - name: Download Lighthouse static files
      get_url:
        url: https://github.com/VKCOM/lighthouse/archive/refs/heads/master.zip
        dest: /tmp/lighthouse.zip

    - name: Ensure unzip is installed
      apt:
        name: unzip
        state: present
      become: yes

    - name: Ensure /var/www/lighthouse directory exists
      file:
        path: /var/www/lighthouse
        state: directory
        owner: www-data
        group: www-data
        mode: '0755'
      become: yes

    - name: Unzip Lighthouse static files
      unarchive:
        src: /tmp/lighthouse.zip
        dest: /var/www/lighthouse
        remote_src: yes
      become: yes

    - name: Install Nginx
      apt:
        name: nginx
        state: present
      become: yes

    - name: Проверка существования fastcgi-php.conf
      command: test -f /etc/nginx/snippets/fastcgi-php.conf
      register: fastcgi_check
      ignore_errors: yes
      become: yes

    - name: Configure Nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/conf.d/lighthouse.conf
      become: yes

    - name: Проверка конфигурации Nginx
      command: nginx -t
      register: nginx_test
      ignore_errors: yes
      become: yes
      when: fastcgi_check.rc == 0

    - name: Перезагрузить Nginx, если конфигурация верна
      service:
        name: nginx
        state: reloaded
      when: nginx_test is defined and nginx_test.rc == 0
      become: yes

    - name: Start Nginx service
      service:
        name: nginx
        state: started
        enabled: yes
      become: yes



```

Создаём шаблон конфигурации Nginx



  ```Bash

server {
    listen 80;
    server_name 51.250.97.96;

    location / {
        root /var/www/lighthouse/lighthouse-master;
        index index.html index.htm;
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
}



```