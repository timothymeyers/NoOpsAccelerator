#################################
# Global Configuration
#################################

variable "location" {
  description = "The region for spoke network deployment"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  type        = string
}

#################################
# Spoke Configuration
#################################

variable "spoke_vnetname" {
  description = "Virtual Network Name for the spoke network deployment"
  type        = string
}

variable "spoke_vnet_address_space" {
  description = "Address space prefixes for the spoke network"
  type        = list(string)
}

variable "spoke_subnets" {
  description = "A complex object that describes subnets for the spoke network"
  type = list(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = list(string)

    enforce_private_link_endpoint_network_policies = bool
    enforce_private_link_service_network_policies  = bool
  }))
}

variable "spoke_route_table_routes" {
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = string
  }))
  description = "The route tables routes with their properties."
}

variable "spoke_network_security_group_name" {
  description = "The name of the network security group"
  type        = string
}

variable "spoke_network_security_group_rules" {
  description = "A complex object that describes network security group rules for the spoke network"
  type = map(object({
    name                       = string
    priority                   = string
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = list(string)
    source_address_prefix      = list(string)
    destination_address_prefix = string
  }))
}

variable "spoke_route_table_name" {
  description = "The name of the route table"
  type        = string
}

variable "spoke_route_table_subnet_associations" {
  description = "A complex object that describes subnet associations for the spoke network"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

#################################
# Locks configuration section
#################################

variable "enable_resource_locks" {
  description = " Whether to enable resource locks on the resource group"
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "The level of lock to apply to the resource group"
  type        = string
  default     = "CanNotDelete"
}

#################################
# Logging Configuration
#################################

variable "spoke_log_storage_account_name" {
  description = "Storage Account name for the deployment"
  type        = string
  default     = ""
}

variable "spoke_logging_storage_account_config" {
  description = "Storage Account variables for the Spoke deployment"
  type = object({
    sku_name                 = string
    kind                     = string
    min_tls_version          = string
    account_replication_type = string
  })
  default = {
    sku_name                 = "Standard_LRS"
    kind                     = "StorageV2"
    min_tls_version          = "TLS1_2"
    account_replication_type = "LRS"
  }
}
