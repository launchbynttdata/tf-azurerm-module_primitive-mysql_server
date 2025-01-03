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

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))

  default = {
    mysql_server = {
      name       = "mysql"
      max_length = 60
    }
    virtual_network = {
      name       = "vnet"
      max_length = 60
    }
    dns_vnet_link = {
      name       = "dnsvnet"
      max_length = 60
    }
    resource_group = {
      name       = "rg"
      max_length = 60
    }
    managed_identity = {
      name       = "mi"
      max_length = 60
    }
  }
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "Instance number should be between 0 to 999."
  }
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "Instance number should be between 0 to 100."
  }
}

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "launch"
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "database"
}

variable "class_env" {
  type        = string
  description = "(Required) Environment where resource is going to be deployed. For example. dev, qa, uat"
  nullable    = false
  default     = "dev"

  validation {
    condition     = length(regexall("\\b \\b", var.class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "location" {
  description = "Location of the mysql Flexible Server"
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "Address space of the example vnet"
  type        = string
  default     = "10.0.200.0/24"
}

variable "private_dns_zone_name" {
  description = "Suffix of the private dns zone name"
  type        = string
  default     = "launchdso.mysql.database.azure.com"
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

variable "administrator_login" {
  description = "The administrator login for the mysql Flexible Server."
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
  default = null
}

variable "source_server_id" {
  description = "The ID of the source mysql Flexible Server to restore from. Required when `create_mode` is GeoRestore, PointInTimeRestore, or Replica"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
