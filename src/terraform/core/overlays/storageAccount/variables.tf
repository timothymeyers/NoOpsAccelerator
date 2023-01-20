# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

###################################
# Global Configuration   ##
###################################

variable "resource_group_name" {
  description = "The name of the resource group the Bastion Host resides in"
  type        = string
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
  type        = map(string)
}

####################################
# Resource Locks Configuration    ##
####################################

variable "enable_resource_locks" {
  description = "(Optional) Enable resource locks"
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
  default     = "CanNotDelete"
}

#############################
# Storage Configuration    ##
#############################

variable "create_storage_account_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = false
  type        = bool
}

variable "storage_account_name" {
  description = "The name of the azure storage account"
  default     = ""
  type        = string
}

variable "enable_advanced_threat_protection" {
  description = "Enable advanced threat protection"
  default     = false
  type        = bool
}

variable "account_kind" {
  description = "Specifies the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created."
  default     = null
  type        = string
}

variable "sku_name" {
  description = "The name of the SKU used for this storage account. Valid options are Standard_LRS, Standard_GRS, Standard_RAGRS, Standard_ZRS, Premium_LRS, Premium_ZRS, Standard_GZRS, Standard_RAGZRS, and BlobStorage. Changing this forces a new resource to be created."
  default     = null
  type        = string
}
