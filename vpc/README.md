<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.8.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [yandex_vpc_network.vpc](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network) | resource |
| [yandex_vpc_subnet.vpc_subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr"></a> [cidr](#input\_cidr) | n/a | `list(string)` | <pre>[<br/>  "10.0.1.0/24"<br/>]</pre> | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | n/a | `string` | `null` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | n/a | `string` | `"mia_vpc"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | n/a | `string` | `"ru-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_net"></a> [all\_net](#output\_all\_net) | n/a |
| <a name="output_all_subnet"></a> [all\_subnet](#output\_all\_subnet) | n/a |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | n/a |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | n/a |
| <a name="output_zone"></a> [zone](#output\_zone) | n/a |
<!-- END_TF_DOCS -->