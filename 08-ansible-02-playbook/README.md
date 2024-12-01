# Домашнее задание к занятию 2 «Работа с Playbook»

## Подготовка к выполнению

1. * Необязательно. Изучите, что такое [ClickHouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [Vector](https://www.youtube.com/watch?v=CgEhyffisLY).
2. Создайте свой публичный репозиторий на GitHub с произвольным именем или используйте старый.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

## Основная часть

1. Подготовьте свой inventory-файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev). Конфигурация vector должна деплоиться через template файл jinja2. От вас не требуется использовать все возможности шаблонизатора, просто вставьте стандартный конфиг в template файл. Информация по шаблонам по [ссылке](https://www.dmosk.ru/instruktions.php?object=ansible-nginx-install). не забудьте сделать handler на перезапуск vector в случае изменения конфигурации!
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги. Пример качественной документации ansible playbook по [ссылке](https://github.com/opensearch-project/ansible-playbook). Так же приложите скриншоты выполнения заданий №5-8
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---


 ```javascript
kuliaev@ansible02:~$ ansible --version
ansible [core 2.12.10]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/kuliaev/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/kuliaev/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Nov  7 2024, 13:10:47) [GCC 9.4.0]
  jinja version = 2.10.1
  libyaml = True


 ```
```Bash
kuliaev@ansible02:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ cat Dockerfile 
FROM rockylinux:8

RUN dnf -y update && \
    dnf -y install epel-release && \
    dnf -y install python38 python38-pip && \
    dnf clean all

RUN alternatives --set python /usr/bin/python3.8 && \
    ln -s /usr/bin/pip3.8 /usr/bin/pip

CMD ["sleep", "infinity"]



 ```

 ```Bash
kuliaev@ansible02:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ cat docker-compose.yml 
---

version: '3.8'  

services:
  # Сервис для ClickHouse
  clickhouse:
    build:
      context: . # каталог с Dockerfile
    container_name: clickhouse-01 
    restart: unless-stopped  

  # Сервис для Vector
  vector:
    build:
      context: . # каталог с Dockerfile
    container_name: vector-01 
    restart: unless-stopped  


networks:
  default:
    name: my_network  



  ```



 ```Bash
kuliaev@ansible02:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ docker-compose up -d
WARN[0003] /home/kuliaev/dowl/mnt-homeworks/08-ansible-02-playbook/playbook/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
[+] Building 57.0s (6/8)                                                                                               docker:default
 ⠏ Service clickhouse  Building                                                                                                 78.6s 
 ⠏ Service vector      Building                                                                                                 78.6s 
[+] Building 103.6s (12/12) FINISHED                                                                                   docker:default 
 => [clickhouse internal] load build definition from Dockerfile                                                                  0.3s 
 => => transferring dockerfile: 304B                                                                                             0.0s
 => [clickhouse internal] load .dockerignore                                                                                     0.3s 
 => => transferring context: 2B                                                                                                  0.0s 
 => [vector internal] load .dockerignore                                                                                         0.3s 
 => => transferring context: 2B                                                                                                  0.0s
 => [vector internal] load build definition from Dockerfile                                                                      0.3s 
 => => transferring dockerfile: 304B                                                                                             0.0s 
 => [clickhouse internal] load metadata for docker.io/library/rockylinux:8                                                       2.3s 
 => [vector 1/3] FROM docker.io/library/rockylinux:8@sha256:9794037624aaa6212aeada1d28861ef5e0a935adaf93e4ef79837119f2a2d04c    26.3s 
 => => resolve docker.io/library/rockylinux:8@sha256:9794037624aaa6212aeada1d28861ef5e0a935adaf93e4ef79837119f2a2d04c            0.0s 
 => => sha256:9794037624aaa6212aeada1d28861ef5e0a935adaf93e4ef79837119f2a2d04c 2.41kB / 2.41kB                                   0.0s 
 => => sha256:2d05a9266523bbf24f33ebc3a9832e4d5fd74b973c220f2204ca802286aa275d 1.04kB / 1.04kB                                   0.0s 
 => => sha256:c79048e50f5fce116723442952adf4f5258455a1665bbc64aa65469abe9ead90 578B / 578B                                       0.0s 
 => => sha256:9088cdb84e397c480d4c5f1675d1aa6928c3e8b5b30c57b68a756d5d1fda4d80 72.82MB / 72.82MB                                23.1s 
 => => extracting sha256:9088cdb84e397c480d4c5f1675d1aa6928c3e8b5b30c57b68a756d5d1fda4d80                                        2.4s 
 => [clickhouse 2/3] RUN dnf -y update &&     dnf -y install epel-release &&     dnf -y install python38 python38-pip &&     d  72.3s 
 => [clickhouse 3/3] RUN alternatives --set python /usr/bin/python3.8 &&     ln -s /usr/bin/pip3.8 /usr/bin/pip                  0.5s 
 => [vector] exporting to image                                                                                                  1.7s 
 => => exporting layers                                                                                                          1.7s 
 => => writing image sha256:580e1c3984fb251cb38037a084480802b4b2d7b4fb52864ababfa8d21a34258e                                     0.0s 
 => => naming to docker.io/library/playbook-vector                                                                               0.0s 
 => [clickhouse] exporting to image                                                                                              1.7s 
 => => exporting layers                                                                                                          1.7s
 => => writing image sha256:326c36a2c16aae91bbeb6047ec966c7606194c36665b098cfe059f5859d80c00                                     0.0s
[+] Running 5/5o docker.io/library/playbook-clickhouse                                                                           0.0s
 ✔ Service clickhouse       Built                                                                                              104.9s 
 ✔ Service vector           Built                                                                                              104.9s 
 ✔ Network my_network       Created                                                                                              0.0s 
 ✔ Container clickhouse-01  Started                                                                                              4.8s 
 ✔ Container vector-01      Started                                                                                              4.8s 
kuliaev@ansible02:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ 


  ```



 ```Bash
kuliaev@ansible02:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ docker ps -a
CONTAINER ID   IMAGE                 COMMAND            CREATED         STATUS         PORTS     NAMES
f85a7cb64e9c   playbook-vector       "sleep infinity"   2 minutes ago   Up 2 minutes             vector-01
43ad659ab79e   playbook-clickhouse   "sleep infinity"   2 minutes ago   Up 2 minutes             clickhouse-01
kuliaev@ansible02:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ 


  ```



 ```Bash
- name: Install vector
  hosts: vector
  handlers:
    - name: Start vector service
      become: true
      ansible.builtin.service:
        name: vector
        state: restarted

  tasks:
    - name: Get vector distrib
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-1.x86_64.rpm"
        dest: "./vector-{{ vector_version }}.rpm"
        mode: "0644"
      notify: Start vector service

    - name: Install vector packages
      become: true
      ansible.builtin.dnf:
        name:
          - vector-{{ vector_version }}.rpm
        disable_gpg_check: true
    - name: Flush handlers to restart vector
      ansible.builtin.meta: flush_handlers

    - name: Configure Vector | ensure what directory exists
      ansible.builtin.file:
        path: "{{ vector_config_dir }}"
        state: directory
        mode: "0755"
    - name: Configure Vector | Template config
      ansible.builtin.template:
        src: "template/vector.yml.j2"
        dest: "{{ vector_config_dir }}/vector.yml"
        mode: "0644"


  ```


 ```Bash
kuliaev@ansible02:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ ansible-lint site.yml

Command 'ansible-lint' not found, but can be installed with:

apt install ansible-lint
Please ask your administrator.

kuliaev@ansible02:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ sudo apt install ansible-lint
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  python3-ruamel.yaml
The following NEW packages will be installed:
  ansible-lint python3-ruamel.yaml
0 upgraded, 2 newly installed, 0 to remove and 1 not upgraded.
Need to get 269 kB of archives.
After this operation, 1,230 kB of additional disk space will be used.



  ```


 ```YML
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_connection: docker
vector:
  hosts:
    vector-01:
      ansible_connection: docker




  ```


 ```Bash
kuliaev@ansible02:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] *************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************
[WARNING]: Platform linux on host clickhouse-01 is using the discovered Python interpreter at /usr/bin/python3.8, but future installation of another Python
interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more
information.
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *********************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 0, "group": "root", "item": "clickhouse-common-static", "mode": "0644", "msg": "Request failed", "owner": "root", "response": "HTTP Error 404: Not Found", "size": 246310036, "state": "file", "status_code": 404, "uid": 0, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] *********************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] ****************************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "module_stderr": "/bin/sh: sudo: command not found\n", "module_stdout": "", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 127}

PLAY RECAP ****************************************************************************************************************************************************
clickhouse-01              : ok=2    changed=0    unreachable=0    failed=1    skipped=0    rescued=1    ignored=0   

kuliaev@ansible02:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ 



  ```



 ```Bash
uliaev@ansible02:~/dowl/mnt-homeworks/08-ansible-02-playbook/playbook$ docker-compose down
WARN[0000] /home/kuliaev/dowl/mnt-homeworks/08-ansible-02-playbook/playbook/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
[+] Running 3/3
 ✔ Container vector-01      Removed                                                                                                                      10.3s 
 ✔ Container clickhouse-01  Removed                                                                                                                      10.3s 
 ✔ Network my_network       Removed                                                                                                                       0.1s 
k

  ```
Дописываем в Docker файл - sudo


 ```YML
FROM rockylinux:8

RUN dnf -y update && \
    dnf -y install epel-release && \
    dnf -y install python38 python38-pip sudo && \
    dnf clean all

RUN alternatives --set python /usr/bin/python3.8 && \
    ln -s /usr/bin/pip3.8 /usr/bin/pip

CMD ["sleep", "infinity"]



  ```
Собираем по новой  - без кэша


 ```Bash


  ```
  ```Bash


  ```



 ```Bash


  ```
  ```Bash


  ```



 ```Bash


  ```
  ```Bash


  ```



 ```Bash


  ```
  ```Bash


  ```



 ```Bash


  ```