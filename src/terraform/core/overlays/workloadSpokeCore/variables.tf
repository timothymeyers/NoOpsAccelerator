#################################
# Global Configuration
#################################

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)
  default = {
    "DeploymentType" : "AzureNoOpsTF"
  }
}

variable "org_prefix" {
  description = "A name for the organization. It defaults to anoa."
  type        = string
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group the virtual machine resides in"
  type        = string
}

variable "deploy_environment" {
  description = "The environment to deploy to. It defaults to 'dev'."
  type        = string
  default     = "dev"
}


#################################
# Logging Configuration
#################################

variable "workload_log_storage_account_name" {
  description = "Storage Account name for the operations deployment"
  type        = string
  default     = ""
}

variable "log_analytics_resource_id" {
  description = "The name of the log analytics workspace resource id"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "The name of the log analytics workspace"
  type        = string
  default     = ""
}

variable "log_analytics_storage_id" {
  description = "The name of the log analytics storage account"
  type        = string
  default     = ""
}

#################################
# Tier 1 Configuration
#################################

variable "workload_virtual_network_name" {
  description = "Virtual Network Name for the deployment"
  type        = string
  default     = "operations-vnet"
}

variable "workload_subnet_name" {
  description = "Subnet Name for the workload deployment"
  type        = string
  default     = "operations-snet"
}

variable "workload_vnet_address_space" {
  description = "The CIDR Virtual Network Address Prefix for the workload Virtual Network."
  type        = list(string)
  default     = ["10.0.115.0/26"]
}

variable "workload_vnet_subnet_address_space" {
  description = "The CIDR Subnet Address Prefix for the default workload subnet. It must be in the workload Virtual Network space.'"
  type        = string
  default     = "10.0.115.0/27"
}

variable "workload_virtual_network_diagnostics_logs" {
  description = "An array of Network Diagnostic Logs to enable for the workload Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs for valid settings."
  type        = list(string)
  default     = []
}

variable "workload_virtual_network_diagnostics_metrics" {
  description = "An array of Network Diagnostic Metrics to enable for the workload Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings."
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "workload_network_security_group_name" {
  description = " The name of the Network Security Group to apply to the workload Virtual Network."
  type        = string
  default     = ""
}

variable "workload_network_security_group_rules" {
  description = "An array of Network Security Group Rules to apply to the operations Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat for valid settings."
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {}
}

variable "workload_network_security_group_diagnostics_logs" {
  description = "An array of Network Security Group diagnostic logs to apply to the Identity Virtual Network. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories for valid settings."
  type        = list(string)
  default     = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
}

variable "workload_network_security_group_diagnostics_metrics" {
  description = "An array of Network Security Group Metrics to apply to enable for the Identity Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings."
  type        = list(string)
  default     = []
}

variable "workloads_subnets" {
  description = "A map of subnets to create in the workload Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?tabs=bicep#subnetpropertiesformat for valid settings."
  type = list(object({
    name                                           = string
    address_prefixes                               = list(string)
    service_endpoints                              = list(string)
    enforce_private_link_endpoint_network_policies = bool
    enforce_private_link_service_network_policies  = bool
  }))
}

variable "workload_logging_storage_account" {
  description = "Storage Account variables for the workload deployment"
  type = object({
    sku_name = string
    kind     = string
  })
  default = {
    sku_name = "Standard_LRS"
    kind     = "StorageV2"
  }
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection"
  type        = bool
  default     = false
}

#################################
# Firewall configuration section
#################################

variable "firewall_private_ip" {
  description = "The private IP address of the firewall"
  type        = string
  default     = ""
}
