# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "vnet_1_name" {
  description = "Specifies the name of the first virtual network"
  type        = string
}

variable "vnet_1_id" {
  description = "Specifies the resource id of the first virtual network"
  type        = string
}

variable "vnet_1_rg" {
  description = "Specifies the resource group name of the first virtual network"
  type        = string
}

variable "vnet_2_name" {
  description = "Specifies the name of the second virtual network"
  type        = string
}

variable "vnet_2_id" {
  description = "Specifies the resource id of the second virtual network"
  type        = string
}

variable "vnet_2_rg" {
  description = "Specifies the resource group name of the second virtual network"
  type        = string
}

variable "peering_name_1_to_2" {
  description = "(Optional) Specifies the name of the first to second virtual network peering"
  type        = string
  default     = "peering1to2"
}

variable "peering_name_2_to_1" {
  description = "(Optional) Specifies the name of the second to first virtual network peering"
  type        = string
  default     = "peering2to1"
}

variable "allow_virtual_network_access" {
  description = "(Optional) Allow access from the remote virtual network to use this virtual network's gateways. Defaults to false."
  type        = bool
  default = true
}

variable "allow_forwarded_traffic" {
  description = "(Optional) Allow forwarded traffic from the remote virtual network. Defaults to false."
  type        = bool
  default = true
}

variable "allow_gateway_transit" {
  description = "(Optional) Allow gateway transit from the remote virtual network. Defaults to false."
  type        = bool
  default = false
}

variable "use_remote_gateways" {
  description = "(Optional) Use remote gateways from the remote virtual network. Defaults to false."
  type        = bool
  default = false
}



