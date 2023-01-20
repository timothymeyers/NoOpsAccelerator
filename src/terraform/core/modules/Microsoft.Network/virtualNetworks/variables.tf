# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution" 
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
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

####################################
# Virtual Network Configuration   ##
####################################

variable "vnetwork_name" {
  description = "Name of your Azure Virtual Network"
}

variable "vnet_address_space" {
  description = "The address space to be used for the Azure virtual network."
}

variable "create_ddos_plan" {
  description = "Create an ddos plan - Default is false"
  default     = false
}

variable "ddos_plan_name" {
  description = "The name of AzureNetwork DDoS Protection Plan"
}

variable "dns_servers" {
  description = "List of dns servers to use for virtual network"
  default     = []
}

variable "create_network_watcher" {
  description = "Controls if Network Watcher resources should be created for the Azure subscription"
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}