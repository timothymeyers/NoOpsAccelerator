# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  type        = string
}

variable "public_ip_address_name" {
  description = "The name of the public IP address for the client"
  type        = string
}

variable "public_ip_address_allocation" {
  description = "The allocation method for the public IP address. Possible values are Static and Dynamic."
  type        = string
  default = "Static"
}

variable "public_ip_address_sku_name" {
  description = "The name of the SKU. Possible values are Basic, Regional and Standard."
  type        = string
  default = "Standard"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# With forced tunneling on, Configure Azure Firewall to never SNAT regardless of the destination IP address,
# use 0.0.0.0/0 as your private IP address range.
# With this configuration, Azure Firewall can never route traffic directly to the Internet.
# see: https://docs.microsoft.com/en-us/azure/firewall/snat-private-range
variable "disable_snat_ip_range" {
  description = "The address space to be used to ensure that SNAT is disabled."
  default     = ["0.0.0.0/0"]
  type        = list(any)
}

