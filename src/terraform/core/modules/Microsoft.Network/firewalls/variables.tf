# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

############################
# Global Configuration    ##
############################

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

####################################
# Resource Locks Configuration    ##
####################################

variable "enable_resource_locks" {
  description = "(Optional) Enable resource locks"
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
  default     = "CanNotDelete"
}

##############################
# Firewall Configuration    ##
##############################

variable "public_ip_prefix_length" {
  description = "Specifies the number of bits of the prefix. The value can be set between 0 (4,294,967,296 addresses) and 31 (2 addresses)."
  default     = 31
}

variable "firewall_client_publicIP_address_name" {
  description = "The name of the public IP address to be used by the firewall client."
  type        = string
}

variable "firewall_management_publicIP_address_name" {
  description = "The name of the public IP address to be used by the firewall Management."
  type        = string
}

variable "firewall_config" {
  description = "Manages an Azure Firewall configuration"
  type = object({
    name              = string
    sku_name          = optional(string)
    sku_tier          = optional(string)
    dns_servers       = optional(list(string))
    private_ip_ranges = optional(list(string))
    threat_intel_mode = optional(string)
    zones             = optional(list(string))
  })
}

variable "enable_forced_tunneling" {
  description = "Route all Internet-bound traffic to a designated next hop instead of going directly to the Internet"
}

variable "client_subnet_id" {
  description = "The subnet id of the client subnet"
  type        = string 
}

variable "management_subnet_id" {
  description = "The subnet id of the client subnet"
  type        = string 
  default = null
}

variable "virtual_hub" {
  description = "An Azure Virtual WAN Hub with associated security and routing policies configured by Azure Firewall Manager. Use secured virtual hubs to easily create hub-and-spoke and transitive architectures with native security services for traffic governance and protection."
  type = object({
    virtual_hub_id  = string
    public_ip_count = number
  })
  default = null
}

variable "firewall_application_rules" {
  description = "Microsoft-managed virtual network that enables connectivity from other resources."
  type = list(object({
    name             = string
    description      = optional(string)
    action           = string
    source_addresses = optional(list(string))
    source_ip_groups = optional(list(string))
    fqdn_tags        = optional(list(string))
    target_fqdns     = optional(list(string))
    protocol = optional(object({
      type = string
      port = string
    }))
  }))
  default = []
}

variable "firewall_network_rules" {
  description = "List of network rules to apply to firewall."
  type = list(object({
    name                  = string
    description           = optional(string)
    action                = string
    source_addresses      = optional(list(string))
    destination_ports     = list(string)
    destination_addresses = optional(list(string))
    destination_fqdns     = optional(list(string))
    protocols             = list(string)
  }))
  default = []
}

variable "firewall_nat_rules" {
  description = "List of nat rules to apply to firewall."
  type = list(object({
    name                  = string
    description           = optional(string)
    action                = string
    source_addresses      = optional(list(string))
    destination_ports     = list(string)
    destination_addresses = list(string)
    protocols             = list(string)
    translated_address    = string
    translated_port       = string
  }))
  default = []
}

