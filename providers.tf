terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">1.12.0"
}

provider "yandex" {
  cloud_id                 = local.cloud_id
  folder_id                = local.folder_id
}
