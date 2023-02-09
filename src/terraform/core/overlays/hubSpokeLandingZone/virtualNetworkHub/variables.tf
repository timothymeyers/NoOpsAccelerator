###########################
# Global Configuration   ##
###########################

variable "custom_resource_group_name" {
  description = "The name of the resource group to create. If not set, the name will be generated using the 'name_prefix' and 'name_suffix' variables. If set, the 'name_prefix' and 'name_suffix' variables will be ignored."
  type        = string
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "org_prefix" {
  description = "A name for the organization. It defaults to anoa."
  type        = string
  default     = "anoa"
}

variable "workload_name" {
  description = "A name for the workload. It defaults to anoa."
  type        = string
  default     = "anoa"
}

variable "environment" {
  description = "The Terraform backend environment e.g. public or usgovernment"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
  type        = map(string)
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

##########################
# VNet Configuration    ##
##########################

variable "virtual_network_name" {
  description = "Name of your Azure Virtual Network"
  default     = null
}

variable "virtual_network_address_space" {
  description = "The address space to be used for the Azure virtual network."
  default     = []
}

variable "create_ddos_plan" {
  description = "Create an ddos plan - Default is false"
  default     = false
}

variable "ddos_plan_name" {
  description = "The name of AzureNetwork DDoS Protection Plan"
  default     = null
}

variable "dns_servers" {
  description = "List of dns servers to use for virtual network"
  default     = []
}

variable "create_network_watcher" {
  description = "Controls if Network Watcher resources should be created for the Azure subscription"
  default     = false
}

############################
# Subnet Configuration    ##
############################

variable "subnet_name" {
  description = "The name of the defualt subnet"
  default     = null
}

variable "subnet_address_prefixes" {
  description = "The address prefixes to use for the default subnet"
  type        = list(string)
  default     = []
}

variable "subnet_service_endpoints" {
  description = "Service endpoints to add to the default subnet"
  type        = list(string)
  default     = []
}

variable "private_endpoint_network_policies_enabled" {
  description = "Whether or not to enable network policies on the private endpoint subnet"
  default     = null
}

variable "private_endpoint_service_endpoints_enabled" {
  description = "Whether or not to enable service endpoints on the private endpoint subnet"
  default     = null
}

variable "gateway_subnet_address_prefix" {
  description = "The address prefix to use for the gateway subnet"
  default     = null
}

variable "gateway_service_endpoints" {
  description = "Service endpoints to add to the Gateway subnet"
  type        = list(string)
  default     = []
}

variable "network_security_group_name" {
  description = "The name of the network security group to associate with the subnet"
  default     = null
}

variable "network_security_group_inbound_rules" {
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

variable "network_security_group_outbound_rules" {
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

#################################
# Route Table Configuration    ##
#################################

variable "route_table_name" {
  description = "The name of the route table to associate with the subnet"
  default     = null
}

variable "route_table_routes" {
  description = "A map of route table routes to add to the route table"
  type = map(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = string
  }))
  default = {}
}

variable "disable_bgp_route_propagation" {
  description = "Whether to disable the default BGP route propagation on the subnet"
  default     = false
}

variable "subnets_to_associate" {
  description = "(Optional) Specifies the subscription id, resource group name, and name of the subnets to associate"
  type        = map(any)
  default     = {}
}

##############################
# Firewall Configuration    ##
##############################

variable "create_firewall" {
  description = "Controls if Azure Firewall resources should be created for the Azure subscription"
}

variable "enable_forced_tunneling" {
  description = "Route all Internet-bound traffic to a designated next hop instead of going directly to the Internet"
}

variable "firewall_subnet_address_prefix" {
  description = "The address prefix to use for the Firewall subnet"
  default     = null
}

variable "firewall_management_subnet_address_prefix" {
  description = "The address prefix to use for Firewall managemement subnet to enable forced tunnelling. The Management Subnet used for the Firewall must have the name `AzureFirewallManagementSubnet` and the subnet mask must be at least a `/26`."
  default     = null
}

variable "firewall_management_publicIP_address_name" {
  description = "The name of the public IP address to associate with the Firewall management subnet. The public IP address used for the Firewall must have the name `AzureFirewallManagementIp` and the IP address must be a static IP address."
  default     = null
}

variable "firewall_client_publicIP_address_name" {
  description = "The name of the public IP address to associate with the Firewall client subnet. The public IP address used for the Firewall must have the name `AzureFirewallManagementIp` and the IP address must be a static IP address."
  default     = null
}

variable "firewall_service_endpoints" {
  description = "Service endpoints to add to the firewall subnet"
  type        = list(string)
  default = [
    "Microsoft.AzureCosmosDB",
    "Microsoft.EventHub",
    "Microsoft.KeyVault",
    "Microsoft.ServiceBus",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
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

variable "virtual_hub" {
  description = "An Azure Virtual WAN Hub with associated security and routing policies configured by Azure Firewall Manager. Use secured virtual hubs to easily create hub-and-spoke and transitive architectures with native security services for traffic governance and protection."
  type = object({
    virtual_hub_id  = string
    public_ip_count = number
  })
  default = null
}

variable "firewall_application_rules" {
  description = "List of application rules to apply to firewall."
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

############################
# Storage Configuration   ##
############################

variable "storage_account_name" {
  description = "The name of the storage account"
  default     = null
}
