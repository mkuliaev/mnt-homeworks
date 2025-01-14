# Домашнее задание к занятию 1 «Введение в Ansible» Mikhail Kuliaev

## Подготовка к выполнению

1. Установите Ansible версии 2.10 или выше.

 ```javascript

kuliaev@ansible1:~$ ansible --version
ansible [core 2.16.3]
  config file = None
  configured module search path = ['/home/kuliaev/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/kuliaev/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.12.3 (main, Sep 11 2024, 14:17:37) [GCC 13.2.0] (/usr/bin/python3)
  jinja version = 3.1.2
  libyaml = True
 
 ```

2. Создайте свой публичный репозиторий на GitHub с произвольным именем.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

---

## Основная часть

1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте значение, которое имеет факт `some_fact` для указанного хоста при выполнении playbook.

```yml
kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ ansible-playbook -i inventory/test.yml site.yml

PLAY [Print os facts] ********************************************************************************************

TASK [Gathering Facts] *******************************************************************************************
ok: [localhost]

TASK [Print OS] **************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP ********************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ 


 ```

2. Найдите файл с переменными (group_vars), в котором задаётся найденное в первом пункте значение, и поменяйте его на `all default fact`.

```yml  

---
  some_fact: "all default fact"

 ```

3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

```Bash

kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ sudo docker ps -a
CONTAINER ID   IMAGE                      COMMAND            CREATED              STATUS              PORTS     NAMES
3bc144773758   pycontribs/ubuntu:latest   "sleep infinity"   52 seconds ago       Up 49 seconds                 ubuntu
bf06802b1142   pycontribs/centos:7        "sleep infinity"   About a minute ago   Up About a minute             centos7
kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ 

 ```

4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

```yml 


PLAY [Print os facts] *******************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [centos7]
ok: [ubuntu]

TASK [Print OS] *************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***********************************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

TASK [Fixed value some_fact] ************************************************************************************************************
ok: [centos7] => {
    "some_fact": "el"
}
ok: [ubuntu] => {
    "some_fact": "deb"
}

PLAY RECAP ******************************************************************************************************************************
centos7                    : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ 




 ```

5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились значения: для `deb` — `deb default fact`, для `el` — `el default fact`.

6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.

```YML 
kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ sudo ansible-playbook -i inventory/prod.yml site.yml

PLAY [Print os facts] *******************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [centos7]
ok: [ubuntu]

TASK [Print OS] *************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***********************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

TASK [Fixed value some_fact] ************************************************************************************************************
ok: [centos7] => {
    "some_fact": "el default fact"
}
ok: [ubuntu] => {
    "some_fact": "deb default fact"
}

PLAY RECAP ******************************************************************************************************************************
centos7                    : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$



 ```

7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

```SQL
kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ ansible-vault encrypt group_vars/deb/examp.yml
New Vault password: 
Confirm New Vault password: 
Encryption successful
kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ ansible-vault encrypt group_vars/el/examp.yml
New Vault password: 
Confirm New Vault password: 
Encryption successful
kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ 

 ```

8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.

```YML 
kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ sudo ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] *******************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [centos7]
ok: [ubuntu]

TASK [Print OS] *************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***********************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

TASK [Fixed value some_fact] ************************************************************************************************************
ok: [centos7] => {
    "some_fact": "el default fact"
}
ok: [ubuntu] => {
    "some_fact": "deb default fact"
}

PLAY RECAP ******************************************************************************************************************************
centos7                    : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ 


 ```

9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь, что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

```YML 
kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ sudo ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] *******************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************
ok: [centos7]
ok: [localhost]
ok: [ubuntu]

TASK [Print OS] *************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***********************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "all default fact"
}

TASK [Fixed value some_fact] ************************************************************************************************************
ok: [centos7] => {
    "some_fact": "el default fact"
}
ok: [ubuntu] => {
    "some_fact": "deb default fact"
}
ok: [localhost] => {
    "some_fact": "all default fact"
}

PLAY RECAP ******************************************************************************************************************************
centos7                    : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

kuliaev@ansible1:~/dowl/mnt-homeworks/08-ansible-01-base/playbook$ 

 ```

12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.
13. Предоставьте скриншоты результатов запуска команд.

(https://github.com/mkuliaev/mnt-homeworks/tree/MNT-video/08-ansible-01-base/playbook)


<details>
<summary>скриншоты</summary>

![изображения 1](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/png/1.png)
![изображения 2](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/png/2.png)
![изображения 3](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/png/3.png)
![изображения 4](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/png/4.png)
![изображения 5](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/png/5.png)
![изображения 6](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/png/6.png)
![изображения 7](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/png/7.png)
![изображения 8](https://github.com/mkuliaev/mnt-homeworks/blob/MNT-video/08-ansible-01-base/png/8.png)

</details>


## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот вариант](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в ваш личный репозиторий.


---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
