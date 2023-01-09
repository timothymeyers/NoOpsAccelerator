# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#################################
# Global Configuration
#################################

variable "required" {
  description = "A map of required variables for the deployment"  
}

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)  
}

variable "enable_services" {
  description = "Map of services you woul like to enable during a deployment."  
}

variable "environment" {
  description = "The Terraform backend environment e.g. public or usgovernment"
  type        = string
}

variable "metadata_host" {
  description = "The metadata host for the Azure Cloud e.g. management.azure.com or management.usgovcloudapi.net."
  type        = string
}

variable "location" {
  description = "The Azure region for most Platform LZ resources. e.g. for government usgovvirginia"
  type        = string
}

variable "disable_telemetry" {
  type        = bool
  description = "If set to true, will disable telemetry for the module. See https://aka.ms/noops-terraform-module-telemetry."
}

###################################
# Resource Locks
###################################

variable "enable_resource_locks" {
  description = "(Optional) Specifies if a lock should be applied to the Resources."
  type        = bool
  default     = true
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
  default     = "CanNotDelete"
}

#######################################
# Operations - Logging Configuration ##
#######################################

variable "logging_resource_group_name" {
  description = "Resource Group Name for the Logging deployment"
  type        = string
}

variable "logging_storage_account_name" {
  description = "Storage Account Name for the Logging deployment"
  type        = string
}

variable "logging_log_analytics_workspace_name" {
  description = "Log Analytics Workspace Name for the Logging deployment"
  type        = string
}

variable "logging_storage_account_config" {
  description = "Storage Account variables for the Spoke deployment"
  type = object({
    sku_name                 = string
    kind                     = string
    min_tls_version          = string
    account_replication_type = string
  })  
}

variable "logging_log_analytics_config" {
  description = "Log Analytics Workspace variables for the deployment"  
}

variable "enable_network_artifacts" {
  description = "Flag to enable network artifacts for the deployment"
  type        = bool
}

#################################
# Hub Configuration
#################################\

variable "hub_subid" {
  description = "Subscription ID for the Hub deployment"
  type        = string  

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.hub_subid)) || var.hub_subid == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "hub_resource_group_name" {
  description = "Resource Group Name for the Hub deployment"
  type        = string
}

variable "hub_virtual_network_name" {
  description = "Virtual Network Name for the Hub deployment"
  type        = string
}

variable "hub_vnet_address_space" {
  description = "The CIDR Virtual Network Address Prefix for the Hub Virtual Network."
  type        = list(string)
}

variable "hub_network_security_group_name" {
  description = "Network Security Group Name for the Hub deployment"
  type        = string
}

variable "hub_route_table_name" {
  description = "Route Table Name for the Hub deployment"
  type        = string
}

variable "hub_subnets" {
  description = "A complex object that describes subnets for the Operations network"
  type = map(object({
    name                 = string
    subnet_address_space = list(string)
    service_endpoints    = list(string)

    enforce_private_link_endpoint_network_policies = bool
    enforce_private_link_service_network_policies  = bool

    network_security_group_rules = map(object({
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

    enable_ddos_protection  = bool
    ddos_protection_plan_id = string
  }))  
}

variable "hub_log_storage_account_name" {
  description = "Storage Account Name for the Hub deployment"
  type        = string
}

variable "hub_logging_storage_account_config" {
  description = "Storage Account variables for the Hub deployment"
  type = object({
    sku_name                 = string
    kind                     = string
    min_tls_version          = string
    account_replication_type = string
  })  
}

#################################
# Azure Firewall Configuration
#################################

variable "enable_firewall" {
  description = "Flag to enable Azure Firewall"
  type        = bool
}

variable "enable_forced_tunneling" {
  description = "Flag to enable forced tunneling on the Azure Firewall"
  type        = bool
}

variable "firewall_name" {
  description = "Name of the Azure Firewall"
  type        = string
}

variable "firewall_policy_name" {
  description = "Name of the Azure Firewall Policy"
  type        = string
}

variable "firewall_sku_tier" {
  description = "[Standard/Premium] The SKU for Azure Firewall. It defaults to Premium."
  type        = string
}

variable "firewall_sku_name" {
  description = "SKU name of the Firewall. Possible values are AZFW_Hub and AZFW_VNet."
  type        = string
}

variable "firewall_threat_intel_mode" {
  description = "[Alert/Deny/Off] The Azure Firewall Threat Intelligence Rule triggered logging behavior. Valid values are 'Alert', 'Deny', or 'Off'. The default value is 'Alert'"
  type        = string
}

variable "firewall_threat_detection_mode" {
  description = "[Alert/Deny/Off] The Azure Firewall Intrusion Detection mode. Valid values are 'Alert', 'Deny', or 'Off'. The default value is 'Alert'"
  type        = string
}

variable "firewall_client_subnet_address_prefix" {
  description = "The CIDR Address Prefix for the Azure Firewall Client Subnet."
  type        = string
}

variable "firewall_client_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Azure Firewall Client Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = []
}

variable "firewall_client_public_ip_address_name" {
  description = "The name of the Public IP Address for the Azure Firewall Client Subnet."
  type        = string
}

variable "firewall_client_publicIP_address_availability_zones" {
  description = "An array of Azure Firewall Public IP Address Availability Zones. It defaults to empty, or 'No-Zone', because Availability Zones are not available in every cloud. See https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku for valid settings."
  type        = list(string)
  default     = []
}

 
variable "firewall_management_subnet_address_prefix" {
  description = "The CIDR Address Prefix for the Azure Firewall Management Subnet."
  type        = string
  default     = "10.0.100.64/26"
}

variable "firewall_management_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Azure Firewall Management Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = []
}

variable "firewall_management_public_ip_address_name" {
  description = "The name of the Public IP Address for the Azure Firewall Management Subnet."
  type        = string
  default     = "pip-fw-management"
}

variable "firewall_management_publicIP_address_availability_zones" {
  description = "An array of Azure Firewall Public IP Address Availability Zones. It defaults to empty, or 'No-Zone', because Availability Zones are not available in every cloud. See https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku for valid settings."
  type        = list(string)
  default     = []
}

variable "firewall_supernet_IP_address" {
  description = "The IP address range that is used to allow traffic from the Azure Firewall to the Internet. It must be in the Hub Virtual Network space. It must be /19."
  type        = string
}

#################################
# Spokes Configuration
#################################

#################################
# Operarions Configuration
#################################

variable "ops_subid" {
  description = "Subscription ID for the Operations Virtual Network deployment"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.ops_subid)) || var.ops_subid == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "ops_resource_group_name" {
  description = "Resource Group name for the Hub Virtual Network deployment"
  type        = string  
}

variable "ops_virtual_network_name" {
  description = "Virtual Network name for the Operations Virtual Network deployment"
  type        = string
}

variable "ops_network_security_group_name" { 
  description = "Network Security Group name for the Operations Virtual Network deployment"
  type        = string 
}

variable "ops_route_table_name" { 
  description = "Route Table name for the Operations Virtual Network deployment"
  type        = string
}

variable "ops_spoke_vnet_address_space" {
  description = "Address space prefixes for the Operations Virtual Network"
  type        = list(string)
}

variable "ops_spoke_subnets" {
  description = "A complex object that describes subnets for the Operations Virtual Network"
  type = map(object({
    subnet_name          = string
    subnet_address_space = list(string)
    service_endpoints    = list(string)

    enforce_private_link_endpoint_network_policies = bool
    enforce_private_link_service_network_policies  = bool

    network_security_group_rules = map(object({
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
    enable_ddos_protection  = bool
    ddos_protection_plan_id = string
  }))  
}

variable "ops_log_storage_account_name" { 
  description = "Storage Account name for the Operations Virtual Network deployment"
  type        = string  
}

variable "ops_logging_storage_account_config" {
  description = "Storage Account variables for the Operations Virtual Network deployment"
  type = object({
    sku_name                 = string
    kind                     = string
    min_tls_version          = string
    account_replication_type = string
  })  
}

#################################
# Shared Services Configuration
#################################

variable "svcs_subid" {
  description = "Subscription ID for the Shared Services Virtual Network deployment"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.svcs_subid)) || var.svcs_subid == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "svcs_resource_group_name" {
  description = "Resource Group name for the Shared Services Virtual Network deployment"
  type        = string  
}

variable "svcs_virtual_network_name" {
  description = "Virtual Network name for the Shared Services Virtual Network deployment"
  type        = string
}

variable "svcs_network_security_group_name" { 
  description = "Network Security Group name for the Shared Services Virtual Network deployment"
  type        = string  
}

variable "svcs_route_table_name" { 
  description = "Route Table name for the Shared Services Virtual Network deployment"
  type        = string 
}


variable "svcs_spoke_vnet_address_space" {
  description = "Address space prefixes for the Shared Services Virtual Network"
  type        = list(string)
}

variable "svcs_spoke_subnets" {
  description = "A complex object that describes subnets for the Shared Services Virtual Network"
  type = map(object({
    subnet_name          = string
    subnet_address_space = list(string)
    service_endpoints    = list(string)

    enforce_private_link_endpoint_network_policies = bool
    enforce_private_link_service_network_policies  = bool

    network_security_group_rules = map(object({
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

    enable_ddos_protection  = bool
    ddos_protection_plan_id = string

  }))  
}

variable "svcs_log_storage_account_name" { 
  description = "Storage Account name for the Operations Virtual Network deployment"
  type        = string
}

variable "svcs_logging_storage_account_config" {
  description = "Storage Account variables for the Shared Services Virtual Network deployment"
  type = object({
    sku_name                 = string
    kind                     = string
    min_tls_version          = string
    account_replication_type = string
  })  
}


##################################
# Network Peering Configuration ##
##################################

variable "peer_to_hub_virtual_network" {
  description = "A boolean value to indicate if the Virtual Network should peer to the hub Virtual Network."
  type        = bool
  default     = true
}

variable "allow_virtual_network_access" {
  description = "Allow access from the remote virtual network to use this virtual network's gateways. Defaults to false."
  type        = bool
  default     = true
}

variable "use_remote_gateways" {
  description = "Use remote gateways from the remote virtual network. Defaults to false."
  type        = bool
  default     = false
}

#################################
# Bastion Host Configuration
#################################

variable "bastion_address_space" {
  description = "The address space to be used for the Bastion Host subnet (must be /27 or larger)."
  type        = string
}

variable "bastion_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Bastion Host Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = []
}

#################################
# Jumpbox VM Configuration    ###
#################################

variable "jumpbox_admin_username" {
  description = "The username of the Jumpbox VM admin account"
  type        = string
}

variable "use_random_password" {
  description = "Set this to true to use a random password for the VMs. If set to false, the password will be stored in the terraform state file."
  type        = bool
}

variable "size_jumpbox" {
  description = "The size of the Jumpbox VM"
  type        = string
}

#######################################
# Jumpbox Linux VM Configuration    ###
#######################################

variable "jumpbox_linux_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"  
}

#########################################
# Jumpbox Windows VM Configuration    ###
#########################################

variable "jumpbox_windows_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
}
