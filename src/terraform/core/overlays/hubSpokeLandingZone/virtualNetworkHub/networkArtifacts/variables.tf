#################################
# Global Configuration
#################################

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)
  default = {
    "DeploymentType" : "AzureNoOpsTF"
  }
}

variable "custom_resource_group_name" {
  description = "The name of the resource group to create. If not set, the name will be generated using the 'name_prefix' and 'name_suffix' variables. If set, the 'name_prefix' and 'name_suffix' variables will be ignored."
  type        = string
  default     = ""
}

variable "resource_group_name" {
    description = "The name of the resource group."
    type = string
}

variable "location" {
  description = "A name for the organization. It defaults to anoa."
  type        = string
}

variable "enable_network_artifacts" {
  description = "Enable network artifacts deployment"
  type        = bool
  default     = false
}

########################################
# Network Artifacts Configuration    ###
########################################

variable "tenant_id" {
  description = "The tenant ID of the keyvault to store jumpbox credentials in"
  type        = string
}

variable "object_id" {
  description = "The object ID with access the keyvault to store and retrieve jumpbox credentials"
  type        = string
}

variable "vnet_subnet_id" {
  description = "(Optional) Specifies the subnet id of the virtual network to which create a virtual network link for private dns zone"
  type        = string
  default     = ""
}

variable "netart_log_storage_account_name" {
  description = "The name of the storage account to store the logs in"
  type        = string
  default     = ""
}

variable "netart_storage_account" {
  description = "Storage account configuration object"
  type = object({
    sku_name = string
    kind     = string
  })
  default = {
    sku_name = "Standard_LRS"
    kind     = "StorageV2"
  }
}

variable "netart_key_vault_name" {
   description = "The name of the key vault to store the jumpbox credentials in"
  type        = string
  default     = ""
}

variable "sku_name" {
  description = "The name of the SKU used for this key vault. Possible values are standard and premium."
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "The number of days that soft-deleted keys should be retained. Must be between 7 and 90."
  type        = number
  default     = 90
}

variable "purge_protection_enabled" {
  description = "Enable purge protection on this key vault"
  type        = bool
  default     = false
}

variable "enable_access_policy" {
  description = "Enable access policy on this key vault"
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "Enable deployment on this key vault"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Enable disk encryption on this key vault"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Enable template deployment on this key vault"
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization on this key vault"
  type        = bool
  default     = false
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

##############################
# Logging Configuration    ###
##############################

variable "log_analytics_workspace_id" {
  description = "The name of the log analytics workspace"
  type        = string
  default     = ""
}

