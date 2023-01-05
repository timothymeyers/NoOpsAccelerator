# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable name {
    type        = string
    description = "The name of the Redis Cache. The Name used for Redis needs to be globally unique"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Redis Cache"
}

variable "location" {
  type        = string
  description = "The Azure Region in which to create the Redis Cache."
}

variable sku_name {
    type = string
    default = "Premium" 
}
variable family {
    type = string
    default = "P"
}
variable capacity {
    type = number
    default = 1
}

variable minimum_tls_version {
    type = number 
    default = 1.2
}

variable enable_non_ssl_port {
    type = bool
    default  = true
}