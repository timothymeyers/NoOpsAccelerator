# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "resource_group_name" {
  type        = string
  description = "Name of the azure resource group."
}

variable "location" {
  type        = string
  description = "Event Hub deployment region. Can be different vs. RG location"
  default     = ""
}

variable "eventhub_name" {
  type        = string
  description = "Name of the Event Hub."
  default     = ""
}

variable "namespace_name" {
  type        = string
  description = "Name of the Event Hub namespace."
  default     = ""
}

variable "partition_count" {
  type        = number
  description = "Number of partitions created for the Event Hub."
  default     = 2
}

variable "message_retention" {
  type        = number
  description = "Number of days to retain the events for this Event Hub."
  default     = 1
}

variable "environment" {
  type        = string
  description = "Name of the environment. Example dev, test, qa, cert, prod etc...."
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to the resources."
  default     = {}
}   