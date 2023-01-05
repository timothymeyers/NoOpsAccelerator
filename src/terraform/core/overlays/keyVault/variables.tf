# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "resource_group_name" {
  description = "The name of the resource group the jumpbox resides in"
  type        = string
}

variable "location" {
  description = "The region to deploy the jumpbox resides into"
  type        = string
}

variable "key_vault_name" {
  description = "Specifies the name of the key vault."
  type        = string
  default     = ""
}

variable "key_vault_sku_name" {
  description = "(Required) The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  type        = string
  default     = "standard"

  validation {
    condition = contains(["standard", "premium" ], var.key_vault_sku_name)
    error_message = "The sku name of the key vault is invalid."
  }
}

variable"key_vault_enabled_for_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false."
  type        = bool
  default     = true
}

variable"key_vault_enabled_for_disk_encryption" {
  description = " (Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to false."
  type        = bool
  default     = true
}

variable"key_vault_enabled_for_template_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Defaults to false."
  type        = bool
  default     = true
}

variable"key_vault_enable_rbac_authorization" {
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. Defaults to false."
  type        = bool
  default     = true
}

variable"key_vault_purge_protection_enabled" {
  description = "(Optional) Is Purge Protection enabled for this Key Vault? Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
  type        = number
  default     = 30
}

variable "key_vault_bypass" {
  description = "(Required) Specifies which traffic can bypass the network rules. Possible values are AzureServices and None."
  type        = string
  default     = "AzureServices"

  validation {
    condition = contains(["AzureServices", "None" ], var.key_vault_bypass)
    error_message = "The valut of the bypass property of the key vault is invalid."
  }
}

variable "key_vault_default_action" {
  description = "(Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny."
  type        = string
  default     = "Allow"

  validation {
    condition = contains(["Allow", "Deny" ], var.key_vault_default_action)
    error_message = "The value of the default action property of the key vault is invalid."
  }
}

variable "vnet_subnet_id" {
  description = "(Optional) Specifies the subnet id of the virtual network to which create a virtual network link for private dns zone"
  type        = string
  default     = ""
}

variable "virtual_networks_to_link" {
  description = "(Optional) Specifies the subscription id, resource group name, and name of the virtual networks to which create a virtual network link for private dns zone"
  type        = map(any)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "(Required) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent."
   type        = string
}

variable "log_analytics_retention_days" {
  description = "(Optional) Specifies the number of days that logs should be kept for; a value of 0 will retain data indefinitely."
  type        = string
  default     = "30"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
  type        = map(string)
}
