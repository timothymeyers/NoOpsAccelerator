# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "resource_group_name" {
  description = "The name of the subnet's resource group"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the subnet's virtual network"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "address_prefixes" {
  description = "The address prefix to use for the subnet"
  type        = list(string)
  default     = []
}

variable "service_endpoints" {
  description = "A list of service endpoints to enable on the subnet"
  type        = list(string)
  default     = []
}

variable "delegations" {
  description = "A list of delegations to apply to the subnet"
  type = list(object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
  default = []
}

variable "private_endpoint_network_policies_enabled" {
  description = "Specifies whether network policies are enabled on the subnet"
  type        = string
}

variable "private_link_service_network_policies_enabled" {
  description = "Specifies whether network policies are enabled on the subnet"
  type        = string
}
