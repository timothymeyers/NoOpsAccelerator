# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "name" {
  description = "(Required) Specifies the name of the Automation Account. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}

variable "public_network_access_enabled" {
  description = "(Optional) Specifies whether or not public network access is allowed for the Automation Account. Defaults to true."
  type        = bool
}

variable "identity" {
  description = "(Optional) A `identity` block as defined below."
  type        = any
}

variable "tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}

variable "private_endpoints" {}
