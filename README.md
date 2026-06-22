# Домашнее задание к занятию «Продвинутые методы работы с Terraform»

### Задание 1

1. Возьмите из [демонстрации к лекции готовый код](https://github.com/netology-code/ter-homeworks/tree/main/04/demonstration1) для создания с помощью двух вызовов remote-модуля -> двух ВМ, относящихся к разным проектам(marketing и analytics) используйте labels для обозначения принадлежности.  В файле cloud-init.yml необходимо использовать переменную для ssh-ключа вместо хардкода. Передайте ssh-ключ в функцию template_file в блоке vars ={} .
Воспользуйтесь [**примером**](https://grantorchard.com/dynamic-cloudinit-content-with-terraform-file-templates/). Обратите внимание, что ssh-authorized-keys принимает в себя список, а не строку.
3. Добавьте в файл cloud-init.yml установку nginx.
4. Предоставьте скриншот подключения к консоли и вывод команды ```sudo nginx -t```, скриншот консоли ВМ yandex cloud с их метками. Откройте terraform console и предоставьте скриншот содержимого модуля. Пример: > module.marketing_vm
------
В случае использования MacOS вы получите ошибку "Incompatible provider version" . В этом случае скачайте remote модуль локально и поправьте в нем версию template провайдера на более старую.
------

### Решение 1

Подправил tf-файлы из демонстрации и шаблон [модуля](https://github.com/udjin10/yandex_compute_instance) под себя, полученный модуль выложил к [себе](https://github.com/murtazinilyas/mia_yandex_compute_instance) в GitHub.

Обозначил переменные для **cloud-init.yml**:

```hcl
variable "public_key" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "username" {
  type    = string
  default = "user"
}

variable "packages" {
  type    = string
  default = "nginx"
}
```

В root-модуле поправил блок **data**:

```hcl
...
data template_file "cloudinit" {
  template = file("./cloud-init.yml")

  vars = {
    username           = var.username
    ssh_public_key     = file(var.public_key)
    packages           = jsonencode(var.packages)
  }
}
```

Подправил **cloud-init.yml** для выполнения условия задания:

```hcl
#cloud-config
users:
  - name: ${username}
    groups: sudo
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    ssh_authorized_keys:
      - ${ssh_public_key}
package_update: true
package_upgrade: false
packages:
  - ${packages}
```

Выполнил ```terraform apply```.

Вывод команды ```sudo nginx -t``` на машине **marketing**:

![1-1](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t1-1.png)

Вывод команды ```sudo nginx -t``` на машине **analytics**:

![1-2](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t1-2.png)

Скриншот консоли YC с метками машин:

![1-5](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t1-5.png)

Содержимое модуля **marketing**:

![1-4](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t1-4.png)

Содержимое модуля **analytics**:

![1-3](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t1-3.png)

### Задание 2

1. Напишите локальный модуль vpc, который будет создавать 2 ресурса: **одну** сеть и **одну** подсеть в зоне, объявленной при вызове модуля, например: ```ru-central1-a```.
2. Вы должны передать в модуль переменные с названием сети, zone и v4_cidr_blocks.
3. Модуль должен возвращать в root module с помощью output информацию о yandex_vpc_subnet. Пришлите скриншот информации из terraform console о своем модуле. Пример: > module.vpc_dev  
4. Замените ресурсы yandex_vpc_network и yandex_vpc_subnet созданным модулем. Не забудьте передать необходимые параметры сети из модуля vpc в модуль с виртуальной машиной.
5. Сгенерируйте документацию к модулю с помощью terraform-docs.
 
Пример вызова

```
module "vpc_dev" {
  source       = "./vpc"
  env_name     = "develop"
  zone = "ru-central1-a"
  cidr = "10.0.1.0/24"
}
```

### Решение 2

Написал модуль:

[**main.tf**](https://github.com/murtazinilyas/ter_adv/blob/main/vpc/main.tf)

```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.8.4"
}

resource "yandex_vpc_network" "vpc" {
  name = var.env_name == null ? "${var.instance_name}" : "${var.env_name}-${var.instance_name}"
}

resource "yandex_vpc_subnet" "vpc_subnet" {
  name           = var.env_name == null ? "${var.instance_name}-${var.zone}" : "${var.env_name}-${var.instance_name}-${var.zone}"
  zone           = var.zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = var.cidr
}
```

[**variables.tf**](https://github.com/murtazinilyas/ter_adv/blob/main/vpc/variables.tf)

```hcl
variable "env_name" {
  type    = string
  default = null
}

variable "instance_name" {
  type    = string
  default = "mia_vpc"
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "cidr" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}
```

[**outputs.tf**](https://github.com/murtazinilyas/ter_adv/blob/main/vpc/outputs.tf)

```hcl
output "network_id" {
  value = yandex_vpc_network.vpc.id
}

output "subnet_id" {
  value = yandex_vpc_subnet.vpc_subnet.id
}

output "zone" {
  value = yandex_vpc_subnet.vpc_subnet.zone
}

output "all_net" {
  value = yandex_vpc_network.vpc
}

output "all_subnet" {
  value = yandex_vpc_subnet.vpc_subnet
}
```

Заменил в root-модуле ресурсы **yandex_vpc_network** и **yandex_vpc_subnet** и переменные **network_id**, **subnet_zones** и **subnet_ids** в модулях **marketing** и **analytics**:

```hcl
module "vpc" {
  source   = "./vpc"
  env_name = "develop"
  zone     = "ru-central1-a"
  cidr     = ["10.0.1.0/24"]
}

module "marketing" {
...
  network_id     = module.vpc.network_id
  subnet_zones   = [module.vpc.zone]
  subnet_ids     = [module.vpc.subnet_id]
...
}

module "analytics" {
...
  network_id     = module.vpc.network_id
  subnet_zones   = [module.vpc.zone]
  subnet_ids     = [module.vpc.subnet_id]
...
}
```

Содержимое модуля **vpc**:

![2-1](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t2-1.png)

### Задание 3
1. Выведите список ресурсов в стейте.
2. Полностью удалите из стейта модуль vpc.
3. Полностью удалите из стейта модуль vm.
4. Импортируйте всё обратно. Проверьте terraform plan. Значимых(!!) изменений быть не должно.
Приложите список выполненных команд и скриншоты процессы.

### Решение 3

Вывел список ресурсов в стейте и после удалили модули **vpc**, **analytics** и **marketing**:

![3-1](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t3-1.png)

Командой ```yc vpc network list``` вывел список существующих сетей и импортировал ресурс **network**:

![3-2](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t3-2.png)

Командой ```yc vpc subnet list``` вывел список существующих подсетей и импортировал ресурс **subnet**:

![3-3](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t3-3.png)

Командой ```yc compute instances list``` вывел список существующих ВМ и импортировал ресурс **analytics**:

![3-4](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t3-4.png)

Командой ```yc compute instances list``` вывел список существующих ВМ и импортировал ресурс **marketing**:

![3-5](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t3-5.png)

Вывод команд ```terraform plan``` и ```terraform state list``` после проведенного импортирования удаленных ранее ресурсов:

![3-6](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t3-6.png)

З.Ы. Диски импортировать отдельно не нужно, они автоматически импортируются вместе с ВМ.

---

[Посмотреть файлы до выполнения дополнительных заданий](https://github.com/murtazinilyas/ter_adv/tree/8c3ad0e4b5ce0e7a10a4054ed429f21c6e2fb233)

---

### Задание 4*

1. Измените модуль vpc так, чтобы он мог создать подсети во всех зонах доступности, переданных в переменной типа list(object) при вызове модуля.  
  
Пример вызова
```
module "vpc_prod" {
  source       = "./vpc"
  env_name     = "production"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" },
    { zone = "ru-central1-c", cidr = "10.0.3.0/24" },
  ]
}

module "vpc_dev" {
  source       = "./vpc"
  env_name     = "develop"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
  ]
}
```

Предоставьте код, план выполнения, результат из консоли YC.

### Решение 4

Исправил модуль:

[**main.tf**](https://github.com/murtazinilyas/ter_adv/blob/main/vpc/main.tf)

```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.8.4"  ### some test 29.10.2025
}

resource "yandex_vpc_network" "vpc" {
  name = var.env_name == null ? "${var.instance_name}" : "${var.env_name}-${var.instance_name}"
}

resource "yandex_vpc_subnet" "vpc_subnet" {
  count          = length(var.subnets)
  name           = var.env_name == null ? "${var.instance_name}-${var.subnets[count.index].zone}" : "${var.env_name}-${var.instance_name}-${var.subnets[count.index].zone}"
  zone           = var.subnets[count.index].zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = var.subnets[count.index].cidr
}
```

[**variables.tf**](https://github.com/murtazinilyas/ter_adv/blob/main/vpc/variables.tf)

```hcl
variable "env_name" {
  type    = string
  default = null
}

variable "instance_name" {
  type    = string
  default = "mia_vpc"
}

variable "subnets" {
  type    = list(object({zone = string, cidr = list(string)}))
  default = [
    { zone = "ru-central1-a", cidr = ["10.0.1.0/24"]},
    ]
}
```

[**outputs.tf**](https://github.com/murtazinilyas/ter_adv/blob/main/vpc/outputs.tf)

```hcl
output "network_id" {
  value = yandex_vpc_network.vpc.id
}

output "subnet_id" {
  value = yandex_vpc_subnet.vpc_subnet[*].id
}

output "zone" {
  value = yandex_vpc_subnet.vpc_subnet[*].zone
}

output "all_net" {
  value = yandex_vpc_network.vpc
}

output "all_subnet" {
  value = yandex_vpc_subnet.vpc_subnet[*]
}
```

Исправил root-модуль:

```hcl
module "vpc" {
  source   = "./vpc"
  env_name = "develop"
  subnets  = [
    {zone = "ru-central1-a", cidr = ["10.0.1.0/24"]},
    {zone = "ru-central1-b", cidr = ["10.0.2.0/24"]}
  ]
}

module "marketing" {
...
  subnet_zones   = module.vpc.zone
  subnet_ids     = module.vpc.subnet_id
...
  }

}

module "analytics" {
...
  subnet_zones   = module.vpc.zone
  subnet_ids     = module.vpc.subnet_id
  instance_count = 2
...
    }
...
}
```

План выполнения:

![4-3](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t4-3.png)

Скриншот консоли YC:

![4-2](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t4-2.png)

З.Ы. Машину создать не получилось, т.к. исчерпана квота на выдачу NAT-адресов

Обновленное содержимое модуля **vpc**:

![4-1](https://github.com/murtazinilyas/ter_adv/blob/main/screenshots/t4-1.png)
