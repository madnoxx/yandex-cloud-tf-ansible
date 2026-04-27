# Yandex Cloud Infrastructure Deployment (Terraform + Ansible)

Этот проект демонстрирует автоматизированный подход к развертыванию инфраструктуры как кода (IaC).

## Стек технологий
* **Terraform:** Развертывание виртуальных машин и сетей (VPC) в Yandex Cloud.
* **Ansible:** Автоматическая конфигурация серверов (обновление кэша, установка Nginx, деплой HTML).
* **Remote State:** Использование Yandex Object Storage (S3) для безопасного хранения `terraform.tfstate`.

## 🚀 Архитектура проекта
1. `modules/compute`: Модуль Terraform для создания виртуальных машин с гибкой настройкой CPU/RAM.
2. `inventory.tftpl`: Шаблон, через который Terraform динамически генерирует `hosts.ini` для Ansible с актуальными IP-адресами.
3. `playbook.yml`: Ansible плейбук для установки и запуска Nginx на всех поднятых серверах.

## ⚙️ Как запустить
1. Настройте переменные окружения для авторизации (`YC_TOKEN`, `YC_FOLDER_ID`, `AWS_ACCESS_KEY_ID`).
2. Выполните инициализацию Terraform:
   `terraform init`
3. Проверьте план и примените изменения:
   `terraform plan`
   `terraform apply -auto-approve`
4. Запустите конфигурацию серверов:
   `ansible-playbook -i hosts.ini playbook.yml`
