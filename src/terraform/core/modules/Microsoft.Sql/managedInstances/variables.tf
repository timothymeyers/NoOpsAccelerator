# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "sql_db_name" {
  type        = string
  description = "The name to assign to the new Database."
}

variable "sql_server_id" {
  type        = string
  description = "The ID of the Azure SQL Server where the database will be created."
}

variable "db_max_size_gb" {
  type        = number
  description = "description"
  default     = "10"
}

variable "sku_name" {
  type        = string
  description = "Specifies the name of the SKU used by the database. For example, GP_S_Gen5_2, Basic, HS_Gen4_1. Changing this from the HyperScale service tier to another service tier will force a new resource to be created."
  default     = "S1"

  validation {
    condition     = var.sku_name == "S1" || var.sku_name == "S2" || var.sku_name == "P1" || var.sku_name == "P2" || var.sku_name == "GP_S_Gen5_2" || var.sku_name == "GP_S_Gen5_4" || var.sku_name == "BC_Gen5_2" || var.sku_name == "BC_Gen5_4"
    error_message = "The input parameter 'sku_name' can be either `S1`, `S2`, `P1`, `P2`. `GP_S_Gen5_2`, `GP_S_Gen5_4`, `BC_Gen5_2`, `BC_Gen5_4`."
  }
}

variable "zone_redundant" {
  type        = bool
  description = "Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones."
  default     = false
}

variable "read_scale" {
  type        = string
  description = "If enabled, connections that have application intent set to readonly in their connection string may be routed to a readonly secondary replica. This property is only settable for Premium and Business Critical databases."
  default     = null
}

variable "storage_account_type" {
  type        = string
  description = ""
  default     = "Geo"
  validation {
    condition     = var.storage_account_type == "Geo" || var.storage_account_type == "Zone" || var.storage_account_type == "Local"
    error_message = "The value of input variable 'storage_account_type must be either 'Geo', 'Zone' or 'Local'."
  }
}

variable "enable_resource_lock" {
  description = "Enable resource locks"
  type        = bool
  default = false
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
  default = "CanNotDelete"
}

variable "tags" {
  type        = map(any)
  description = "description"
  default     = {}
}
