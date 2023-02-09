# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "name" {
  description = "(Required) Specifies the name of the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the name of the resource group."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the location where the AKS cluster will be deployed."
  type        = string
}

variable "path_deploy_template" {
  description = "(Required) Specifies the path to the ARM template to deploy."
  type        = string
}
