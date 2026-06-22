###cloud vars

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