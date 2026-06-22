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