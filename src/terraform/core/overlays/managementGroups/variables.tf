# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "root_id" {
  type        = string
  description = "If specified, will set a custom Name (ID) value for the \"root\" Management Group"
  default     = "im"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{2,10}$", var.root_id))
    error_message = "Value must be between 2 to 10 characters long, consisting of alphanumeric characters and hyphens."
  }
}

variable "root_display_name" {
  type        = string
  description = "If specified, will set a custom Display Name value for the \"root\" Management Group."
  default     = "im-root"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9- ._]{1,22}[A-Za-z0-9]?$", var.root_display_name))
    error_message = "Value must be between 2 to 24 characters long, start with a letter, end with a letter or number, and can only contain space, hyphen, underscore or period characters."
  }
}

variable "management_groups" {
  type = map(object({
    management_group_name      = string
    display_name               = string
    parent_management_group_id = string
    subscription_ids           = list(string)
  }))
  description = "The list of management groups to be created."
  default = {
    "root" = {
      display_name               = "anoa"
      management_group_name      = "anoa"
      parent_management_group_id = "value"
      subscription_ids           = []
    }
  }
}

variable "tags" {
  type        = map(string)
  description = "The tags of the management group."
  default     = {}
}
