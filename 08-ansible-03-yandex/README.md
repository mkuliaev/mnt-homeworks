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

Запуск playbook с флагом --check

  ```Bash
kuliaev@ansible2:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ ansible-playbook -i inventory/prod.yml site.yml --check
[WARNING]: Found both group and host with same name: lighthouse

PLAY [Install Clickhouse] *****************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host clickhouse-01 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [clickhouse-01]

TASK [Open ClickHouse HTTP port] **********************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Download ClickHouse packages] *******************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] ********************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Flush handlers to restart clickhouse] ***********************************************************************************************************************************************************************

TASK [Wait for ClickHouse to start] *******************************************************************************************************************************************************************************
skipping: [clickhouse-01]

TASK [Create database] ********************************************************************************************************************************************************************************************
skipping: [clickhouse-01]

PLAY [Install vector] *********************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host vector-01 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [vector-01]

TASK [Ensure vector config directory exists] **********************************************************************************************************************************************************************
ok: [vector-01]

TASK [Download vector package] ************************************************************************************************************************************************************************************
ok: [vector-01]

TASK [Install vector packages] ************************************************************************************************************************************************************************************
ok: [vector-01]

TASK [Flush handlers to restart vector] ***************************************************************************************************************************************************************************

TASK [Configure Vector | Template config] *************************************************************************************************************************************************************************
ok: [vector-01]

PLAY [Install and configure Lighthouse] ***************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Ensure www-data group exists] *******************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Ensure www-data user exists] ********************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Download Lighthouse static files] ***************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Ensure unzip is installed] **********************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Ensure /var/www/lighthouse directory exists] ****************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Unzip Lighthouse static files] ******************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Install Nginx] **********************************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Проверка существования fastcgi-php.conf] ********************************************************************************************************************************************************************
skipping: [lighthouse]

TASK [Configure Nginx] ********************************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Проверка конфигурации Nginx] ********************************************************************************************************************************************************************************
skipping: [lighthouse]

TASK [Перезагрузить Nginx, если конфигурация верна] ***************************************************************************************************************************************************************
changed: [lighthouse]

TASK [Start Nginx service] ****************************************************************************************************************************************************************************************
ok: [lighthouse]

PLAY RECAP ********************************************************************************************************************************************************************************************************
clickhouse-01              : ok=4    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
lighthouse                 : ok=11   changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
vector-01                  : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

kuliaev@ansible2:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ 

  ```


Запуск playbook с флагом --diff

  ```Bash
kuliaev@ansible2:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff
[WARNING]: Found both group and host with same name: lighthouse

PLAY [Install Clickhouse] *****************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host clickhouse-01 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [clickhouse-01]

TASK [Open ClickHouse HTTP port] **********************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Download ClickHouse packages] *******************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] ********************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Flush handlers to restart clickhouse] ***********************************************************************************************************************************************************************

TASK [Wait for ClickHouse to start] *******************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Create database] ********************************************************************************************************************************************************************************************
ok: [clickhouse-01]

PLAY [Install vector] *********************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host vector-01 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [vector-01]

TASK [Ensure vector config directory exists] **********************************************************************************************************************************************************************
ok: [vector-01]

TASK [Download vector package] ************************************************************************************************************************************************************************************
ok: [vector-01]

TASK [Install vector packages] ************************************************************************************************************************************************************************************
ok: [vector-01]

TASK [Flush handlers to restart vector] ***************************************************************************************************************************************************************************

TASK [Configure Vector | Template config] *************************************************************************************************************************************************************************
--- before: /etc/vector/vector.yml
+++ after: /home/kuliaev/.ansible/tmp/ansible-local-2147yzy344o_/tmpsja1u_7r/vector.yml.j2
@@ -1,16 +1,10 @@
-data_dir: "/var/lib/vector"
+[sources.system]
+type = "journald"
 
-sinks:
-  clickhouse:
-    type: clickhouse
-    inputs: ["my_source"]
-    endpoint: "http://84.201.154.43:8123"
-    database: "logs"
-    table: "my_table"
-    compression: "lz4"
-
-sources:
-  my_source:
-    type: file
-    include:
-      - "/var/log/myapp/*.log"
+[sinks.clickhouse]
+type = "clickhouse"
+inputs = ["system"]
+database = "logs"
+endpoint = "http://84.201.154.43:8123"
+table = "system_logs"
+skip_unknown_fields = true

changed: [vector-01]

PLAY [Install and configure Lighthouse] ***************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Ensure www-data group exists] *******************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Ensure www-data user exists] ********************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Download Lighthouse static files] ***************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Ensure unzip is installed] **********************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Ensure /var/www/lighthouse directory exists] ****************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Unzip Lighthouse static files] ******************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Install Nginx] **********************************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Проверка существования fastcgi-php.conf] ********************************************************************************************************************************************************************
changed: [lighthouse]

TASK [Configure Nginx] ********************************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Проверка конфигурации Nginx] ********************************************************************************************************************************************************************************
changed: [lighthouse]

TASK [Перезагрузить Nginx, если конфигурация верна] ***************************************************************************************************************************************************************
changed: [lighthouse]

TASK [Start Nginx service] ****************************************************************************************************************************************************************************************
ok: [lighthouse]

PLAY RECAP ********************************************************************************************************************************************************************************************************
clickhouse-01              : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
lighthouse                 : ok=13   changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

kuliaev@ansible2:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$

  ```

Проверка идемпотентности


  ```Bash
kuliaev@ansible2:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff
[WARNING]: Found both group and host with same name: lighthouse

PLAY [Install Clickhouse] *****************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host clickhouse-01 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [clickhouse-01]

TASK [Open ClickHouse HTTP port] **********************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Download ClickHouse packages] *******************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] ********************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Flush handlers to restart clickhouse] ***********************************************************************************************************************************************************************

TASK [Wait for ClickHouse to start] *******************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Create database] ********************************************************************************************************************************************************************************************
ok: [clickhouse-01]

PLAY [Install vector] *********************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host vector-01 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [vector-01]

TASK [Ensure vector config directory exists] **********************************************************************************************************************************************************************
ok: [vector-01]

TASK [Download vector package] ************************************************************************************************************************************************************************************
ok: [vector-01]

TASK [Install vector packages] ************************************************************************************************************************************************************************************
ok: [vector-01]

TASK [Flush handlers to restart vector] ***************************************************************************************************************************************************************************

TASK [Configure Vector | Template config] *************************************************************************************************************************************************************************
ok: [vector-01]

PLAY [Install and configure Lighthouse] ***************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Ensure www-data group exists] *******************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Ensure www-data user exists] ********************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Download Lighthouse static files] ***************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Ensure unzip is installed] **********************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Ensure /var/www/lighthouse directory exists] ****************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Unzip Lighthouse static files] ******************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Install Nginx] **********************************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Проверка существования fastcgi-php.conf] ********************************************************************************************************************************************************************
changed: [lighthouse]

TASK [Configure Nginx] ********************************************************************************************************************************************************************************************
ok: [lighthouse]

TASK [Проверка конфигурации Nginx] ********************************************************************************************************************************************************************************
changed: [lighthouse]

TASK [Перезагрузить Nginx, если конфигурация верна] ***************************************************************************************************************************************************************
changed: [lighthouse]

TASK [Start Nginx service] ****************************************************************************************************************************************************************************************
ok: [lighthouse]

PLAY RECAP ********************************************************************************************************************************************************************************************************
clickhouse-01              : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
lighthouse                 : ok=13   changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

kuliaev@ansible2:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ 


  ```

# LightHouse Installation Playbook

## Описание

Этот playbook устанавливает и настраивает LightHouse на Yandex Cloud. Он включает в себя установку Nginx, скачивание статических файлов LightHouse и настройку конфигурации веб-сервера.

## Параметры

- `hosts`: Хосты для установки LightHouse (lighthouse).
- `become`: Уровень привилегий для выполнения задач.

## Теги

- `lighthouse`: Установка и настройка LightHouse.


  ![Screnshot](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-03-yandex/png/lighhous.png)





  ![Screnshot](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-03-yandex/png/--check_1.png)

  ![Screnshot](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-03-yandex/png/---chekk.png)




  ![Screnshot](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-03-yandex/png/--diff_1.png)

  ![Screnshot](hhttps://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-03-yandex/png/--diff.png)
