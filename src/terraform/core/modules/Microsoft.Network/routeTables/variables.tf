# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "resource_group_name" {
  description = "Resource group where RouteTable will be deployed"
  type        = string
}

variable "location" {
  description = "Location where RouteTable will be deployed"
  type        = string
}

variable "route_table_name" {
  description = "RouteTable name"
  type        = string
}

variable "disable_bgp_route_propagation" {
  description = "Specifies whether to disable the routes learned by BGP on that route table. Default is false"
  type        = bool
  default     = false
}

variable "subnets_to_associate" {
  description = "(Optional) Specifies the subscription id, resource group name, and name of the subnets to associate"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "(Required) Map of tags to be applied to the resource"
  type        = map(any)
}
variable "enable_resource_locks" {
  description = "Enable resource locks"
  type        = bool
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
}