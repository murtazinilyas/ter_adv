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