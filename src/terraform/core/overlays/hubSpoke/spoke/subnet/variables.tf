# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the subnet's resource group"
  type        = string
}

variable "name" {
  description = "Subnet Name for this subnet"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the subnet's virtual network"
  type        = string
}

variable "vnet_subnet_address_space" {
  description = "The CIDR Subnet Address Prefix for the this subnet. It must be in the workload Virtual Network space.'"
  type        = list(string)
}

variable "subnet_service_endpoints" {
  description = "The service endpoints to optimize for this subnet"
  type        = list(string)
}

variable "private_endpoint_network_policies_enabled" {
  description = "Enable or Disable network policies for the private endpoint on the subnet."
  type        = bool
}

variable "private_link_service_network_policies_enabled" {
  description = "Enable or Disable network policies for the private link service on the subnet."
  type        = bool
}

variable "network_security_group_name" {
  description = "The name of the subnet's virtual network"
  type        = string
}

variable "network_security_group_rules" {
  description = "A map of network security group rules to add to the network security group."
  type = map(object({
    name                       = string
    priority                   = string
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = list(string)
    source_address_prefix      = list(string)
    destination_address_prefix = string
  }))
  default = {}
}

variable "routetable_name" {
  description = "The name of the subnet's route table"
  type        = string
}

variable "firewall_private_ip_address" {
  description = "The IP Address of the Firewall"
  type        = string
}

#################################
# Locks configuration section
#################################

variable "enable_resource_locks" {
  description = " Whether to enable resource locks on the resource group"
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "The level of lock to apply to the resource group"
  type        = string
  default     = "CanNotDelete"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}