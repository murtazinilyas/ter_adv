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