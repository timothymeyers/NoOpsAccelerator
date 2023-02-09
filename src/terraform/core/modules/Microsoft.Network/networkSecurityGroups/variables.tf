# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "name" {
  description = "The name of the nsg"
  type        = string
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the subnet's resource group"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "inbound_rules" {
  type = map(object({
    name                       = string
    priority                   = string
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_ranges    = list(string)
    source_address_prefixes    = list(string)
    destination_address_prefix = string
  }))
  default     = {}
  description = "List of objects that represent the configuration of each inbound rule."
  # inbound_rules = [
  #   {
  #     name                       = ""
  #     priority                   = ""
  #     access                     = ""
  #     protocol                   = ""
  #     source_address_prefix      = ""
  #     source_port_range          = ""
  #     destination_address_prefix = ""
  #     destination_port_range     = ""
  #     description                = ""
  #   }
  # ]
}

variable "outbound_rules" {
  type = map(object({
    name                       = string
    priority                   = string
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_ranges    = list(string)
    source_address_prefixes    = list(string)
    destination_address_prefix = string
  }))
  default     = {}
  description = "List of objects that represent the configuration of each outbound rule."
  # outbound_rules = [
  #   {
  #     name                       = ""
  #     priority                   = ""
  #     access                     = ""
  #     protocol                   = ""
  #     source_address_prefix      = ""
  #     source_port_range          = ""
  #     destination_address_prefix = ""
  #     destination_port_range     = ""
  #     description                = ""
  #   }
  # ]
}


variable "enable_resource_locks" {
  description = "Enable resource locks"
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
  default     = "CanNotDelete"
}

variable "enable_diagnostic_settings" {
  description = "Create a bastion host and jumpbox VM?"
  type        = bool
  default     = false
}

variable "nsg_log_categories" {
  description = "List of Diagnostic Log Categories"
  type        = list(string)
  default     = []
}

variable "nsg_metric_categories" {
  description = "List of Diagnostic Metric Categories"
  type        = list(string)
  default     = []
}

variable "log_analytics_storage_id" {
  description = "The id of the storage account that stores log analytics diagnostic logs"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "The id of the log analytics workspace"
  type        = string
  default     = ""
}

variable "flow_log_retention_in_days" {
  description = "The number of days to retain flow log data"
  default     = "7"
  type        = number
}
