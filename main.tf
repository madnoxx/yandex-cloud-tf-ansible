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

module "web_servers" {
  source        = "./modules/compute"
  count         = 2
  instance_name = "dracarys-web-${count.index}"
  subnet_id     = yandex_vpc_subnet.my_subnet.id
  ssh_pub_key   = var.public_ssh_key

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "<h1>Hello from Web Server ${count.index}! Managed by Terraform</h1>" > /var/www/html/index.html
    systemctl restart nginx
  EOF
}

module "db_server" {
  source = "./modules/compute"  
  instance_name = "dracarys-db"
  subnet_id     = yandex_vpc_subnet.my_subnet.id
  cpu_cores     = 4
  memory_gb     = 4
  ssh_pub_key   = var.public_ssh_key
}

resource "yandex_lb_target_group" "web_tg" {
  name = "web-target-group"

  target {
    subnet_id = yandex_vpc_subnet.my_subnet.id
    address   = module.web_servers[0].internal_ip
  }

  target {
    subnet_id = yandex_vpc_subnet.my_subnet.id
    address   = module.web_servers[1].internal_ip
  }
}

resource "yandex_lb_network_load_balancer" "main_lb" {
  name = "web-load-balancer"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web_tg.id
    healthcheck {
      name = "http-check"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

output "load_balancer_ip" {
  description = "ЗАЙДИ СЮДА В БРАУЗЕРЕ:"
  value       = yandex_lb_network_load_balancer.main_lb.listener.*.external_address_spec[0].*.address
}

output "web_servers_ips" {
  value = module.web_servers[*].external_ip
}

#resource "local_file" "ansible_inventory" {
#  content = templatefile("inventory.tftpl",
#    {
#      web_ip = module.web_server.external_ip,
#      db_ip = module.db_server.external_ip
#    }
#  )
#  filename = "hosts.ini"
#}
