#################################
# Global Configuration
#################################

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = ""
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

#################################
# Hub Configuration
#################################

variable "hub_virtual_network_name" {
  description = "The name of the Hub Virtual Network."
  type        = string
}

variable "hub_vnet_address_space" {
  description = "The CIDR Virtual Network Address Prefix for the Hub Virtual Network."
  type        = list(string)
}

variable "hub_subnets" {
  description = "A complex object that describes subnets for the Hub Virtual Network"
  type = list(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = list(string)

    enforce_private_link_endpoint_network_policies = bool
    enforce_private_link_service_network_policies  = bool
  }))
}

variable "hub_network_security_group_name" {
  description = "The name of the Network Security Group."
  type        = string
}

variable "hub_network_security_group_rules" {
  description = "A complex object that describes network security group rules for the hub network"
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

variable "hub_route_table_name" {
  description = "The name of the Route Table."
  type        = string
}

variable "hub_route_table_subnet_associations" {
  description = "A complex object that describes subnet associations for the hub network"
  type        = map(any)
  default     = {}
}

#################################
# Resource Lock Configuration
#################################

variable "enable_resource_locks" {
  description = "Flag to enable locks on the hub resources"
  type        = bool
  default     = true
}

variable "lock_level" {
  description = "The level of lock to apply to the resources. Valid values are CanNotDelete, ReadOnly, or NotSpecified."
  type        = string
  default     = "CanNotDelete"
}

#################################
# Logging Configuration
#################################

variable "hub_log_storage_account_name" {
  description = "Storage Account name for the deployment"
  type        = string
  default     = ""
}

variable "hub_logging_storage_account_config" {
  description = "Storage Account variables for the Hub deployment"
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

#################################
# Hub - Azure Firewall Configuration
#################################

variable "enable_firewall" {
  description = "Flag to enable Azure Firewall"
  type        = bool
}

variable "enable_forced_tunneling" {
  description = "Flag to enable forced tunneling on the Azure Firewall"
  type        = bool
  default     = false
}

variable "firewall_name" {
  description = "The name of the Azure Firewall."
  type        = string
}

variable "firewall_sku" {
  description = "The SKU of the Azure Firewall. Valid values are AZFW_Hub, AZFW_VNet, and AZFW_VNet_Hub."
  type        = string
}

variable "firewall_sku_tier" {
  description = "The SKU Tier of the Azure Firewall. Valid values are Standard and Premium."
  type        = string
}

variable "firewall_client_public_ip_address_name" {
  description = "The name of the Public IP Address for the Azure Firewall."
  type        = string
}

variable "firewall_client_subnet_address_prefix" {
  description = "The CIDR Address Prefix for the Azure Firewall Client Subnet."
  type        = string
}

variable "firewall_management_public_ip_address_name" {
  description = "The name of the Public IP Address for the Azure Firewall Management Interface."
  type        = string
}

variable "firewall_management_subnet_address_prefix" {
  description = "The CIDR Address Prefix for the Azure Firewall Management Subnet."
  type        = string
}

variable "firewall_policy_name" {
  description = "The name of the Azure Firewall Policy."
  type        = string
}

variable "firewall_policy_application_rule_collection" {
  description = "The SKU for Azure Firewall Public IP Address. It defaults to Standard."
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name = string
      protocols = list(object({
        port = number
        type = string
      }))
      source_addresses      = list(string)
      destination_fqdns     = list(string)
      destination_fqdn_tags = list(string)
      source_ip_groups      = list(string)
    }))
  }))
}

variable "firewall_policy_network_rule_collection" {
  description = "The SKU for Azure Firewall Public IP Address. It defaults to Standard."
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      description           = string
      destination_address   = string
      destination_addresses = list(string)
      destination_fqdns     = list(string)
      destination_ports     = list(string)
      destination_ip_groups = list(string)
      name                  = string
      protocols             = list(string)
      source_addresses      = list(string)
      source_ip_groups      = list(string)
      translated_address    = string
      translated_port       = string
    }))
  }))
}

variable "publicIP_address_diagnostics_logs" {
  description = "An array of Public IP Address Diagnostic Logs to enable for the Azure Firewall. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs for valid settings."
  type        = list(string)
  default     = []
}

variable "publicIP_address_diagnostics_metrics" {
  description = "An array of Public IP Address Diagnostic Metrics to enable for the Azure Firewall. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings."
  type        = list(string)
  default     = []
}

variable "firewall_threat_intel_mode" {
  description = "[Alert/Deny/Off] The Azure Firewall Threat Intelligence Rule triggered logging behavior. Valid values are 'Alert', 'Deny', or 'Off'. The default value is 'Alert'"
  type        = string
}

variable "firewall_threat_detection_mode" {
  description = "[Alert/Deny/Off] The Azure Firewall Intrusion Detection mode. Valid values are 'Alert', 'Deny', or 'Off'. The default value is 'Alert'"
  type        = string
}


variable "firewall_client_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Azure Firewall Client Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
}

variable "firewall_management_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Azure Firewall Management Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
}

variable "firewall_supernet_IP_address" {
  description = "Name of the firewall policy to apply to the hub firewall"
  type        = string
}

