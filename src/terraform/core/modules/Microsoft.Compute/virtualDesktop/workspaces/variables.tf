# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "name" {
  description = "(Required) Specifies the name of the Virtual Desktop Workspace. Changing this forces a new resource to be created.  "
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

variable "friendly_name" {
  description = "(Optional) The friendly name of the Virtual Desktop Workspace."
  type        = string
}

variable "description" {
  description = "(Optional) The description of the Virtual Desktop Workspace."
  type        = string
}

variable "tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}

