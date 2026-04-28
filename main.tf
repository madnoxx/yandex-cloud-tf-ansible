terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    bucket     = "dmitry-tf-state-12345"
    region     = "ru-central1"
    key        = "prod/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  zone = "ru-central1-a"
}

resource "yandex_vpc_network" "my_network" {
  name = "dracarys-network"
}

resource "yandex_vpc_subnet" "my_subnet" {
  name           = "dracarys-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

module "web_server" {
  source        = "./modules/compute"
  
  instance_name = "dracarys-web"
  subnet_id     = yandex_vpc_subnet.my_subnet.id
  ssh_pub_key   = var.public_ssh_key
}

module "db_server" {
  source = "./modules/compute"
  
  instance_name = "dracarys-db"
  subnet_id     = yandex_vpc_subnet.my_subnet.id
  cpu_cores     = 4
  memory_gb     = 4
  ssh_pub_key   = var.public_ssh_key
}

output "web_ip" {
  value = module.web_server.external_ip
}

output "db_ip" {
  value = module.db_server.external_ip
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tftpl",
    {
      web_ip = module.web_server.external_ip,
      db_ip = module.db_server.external_ip
    }
  )
  filename = "hosts.ini"
}
