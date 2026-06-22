module "vpc" {
  source   = "./vpc"
  env_name = "develop"
  subnets  = [
    {zone = "ru-central1-a", cidr = ["10.0.1.0/24"]},
    {zone = "ru-central1-b", cidr = ["10.0.2.0/24"]}
  ]
}

module "marketing" {
  source         = "git::https://github.com/murtazinilyas/mia_yandex_compute_instance?ref=main"
  env_name       = "marketing" 
  network_id     = module.vpc.network_id
  subnet_zones   = module.vpc.zone
  subnet_ids     = module.vpc.subnet_id
  instance_name  = "web-marketing"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = { 
    owner= "marketing",
    }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
    serial-port-enable = 1
  }

}

module "analytics" {
  source         = "git::https://github.com/murtazinilyas/mia_yandex_compute_instance?ref=main"
  env_name       = "analytics"
  network_id     = module.vpc.network_id
  subnet_zones   = module.vpc.zone
  subnet_ids     = module.vpc.subnet_id
  instance_name  = "web-analytics"
  instance_count = 2
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = { 
    owner= "analytics",
    }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
    serial-port-enable = 1
  }

}

#Пример передачи cloud-config в ВМ для демонстрации №3
data template_file "cloudinit" {
  template = file("./cloud-init.yml")

  vars = {
    username           = var.username
    ssh_public_key     = file(var.public_key)
    packages           = jsonencode(var.packages)
  }
}
