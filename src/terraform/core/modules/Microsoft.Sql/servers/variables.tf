
variable "server_name" {
  description = "The name of the SQL Server."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the SQL Server."
  type        = string
}

variable "location" {
  description = "The location/region where the SQL Server is created."
  type        = string
}

variable "sql_db_version" {
  description = "The version of the SQL Server. Possible values are 12.0, 12.0 - 2, 12.1, 13.0, 13.0 - 2, 13.0 - 3, 14.0."
  type        = string
  default     = "12.0"
}

variable "sql_db_login" {
  type        = string
  description = "The login name associated with the SQL Server."
  sensitive   = true
}

variable "sql_db_password" {
  description = "The password associated with the sql_db_login for the SQL Server."
  type        = string
  sensitive   = true
}

variable "minimum_tls_version" {
  description = "The minimum TLS version for the server. Possible values are 1.0, 1.1, 1.2."
  type        = string
  default     = "1.2"
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
