// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.location
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  maximum_length          = each.value.max_length
  instance_resource       = var.instance_resource
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = module.resource_names["resource_group"].minimal_random_suffix
  location = var.location

  tags = merge(var.tags, { resource_name = module.resource_names["resource_group"].standard })
}

module "managed_identity" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/user_managed_identity/azurerm"
  version = "~> 1.0"

  user_assigned_identity_name = module.resource_names["managed_identity"].minimal_random_suffix
  resource_group_name         = module.resource_group.name
  location                    = var.location
  depends_on                  = [module.resource_group]
}

module "virtual_network" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/virtual_network/azurerm"
  version = "~> 3.0"

  vnet_name           = module.resource_names["virtual_network"].minimal_random_suffix
  resource_group_name = module.resource_group.name
  vnet_location       = var.location

  address_space = [var.vnet_address_space]
  subnets = {
    mysql-subnet = {
      prefix = var.vnet_address_space
      delegation = {
        mysql = {
          service_name    = "Microsoft.DBforMySQL/flexibleServers"
          service_actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    }
  }

  tags = merge(var.tags, { resource_name = module.resource_names["virtual_network"].standard })

  depends_on = [module.resource_group]
}

module "private_dns_zone" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_zone/azurerm"
  version = "~> 1.0"

  zone_name           = var.private_dns_zone_name
  resource_group_name = module.resource_group.name

  tags = var.tags

  depends_on = [module.resource_group]
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  name                  = module.resource_names["dns_vnet_link"].minimal_random_suffix
  resource_group_name   = module.resource_group.name
  private_dns_zone_name = module.private_dns_zone.zone_name
  virtual_network_id    = module.virtual_network.vnet_id
}

# create a random password for the admin user
resource "random_password" "admin_password" {
  length           = 16
  special          = true
  min_lower        = 1
  min_upper        = 1
  min_special      = 1
  override_special = "%^&@" ### underscore is not considered "special" by Azure MySQL
}

module "mysql_server" {
  source = "./../.."

  name                = module.resource_names["mysql_server"].minimal_random_suffix
  resource_group_name = module.resource_group.name
  location            = var.location

  create_mode   = var.create_mode
  mysql_version = var.mysql_version
  sku_name      = var.sku_name

  identity_ids = [module.managed_identity.id]

  administrator_login    = var.administrator_login
  administrator_password = random_password.admin_password.result

  delegated_subnet_id = module.virtual_network.subnet_map["mysql-subnet"].id
  private_dns_zone_id = module.private_dns_zone.id

  high_availability = var.high_availability

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  maintenance_window = var.maintenance_window

  storage = var.storage

  source_server_id = var.source_server_id
  zone             = var.zone

  tags = merge(var.tags, { resource_name = module.resource_names["mysql_server"].standard })

  depends_on = [module.resource_group, module.virtual_network, module.private_dns_zone, azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link, module.managed_identity]
}
