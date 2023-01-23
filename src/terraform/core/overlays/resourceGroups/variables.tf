# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "location" {
  description = "Azure region in which instance will be hosted"
  type        = string
}

variable "location_short" {
  description = "Azure region short name"
  type        = string
}

variable "environment" {
  description = "Name of the workload's environnement"
  type        = string
}

variable "workload_name" {
  description = "Name of the workload_name"
  type        = string
}

variable "org_name" {
  description = "Name of the organization"
  type        = string
}

