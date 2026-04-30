variable "instance_name" {
  description = "Имя виртуальной машины"
  type        = string
}

variable "subnet_id" {
  description = "ID подсети, куда подключать сервер"
  type        = string
}

variable "cpu_cores" {
  description = "Количество ядер CPU"
  type        = number
  default     = 2
}

variable "memory_gb" {
  description = "Количество ОЗУ в ГБ"
  type        = number
  default     = 2
}

variable "ssh_pub_key" {
  description = "Содержимое публичного SSH-ключа"
  type        = string
}

variable "user_data" {
  description = "Скрипт для запуска при старте сервера"
  type        = string
  default     = ""
}
