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

output "mysql_id" {
  value = module.mysql_server.id
}

output "mysql_name" {
  value = module.mysql_server.name
}

output "mysql_fqdn" {
  value = module.mysql_server.fqdn
}

output "vnet_id" {
  value = module.virtual_network.vnet_id
}

output "resource_group_name" {
  value = module.resource_group.name
}

output "mysql_storage" {
  value = var.storage
}

output "mysql_maintenance_window" {
  value = var.maintenance_window
}
