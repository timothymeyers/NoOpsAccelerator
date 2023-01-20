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

variable "enable_resource_lock" {
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

variable "create_resource_group" {
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

variable "tables" {
  description = "List of tables to create"
  default     = []
  type        = list(string)
}