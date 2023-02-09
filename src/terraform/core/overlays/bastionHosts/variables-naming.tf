# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "name_prefix" {
  description = "Optional prefix for the generated name"
  type        = string
  default     = ""
}

variable "name_suffix" {
  description = "Optional suffix for the generated name"
  type        = string
  default     = ""
}

variable "use_naming" {
  description = "Use the Azure CAF naming provider to generate default resource name. `custom_rg_name` override this if set. Legacy default name is used if this is set to `false`."
  type        = bool
  default     = true
}

# Bastion naming

variable "custom_bastion_name" {
  description = "Custom Bastion name, generated if not set"
  type        = string
  default     = null
}

variable "custom_public_ip_name" {
  description = "Bastion IP Config resource custom name"
  type        = string
  default     = null
}

variable "custom_ipconfig_name" {
  description = "Bastion IP Config custom name"
  type        = string
  default     = ""
}
