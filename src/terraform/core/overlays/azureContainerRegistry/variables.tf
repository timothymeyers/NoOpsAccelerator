
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "acr_name" {
  description = "(Required) Specifies the name of the Container Registry. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Container Registry. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "enable_diagnostic_setting" {
  type        = bool
  description = "Boolean flag to specify whether the logs should be sent to Log Analytics Workspace."
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "(Required) Specifies the log analytics workspace id"
  type        = string
}

variable "vnet_subnet_id" {
  description = "(Optional) Specifies the subnet id of the virtual network to which create a virtual network link for private dns zone"
  type        = string
}

variable "log_analytics_retention_days" {
  description = "(Optional) Specifies the number of days of the retention policy. Possible values are 0-365. 0 means Unlimited retention for the Unlimited Sku. 30 days is the default for all other Skus."
  type        = string
  default     = "30"
}

variable "acr_sku" {
  description = "(Optional) The SKU name of the container registry. Possible values are Basic, Standard and Premium. Defaults to Standard"
  type        = string
  default     = "Standard"
}

variable "acr_admin_enabled" {
  description = "(Optional) Specifies whether the admin user is enabled. Defaults to false."
  type        = bool
  default     = false
}

variable "virtual_networks_to_link" {
  description = "(Optional) Specifies the subscription id, resource group name, and name of the virtual networks to which create a virtual network link for private dns zone"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(any)
  default     = {}
}
