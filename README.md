# tf-azurerm-module_primitive-mysql_server

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.113 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_mysql_flexible_server.mysql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Resource name of the mysql Flexible Server | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name of the mysql Flexible Server | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the mysql Flexible Server | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The name of the SKU used by this mysql Flexible Server | `string` | `"B_Standard_B1ms"` | no |
| <a name="input_create_mode"></a> [create\_mode](#input\_create\_mode) | The creation mode. Possible values are Default, GeoRestore, PointInTimeRestore, Replica, and Update | `string` | `"Default"` | no |
| <a name="input_mysql_version"></a> [mysql\_version](#input\_mysql\_version) | Version of the mysql Flexible Server. Required when `create_mode` is Default | `string` | `"16"` | no |
| <a name="input_delegated_subnet_id"></a> [delegated\_subnet\_id](#input\_delegated\_subnet\_id) | The ID of the subnet to which the mysql Flexible Server is delegated | `string` | `null` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | The ID of the private DNS zone. Required when `delegated_subnet_id` is set | `string` | `null` | no |
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | The administrator login for the mysql Flexible Server.<br>Required when `create_mode` is Default and `authentication.password_auth_enabled` is true | `string` | `null` | no |
| <a name="input_administrator_password"></a> [administrator\_password](#input\_administrator\_password) | The administrator password for the mysql Flexible Server.<br>Required when `create_mode` is Default and `authentication.password_auth_enabled` is true | `string` | `null` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | The backup retention days for the mysql Flexible Server, between 7 and 35 days | `number` | `7` | no |
| <a name="input_geo_redundant_backup_enabled"></a> [geo\_redundant\_backup\_enabled](#input\_geo\_redundant\_backup\_enabled) | Whether or not geo-redundant backups are enabled for this server | `bool` | `false` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone of the mysql Flexible Server | `string` | `null` | no |
| <a name="input_high_availability"></a> [high\_availability](#input\_high\_availability) | mode                      = The high availability mode. Possible values are SameZone or ZoneRedundant<br>standby\_availability\_zone = The availability zone for the standby server | <pre>object({<br>    mode                      = string<br>    standby_availability_zone = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of User Assigned Managed Identity IDs to be assigned | `list(string)` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The maintenance window of the mysql Flexible Server<br>day\_of\_week = The day of the week when maintenance should be performed<br>start\_hour   = The start hour of the maintenance window<br>start\_minute = The start minute of the maintenance window | <pre>object({<br>    day_of_week  = optional(string, 0)<br>    start_hour   = optional(number, 0)<br>    start_minute = optional(number, 0)<br>  })</pre> | <pre>{<br>  "day_of_week": 0,<br>  "start_hour": 0,<br>  "start_minute": 0<br>}</pre> | no |
| <a name="input_source_server_id"></a> [source\_server\_id](#input\_source\_server\_id) | The ID of the source mysql Flexible Server to restore from. Required when `create_mode` is GeoRestore, PointInTimeRestore, or Replica | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | n/a |
| <a name="output_delegated_subnet_id"></a> [delegated\_subnet\_id](#output\_delegated\_subnet\_id) | n/a |
| <a name="output_private_dns_zone_id"></a> [private\_dns\_zone\_id](#output\_private\_dns\_zone\_id) | n/a |
| <a name="output_source_server_id"></a> [source\_server\_id](#output\_source\_server\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
