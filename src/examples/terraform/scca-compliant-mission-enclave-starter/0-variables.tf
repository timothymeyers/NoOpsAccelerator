# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
  PARAMETERS
  Here are all the variables a user can override.
*/

#################################
# Global Configuration
#################################

variable "required" {
  description = "A map of required variables for the deployment"
  default = {
    org_prefix         = "anoa"
    deploy_environment = "dev"
  }
}

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)
  default = {
    "Organization" : "anoa",
    "Region" : "usgovvirginia",
    "DeployEnvironment" : "dev"
  }
}

variable "enable_services" {
  description = "Map of services you woul like to enable during a deployment."
  default = {
    // Enable Identity services
    deploy_custom_roles = true // true to deploy custom roles

    // Enable Bastion services
    enable_bastion_hosts             = true // true to create a bastion host
    bastion_linux_virtual_machines   = true // true to create a linux bastion host
    bastion_windows_virtual_machines = true // true to create a windows bastion host

    // Enable Network services
    enable_network_diagnostics = true  // true to create a diagnostics settings for the network
    enable_bastion_diagnostics = false // true to create a diagnostics settings for the bastion host
    enable_network_artifacts   = false // true to create a network artifacts for operations
    enable_resource_locks      = false // true to enable resource locks
    enable_firewall            = true  // true to create the Azure Firewall
    enable_forced_tunneling    = true  // true to enable forced tunneling
    enable_vpn_gateway         = true  // true to create the Azure VPN Gateway

    // Enable Security services
    enable_azure_security_center   = false // true to deploy Azure Security Center
    enable_security_center_setting = false // true to enable the Azure Security Center Setting    

    // Enable Monitoring services    
    deploy_laws_solutions = true // true to deploy Azure Monitor Solutions
    deploy_sentinel       = true // true to deploy Azure Sentinel  
  }
}

variable "environment" {
  description = "The Terraform backend environment e.g. public or usgovernment"
  type        = string
  default     = "public"
}

variable "metadata_host" {
  description = "The metadata host for the Azure Cloud e.g. management.azure.com or management.usgovcloudapi.net."
  type        = string
  default     = "management.azure.com"
}

variable "location" {
  description = "List of Azure regions into which stamps are deployed. Important: The first location in this list will be used as the main location for this deployment."
  type        = string
  default     = "eastus"
}

variable "root_management_group_id" {
  description = "The ID for the root management group."
  type        = string
  default     = "anoa"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_\\(\\)\\.]{1,36}$", var.root_management_group_id))
    error_message = "Value must be a valid Management Group ID, consisting of alphanumeric characters, hyphens, underscores, periods and parentheses."
  }
}

variable "root_management_group_display_name" {
  description = "The display name for the root management group."
  type        = string
  default     = "anoa-root"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_\\(\\)\\.]{1,36}$", var.root_management_group_display_name))
    error_message = "Value must be a valid Management Group ID, consisting of alphanumeric characters, hyphens, underscores, periods and parentheses."
  }
}

variable "disable_telemetry" {
  type        = bool
  description = "If set to true, will disable telemetry for the module. See https://aka.ms/alz-terraform-module-telemetry."
  default     = false
}

#################################
# Resource Lock Configuration
#################################

variable "lock_level" {
  description = "The level of lock to apply to the resources. Valid values are CanNotDelete, ReadOnly, or NotSpecified."
  type        = string
  default     = "CanNotDelete"
}

###################################
# Managment Group Configuration  ##
###################################

variable "management_groups" {
  type = map(object({
    management_group_name      = string
    display_name               = string
    parent_management_group_id = string
    subscription_ids           = list(string)
  }))
  description = "The list of management groups to be created under the root."
  default = {
    "platforms" = {
      display_name               = "platforms"
      management_group_name      = "platforms"
      parent_management_group_id = "anoa"
      subscription_ids           = []
    },
    "workloads" = {
      display_name               = "workloads"
      management_group_name      = "workloads"
      parent_management_group_id = "anoa"
      subscription_ids           = []
    },
    "sandbox" = {
      display_name               = "sandbox"
      management_group_name      = "sandbox"
      parent_management_group_id = "anoa"
      subscription_ids           = []
    },
    "identity" = {
      display_name               = "identity"
      management_group_name      = "identity"
      parent_management_group_id = "platforms"
      subscription_ids           = []
    },
    "transport" = {
      display_name               = "transport"
      management_group_name      = "transport"
      parent_management_group_id = "platforms"
      subscription_ids           = ["<<subscriptionId>>"]
    },
    "management" = {
      display_name               = "management"
      management_group_name      = "management"
      parent_management_group_id = "platforms"
      subscription_ids           = []
    },
    "internal" = {
      display_name               = "internal"
      management_group_name      = "internal"
      parent_management_group_id = "workloads"
      subscription_ids           = []
    },
    "partners" = {
      display_name               = "partners"
      management_group_name      = "partners"
      parent_management_group_id = "workloads"
      subscription_ids           = []
    }
  }
}

###################################
# Service Alerts Configuration  ##
###################################

variable "contact_email" {
  description = "Email address for alert notifications"
  type        = string
  default     = ""
}

#################################
# Logging Configuration
#################################

variable "log_analytics_config" {
  description = "Log Analytics Workspace variables for the deployment"
  default = {
    sku               = "PerGB2018"
    retention_in_days = 30
    daily_quota_gb    = -1
  }
}

#################################
# Hub Configuration
#################################

variable "hub_subscription_id" {
  description = "Subscription ID for the Hub deployment"
  type        = string
  default     = "<<subscriptionId>>"

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.hub_subscription_id)) || var.hub_subscription_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "hub_vnet_address_space" {
  description = "The CIDR Virtual Network Address Prefix for the Hub Virtual Network."
  type        = list(string)
  default     = ["10.0.100.0/24"]
}

variable "hub_vnet_subnet_address_prefixes" {
  description = "The CIDR Address Prefixes for the Subnets in the Hub Virtual Network."
  type        = list(string)
  default     = ["10.0.100.128/27"]
}

variable "hub_vnet_subnet_service_endpoints" {
  description = "The CIDR Address Prefixes for the Subnets in the Hub Virtual Network."
  type        = list(string)
  default = [
    "Microsoft.KeyVault",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}

variable "hub_network_security_group_inbound_rules" {
  description = "A complex object that describes network security group rules for the Workload Virtual Network"
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
  default = {}
}

variable "hub_storage_account_config" {
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

####################################
# Network Artifacts Configuration ##
####################################

variable "enable_network_artifacts" {
  description = "Flag to enable network artifacts for the deployment"
  type        = bool
  default     = false
}

variable "enable_network_artifacts_diagnostics" {
  description = "Flag to enable diagnostics for the network artifacts"
  type        = bool
  default     = false
}

variable "network_artifacts_storage_account" {
  description = "Storage account configuration object"
  type = object({
    sku_name = string
    kind     = string
  })
  default = {
    sku_name = "Standard_LRS"
    kind     = "StorageV2"
  }
}

variable "kv_sku_name" {
  description = "The name of the SKU used for this key vault. Possible values are standard and premium."
  type        = string
  default     = "standard"
}

variable "kv_soft_delete_retention_days" {
  description = "The number of days that soft-deleted keys should be retained. Must be between 7 and 90."
  type        = number
  default     = 90
}

variable "kv_purge_protection_enabled" {
  description = "Enable purge protection on this key vault"
  type        = bool
  default     = false
}

variable "kv_enable_access_policy" {
  description = "Enable access policy on this key vault"
  type        = bool
  default     = false
}

variable "kv_enabled_for_deployment" {
  description = "Enable deployment on this key vault"
  type        = bool
  default     = false
}

variable "kv_enabled_for_disk_encryption" {
  description = "Enable disk encryption on this key vault"
  type        = bool
  default     = false
}

variable "kv_enabled_for_template_deployment" {
  description = "Enable template deployment on this key vault"
  type        = bool
  default     = false
}

variable "kv_enable_rbac_authorization" {
  description = "Enable RBAC authorization on this key vault"
  type        = bool
  default     = false
}

#################################
# Firewall configuration section
#################################

variable "firewall_sku_tier" {
  description = "[Standard/Premium] The SKU for Azure Firewall. It defaults to Premium."
  type        = string
  default     = "Premium"

  validation {
    condition     = var.firewall_sku_tier == "Standard" || var.firewall_sku_tier == "Premium"
    error_message = "The Azure Firewall must be set to Premium or Standard."
  }
}

variable "firewall_sku_name" {
  description = "SKU name of the Firewall. Possible values are AZFW_Hub and AZFW_VNet."
  type        = string
  default     = "AZFW_VNet"

  validation {
    condition     = var.firewall_sku_name == "AZFW_VNet" || var.firewall_sku_name == "AZFW_Hub"
    error_message = "The Azure Firewall must be set to AZFW_VNet or AZFW_Hub."
  }
}

variable "firewall_threat_intel_mode" {
  description = "[Alert/Deny/Off] The Azure Firewall Threat Intelligence Rule triggered logging behavior. Valid values are 'Alert', 'Deny', or 'Off'. The default value is 'Alert'"
  type        = string
  default     = "Deny"

  validation {
    condition     = var.firewall_threat_intel_mode == "Alert" || var.firewall_threat_intel_mode == "Deny" || var.firewall_threat_intel_mode == "Off"
    error_message = "The Azure Firewall Threat Intelligence Rule must be set to [Alert/Deny/Off]."
  }
}

// Network hub starts out with only supporting DNS. This is only being done for
// simplicity in this deployment and is not guidance, please ensure all firewall
// rules are aligned with your security standards.
variable "firewall_policy_application_rule_collection" {
  description = "List of Application Rule Collections used by Firewall Policy."
  type = list(object({
    name             = string
    description      = optional(string)
    priority         = number
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
  default = [
    {
      name             = "AzureAuth"
      priority         = 100
      action           = "Allow"
      source_addresses = ["*"]
      target_fqdns     = ["aadcdn.msftauth.net", "aadcdn.msauth.net"]
      protocol = {
        type = "Https"
        port = "443"
      }
  }]
}

variable "firewall_policy_network_rule_collection" {
  description = "List of Network Rule Collections used by Firewall Policy."
  type = list(object({
    name                  = string
    description           = optional(string)
    priority              = number
    action                = string
    source_addresses      = optional(list(string))
    destination_ports     = list(string)
    destination_addresses = optional(list(string))
    destination_fqdns     = optional(list(string))
    protocols             = list(string)
  }))
  default = [
    {
      name                  = "AzureCloud"
      description           = "Allow traffic to Azure Cloud"
      priority              = 100
      action                = "Allow"
      source_addresses      = ["*"]
      destination_ports     = ["*"]
      destination_addresses = ["AzureCloud"]
      translated_port       = null
      translated_address    = null
      protocols             = ["Any"]
    },
    {
      name                  = "AllSpokeTraffic"
      description           = "Allow traffic between spokes"
      priority              = 200
      action                = "Allow"
      source_addresses      = ["10.96.0.0/19"]
      destination_ports     = ["*"]
      destination_addresses = ["*"]
      translated_port       = null
      translated_address    = null
      protocols             = ["Any"]
    }
  ]
}

variable "firewall_client_subnet_address_prefix" {
  description = "The CIDR Subnet Address Prefix for the Azure Firewall Subnet. It must be in the Hub Virtual Network space. It must be /26."
  type        = string
  default     = "10.0.100.0/26"
}

variable "firewall_client_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Azure Firewall Client Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = []
}

variable "firewall_client_publicIP_address_availability_zones" {
  description = "An array of Azure Firewall Public IP Address Availability Zones. It defaults to empty, or 'No-Zone', because Availability Zones are not available in every cloud. See https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku for valid settings."
  type        = list(string)
  default     = []
}

variable "firewall_management_subnet_address_prefix" {
  description = "The CIDR Subnet Address Prefix for the Azure Firewall Management Subnet. It must be in the Hub Virtual Network space. It must be /26."
  type        = string
  default     = "10.0.100.64/26"
}

variable "firewall_management_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Azure Firewall Management Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = []
}

variable "firewall_management_publicIP_address_availability_zones" {
  description = "An array of Azure Firewall Public IP Address Availability Zones. It defaults to empty, or 'No-Zone', because Availability Zones are not available in every cloud. See https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku for valid settings."
  type        = list(string)
  default     = []
}

variable "firewall_supernet_IP_address" {
  description = "The IP address range that is used to allow traffic from the Azure Firewall to the Internet. It must be in the Hub Virtual Network space. It must be /19."
  type        = string
  default     = "10.96.0.0/19"
}

#################################
# Spokes Configuration
#################################

######################################
# Tier 1 - Operations Configuration ##
######################################

variable "ops_subscription_id" {
  description = "Subscription ID for the Operations Virtual Network deployment"
  type        = string
  default     = "<<subscriptionId>>"

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.ops_subscription_id)) || var.ops_subscription_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "ops_vnet_address_space" {
  description = "The CIDR Virtual Network Address Prefix for the Hub Virtual Network."
  type        = list(string)
  default     = ["10.0.115.0/26"]
}

variable "ops_vnet_subnet_address_prefixes" {
  description = "The CIDR Address Prefixes for the Subnets in the Hub Virtual Network."
  type        = list(string)
  default     = ["10.0.115.0/27"]
}

variable "ops_vnet_subnet_service_endpoints" {
  description = "The CIDR Address Prefixes for the Subnets in the Hub Virtual Network."
  type        = list(string)
  default = [
    "Microsoft.KeyVault",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}

variable "ops_network_security_group_inbound_rules" {
  description = "A complex object that describes network security group rules for the Workload Virtual Network"
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
  default = {
    "allow_traffic_from_spokes_default" = {
      name                       = "Allow-Traffic-From-Spokes"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_ranges    = ["22", "3389", "80", "443"]
      source_address_prefixes    = ["10.0.130.0/26", "10.0.125.0/26", "10.0.120.0/26"]
      destination_address_prefix = "10.0.115.0/26"
    }
  }
}

variable "ops_storage_account_config" {
  description = "Storage Account variables for the Operations deployment"
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

###########################################
# Tier 2 - Shared Services Configuration ##
###########################################

variable "svcs_subscription_id" {
  description = "Subscription ID for the Shared Services Virtual Network deployment"
  type        = string
  default     = "<<subscriptionId>>"

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.svcs_subscription_id)) || var.svcs_subscription_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "svcs_vnet_address_space" {
  description = "The CIDR Virtual Network Address Prefix for the Hub Virtual Network."
  type        = list(string)
  default     = ["10.0.120.0/26"]
}

variable "svcs_vnet_subnet_address_prefixes" {
  description = "The CIDR Address Prefixes for the Subnets in the Hub Virtual Network."
  type        = list(string)
  default     = ["10.0.120.0/27"]
}

variable "svcs_vnet_subnet_service_endpoints" {
  description = "The CIDR Address Prefixes for the Subnets in the Hub Virtual Network."
  type        = list(string)
  default = [
    "Microsoft.KeyVault",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}

variable "svcs_network_security_group_inbound_rules" {
  description = "A complex object that describes network security group rules for the Workload Virtual Network"
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
  default = {
    "allow_traffic_from_spokes_default" = {
      name                       = "Allow-Traffic-From-Spokes"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_ranges    = ["22", "3389", "80", "443"]
      source_address_prefixes    = ["10.0.130.0/26", "10.0.125.0/26", "10.0.115.0/26"]
      destination_address_prefix = "10.0.120.0/26"
    }
  }
}

variable "svcs_storage_account_config" {
  description = "Storage Account variables for the Operations deployment"
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

######################################################
# Tier 2 - Shared Services Workloads Configuration  ##
######################################################

#############################
# Cosmos Configuration    ##
#############################

variable "create_cosmos_sqldb_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = false
  type        = bool
}

variable "cosmosdb_account_config" {
  type = map(object({
    offer_type                            = string
    kind                                  = optional(string)
    enable_free_tier                      = optional(bool)
    analytical_storage_enabled            = optional(bool)
    enable_automatic_failover             = optional(bool)
    public_network_access_enabled         = optional(bool)
    is_virtual_network_filter_enabled     = optional(bool)
    key_vault_key_id                      = optional(string)
    enable_multiple_write_locations       = optional(bool)
    access_key_metadata_writes_enabled    = optional(bool)
    mongo_server_version                  = optional(string)
    network_acl_bypass_for_azure_services = optional(bool)
    network_acl_bypass_ids                = optional(list(string))
  }))
  description = "Manages a CosmosDB (formally DocumentDB) Account specifications"
  default = {
    demo-cosmosdb = {
      offer_type = "Standard"
      kind       = "GlobalDocumentDB"
    }
  }
}

variable "enable_advanced_threat_protection" {
  description = "Whether to enable Advanced Threat Protection on CosmosDB"
  default     = false
  type        = bool
}

variable "create_cosmosdb_sql_database" {
  description = "Whether to create a CosmosDB SQL Database"
  default     = true
  type        = bool
}

variable "create_cosmosdb_sql_container" {
  description = "Whether to create a CosmosDB SQL Container"
  default     = true
  type        = bool
}

#####################################
# Storage Account Configuration    ##
#####################################

###############################
# Key Vault Configuration    ##
###############################

###############################################
# Dev Team Env Workload Spoke Configuration
##############################################

variable "dev_team_subscription_id" {
  description = "Subscription ID for the Workload Virtual Network deployment"
  type        = string
  default     = "<<subscriptionId>>"

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.dev_team_subscription_id)) || var.dev_team_subscription_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "dev_team_spoke_vnet_address_space" {
  description = "Address space prefixes for the Workload Virtual Network"
  type        = list(string)
  default     = ["10.0.125.0/24"]
}

variable "dev_team_vnet_subnet_address_prefixes" {
  description = "The CIDR Address Prefixes for the Subnets in the Hub Virtual Network."
  type        = list(string)
  default     = ["10.0.125.0/27"]
}

variable "dev_team_vnet_subnet_service_endpoints" {
  description = "The CIDR Address Prefixes for the Subnets in the Hub Virtual Network."
  type        = list(string)
  default = [
    "Microsoft.KeyVault",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}

variable "dev_team_network_inbound_security_group_rules" {
  description = "A complex object that describes network security group rules for the Workload Virtual Network"
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
  default = {
    "allow_traffic_from_spokes_default" = {
      name                       = "Allow-Traffic-From-Spokes"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_ranges    = ["22", "3389", "80", "443"]
      source_address_prefixes    = ["10.0.110.0/26", "10.0.130.0/26", "10.0.120.0/26"]
      destination_address_prefix = "10.0.125.0/26"
    }
  }
}

variable "dev_team_log_storage_account_name" {
  description = "Storage Account name for the Workload Virtual Network deployment"
  type        = string
  default     = "stlogsworkload"
}

variable "dev_team_logging_storage_account_config" {
  description = "Storage Account variables for the Workload Virtual Network deployment"
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

###############################################
# Prod Env Workload Spoke Configuration
##############################################

variable "prod_subscription_id" {
  description = "Subscription ID for the Workload Virtual Network deployment"
  type        = string
  default     = "<<subscriptionId>>"

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.prod_subscription_id)) || var.prod_subscription_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "prod_spoke_vnet_address_space" {
  description = "Address space prefixes for the Workload Virtual Network"
  type        = list(string)
  default     = ["10.0.130.0/24"]
}

variable "prod_vnet_subnet_address_prefixes" {
  description = "The CIDR Address Prefixes for the Subnets in the Hub Virtual Network."
  type        = list(string)
  default     = ["10.0.130.0/27"]
}

variable "prod_vnet_subnet_service_endpoints" {
  description = "The CIDR Address Prefixes for the Subnets in the Hub Virtual Network."
  type        = list(string)
  default = [
    "Microsoft.KeyVault",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}

variable "prod_network_inbound_security_group_rules" {
  description = "A complex object that describes network security group rules for the Workload Virtual Network"
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
  default = {
    "allow_traffic_from_spokes_default" = {
      name                       = "Allow-Traffic-From-Spokes"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_ranges    = ["22", "3389", "80", "443"]
      source_address_prefixes    = ["10.0.110.0/26", "10.0.125.0/26", "10.0.120.0/26"]
      destination_address_prefix = "10.0.130.0/26"
    }
  }
}

variable "prod_log_storage_account_name" {
  description = "Storage Account name for the Workload Virtual Network deployment"
  type        = string
  default     = "stlogsworkload"
}

variable "prod_logging_storage_account_config" {
  description = "Storage Account variables for the Workload Virtual Network deployment"
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
  default     = "10.0.100.160/27"
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
  default     = "azureadmin"
}

variable "use_random_password" {
  description = "Set this to true to use a random password for the VMs. If set to false, the password will be stored in the terraform state file."
  type        = bool
  default     = true
}


#######################################
# Jumpbox Linux VM Configuration    ###
#######################################

variable "size_linux_jumpbox" {
  description = "The size of the Jumpbox VM"
  type        = string
  default     = "Standard_B2s"
}

variable "jumpbox_linux_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

#########################################
# Jumpbox Windows VM Configuration    ###
#########################################


variable "size_windows_jumpbox" {
  description = "The size of the Jumpbox VM"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "jumpbox_windows_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

####################################################
# Azure Container Registry configuration section  ##
####################################################

variable "acr_name" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "BaboAcr"
}

variable "acr_sku" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "The container registry sku is invalid."
  }
}

variable "acr_admin_enabled" {
  description = "Specifies whether admin is enabled for the container registry"
  type        = bool
  default     = true
}

variable "acr_georeplication_locations" {
  description = "(Optional) A list of Azure locations where the container registry should be geo-replicated."
  type        = list(string)
  default     = []
}

variable "acr_dns_virtual_networks_to_link" {
  type        = list(string)
  description = "(Optional) A list of Virtual Network IDs to link to the Azure Container Registry DNS Zone. Changing this forces a new resource to be created."
  default     = []
}

####################################################
# Azure Kuvernates Cluster configuration section  ##
####################################################

variable "aks_prefix_name" {
  description = "Specifies the prefix of the AKS cluster"
  type        = string
  default     = "msft"
}

variable "aks_vnet_name" {
  description = "Specifies the name of the AKS subnet"
  default     = "AksVNet"
  type        = string
}

variable "aks_vnet_address_space" {
  description = "Specifies the address prefix of the AKS subnet"
  default     = ["10.0.0.0/16"]
  type        = list(string)
}

variable "aks_cluster_name" {
  description = "(Required) Specifies the name of the AKS cluster."
  default     = "BaboAks"
  type        = string
}

variable "role_based_access_control_enabled" {
  description = "(Required) Is Role Based Access Control Enabled? Changing this forces a new resource to be created."
  default     = true
  type        = bool
}

variable "use_user_defined_identity" {
  type        = bool
  description = "Use user defined identity"
  default     = true
}

variable "automatic_channel_upgrade" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, and stable."
  default     = "stable"
  type        = string

  validation {
    condition     = contains(["patch", "rapid", "stable"], var.automatic_channel_upgrade)
    error_message = "The upgrade mode is invalid."
  }
}

variable "admin_group_object_ids" {
  description = "(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
  default     = ["6e5de8c1-5a4b-409b-994f-0706e4403b77", "78761057-c58c-44b7-aaa7-ce1639c6c4f5"]
  type        = list(string)
}

variable "azure_rbac_enabled" {
  description = "(Optional) Is Role Based Access Control based on Azure AD enabled?"
  default     = true
  type        = bool
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free."
  default     = "Free"
  type        = string

  validation {
    condition     = contains(["Free", "Paid"], var.sku_tier)
    error_message = "The sku tier is invalid."
  }
}

variable "kubernetes_version" {
  description = "Specifies the AKS Kubernetes version"
  default     = "1.21.1"
  type        = string
}

variable "default_node_pool_vm_size" {
  description = "Specifies the vm size of the default node pool"
  default     = "Standard_F8s_v2"
  type        = string
}

variable "default_node_pool_availability_zones" {
  description = "Specifies the availability zones of the default node pool"
  default     = ["1", "2", "3"]
  type        = list(string)
}

variable "network_docker_bridge_cidr" {
  description = "Specifies the Docker bridge CIDR"
  default     = "172.17.0.1/16"
  type        = string
}

variable "network_dns_service_ip" {
  description = "Specifies the DNS service IP"
  default     = "10.2.0.10"
  type        = string
}

variable "network_service_cidr" {
  description = "Specifies the service CIDR"
  default     = "10.2.0.0/24"
  type        = string
}

variable "network_plugin" {
  description = "Specifies the network plugin of the AKS cluster"
  default     = "azure"
  type        = string
}

variable "default_node_pool_name" {
  description = "Specifies the name of the default node pool"
  default     = "system"
  type        = string
}

variable "default_node_pool_subnet_name" {
  description = "Specifies the name of the subnet that hosts the default node pool"
  default     = "SystemSubnet"
  type        = string
}

variable "default_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the default node pool"
  default     = ["10.0.0.0/21"]
  type        = list(string)
}

variable "default_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = true
}

variable "default_node_pool_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "default_node_pool_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "default_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 50
}

variable "default_node_pool_node_labels" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = map(any)
  default     = {}
}

variable "default_node_pool_node_taints" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type        = list(string)
  default     = []
}

variable "default_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Ephemeral"
}

variable "default_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  default     = 10
}

variable "default_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 3
}

variable "default_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type        = number
  default     = 3
}

variable "additional_node_pool_subnet_name" {
  description = "Specifies the name of the subnet that hosts the default node pool"
  default     = "UserSubnet"
  type        = string
}

variable "additional_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the additional node pool"
  type        = list(string)
  default     = ["10.0.16.0/20"]
}

variable "additional_node_pool_name" {
  description = "(Required) Specifies the name of the node pool."
  type        = string
  default     = "user"
}

variable "additional_node_pool_vm_size" {
  description = "(Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard_F8s_v2"
}

variable "additional_node_pool_availability_zones" {
  description = "(Optional) A list of Availability Zones where the Nodes in this Node Pool should be created in. Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "additional_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = true
}

variable "additional_node_pool_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "additional_node_pool_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "additional_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 50
}

variable "additional_node_pool_mode" {
  description = "(Optional) Should this Node Pool be used for System or User resources? Possible values are System and User. Defaults to User."
  type        = string
  default     = "User"
}

variable "additional_node_pool_node_labels" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = map(any)
  default     = {}
}

variable "additional_node_pool_node_taints" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["CriticalAddonsOnly=true:NoSchedule"]
}

variable "additional_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Ephemeral"
}

variable "additional_node_pool_os_type" {
  description = "(Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are Linux and Windows. Defaults to Linux."
  type        = string
  default     = "Linux"
}

variable "additional_node_pool_priority" {
  description = "(Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
  type        = string
  default     = "Regular"
}

variable "additional_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  default     = 10
}

variable "additional_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 3
}

variable "additional_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type        = number
  default     = 3
}
