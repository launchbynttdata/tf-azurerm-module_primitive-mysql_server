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

variable "name" {
  description = "Resource name of the mysql Flexible Server"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name of the mysql Flexible Server"
  type        = string
}

variable "location" {
  description = "Location of the mysql Flexible Server"
  type        = string
}

variable "sku_name" {
  description = "The name of the SKU used by this mysql Flexible Server"
  type        = string
  default     = "GP_Standard_D2ads_v5"
}

variable "create_mode" {
  description = "The creation mode. Possible values are Default, GeoRestore, PointInTimeRestore, Replica, and Update"
  type        = string
  default     = "Default"

  validation {
    condition     = can(regex("^(Default|GeoRestore|PointInTimeRestore|Replica|Update)$", var.create_mode))
    error_message = "Invalid create_mode value"
  }
}

variable "mysql_version" {
  description = "Version of the mysql Flexible Server. Required when `create_mode` is Default"
  type        = string
  default     = "8.0.21"
}

variable "delegated_subnet_id" {
  description = "The ID of the subnet to which the mysql Flexible Server is delegated"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone. Required when `delegated_subnet_id` is set"
  type        = string
  default     = null
}

variable "administrator_login" {
  description = <<-EOT
    The administrator login for the mysql Flexible Server.
    Required when `create_mode` is Default and `authentication.password_auth_enabled` is true
  EOT
  type        = string
  default     = null
}

variable "administrator_password" {
  description = <<-EOT
    The administrator password for the mysql Flexible Server.
    Required when `create_mode` is Default and `authentication.password_auth_enabled` is true
  EOT
  type        = string
  default     = null
}

variable "backup_retention_days" {
  description = "The backup retention days for the mysql Flexible Server, between 7 and 35 days"
  type        = number
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  description = "Whether or not geo-redundant backups are enabled for this server"
  type        = bool
  default     = false
}

variable "zone" {
  description = "The zone of the mysql Flexible Server"
  type        = string
  default     = null

  validation {
    condition     = var.zone == null || can(regex("^[0-9]$", var.zone))
    error_message = "Invalid value for `zone`"
  }
}

variable "high_availability" {
  description = <<-EOT
    mode                      = The high availability mode. Possible values are SameZone or ZoneRedundant
    standby_availability_zone = The availability zone for the standby server
  EOT
  type = object({
    mode                      = string
    standby_availability_zone = optional(string)
  })
  default = null

  validation {
    condition     = var.high_availability == null || can(regex("^(SameZone|ZoneRedundant)$", var.high_availability.mode))
    error_message = "Invalid high_availability.mode value. Must be SameZone or ZoneRedundant"
  }
  validation {
    condition     = var.high_availability == null || can(regex("^[0-9]$", var.high_availability.standby_availability_zone))
    error_message = "Invalid value for standby_availability_zone"
  }
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned"
  type        = list(string)
  default     = null
}

variable "maintenance_window" {
  description = <<-EOT
    The maintenance window of the mysql Flexible Server
    day_of_week = The day of the week when maintenance should be performed
    start_hour   = The start hour of the maintenance window
    start_minute = The start minute of the maintenance window
  EOT
  type = object({
    day_of_week  = optional(string, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
  })
  default = {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }

  validation {
    condition     = var.maintenance_window.day_of_week >= 0 && var.maintenance_window.day_of_week <= 6
    error_message = "Invalid maintenance_window.day_of_week value"
  }
  validation {
    condition     = var.maintenance_window.start_hour >= 0 && var.maintenance_window.start_hour <= 23
    error_message = "maintenance_window.start_hour must be between 0 and 23"
  }
  validation {
    condition     = var.maintenance_window.start_minute >= 0 && var.maintenance_window.start_minute <= 59
    error_message = "maintenance_window.start_minute must be between 0 and 59"
  }
}

variable "source_server_id" {
  description = "The ID of the source mysql Flexible Server to restore from. Required when `create_mode` is GeoRestore, PointInTimeRestore, or Replica"
  type        = string
  default     = null
}

variable "storage" {
  type = object({
    io_scaling_enabled = optional(bool, null)
    iops               = optional(number)
    size_gb            = optional(number)
    auto_grow_enabled  = optional(bool, true)
  })

  default = {
    io_scaling_enabled = true
    iops               = null
    size_gb            = 20
    auto_grow_enabled  = true
  }

  validation {
    condition     = var.storage.size_gb >= 5 && var.storage.size_gb <= 16384
    error_message = "size_gb must be between 5 and 16384."
  }
  validation {
    condition     = var.storage.io_scaling_enabled ? var.storage.iops == null : true
    error_message = "iops must not be specified when io_scaling_enabled is true."
  }
  validation {
    condition     = var.storage.iops == null ? true : (var.storage.iops >= 360 && var.storage.iops <= 20000)
    error_message = "iops must be between 360 and 20000."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
