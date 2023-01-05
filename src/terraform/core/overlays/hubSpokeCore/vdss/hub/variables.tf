#################################
# Global Configuration
#################################

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)
  default     = {}
}

variable "org_prefix" {
  description = "A name for the organization. It defaults to anoa."
  type        = string
}

variable "location" {
  description = ""
  type        = string
}

variable "resource_group_name" {
    description = "The name of the resource group."
    type = string
}

variable "deploy_environment" {
  description = "The environment to deploy to. It defaults to 'dev'."
  type        = string
  default     = "dev"
}

#################################
# Logging Configuration
#################################


variable "hub_log_storage_account_name" {
  description = "The name of the storage account to store the logs in"
  type        = string
}

variable "log_analytics_resource_id" {
  description = "The resource id of the Log Analytics Workspace"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The name of the log analytics workspace"
  type        = string
}

variable "log_analytics_storage_id" {
  description = "The name of the log analytics storage account"
  type        = string
}

#################################
# Hub Configuration
#################################

variable "hub_virtual_network_name" {
  description = "The name of the Hub Virtual Network."
  type        = string
  default     = "hub-vnet"
}

variable "hub_subnet_name" {
  description = "The name of the Hub Subnet."
  type        = string
  default     = "hub-subnet"
}

variable "hub_route_table_name" {
  description = "The name of the Hub Route Table."
  type        = string
  default     = "hub-route-table"
}

variable "hub_vnet_address_space" {
  description = "The CIDR Virtual Network Address Prefix for the Hub Virtual Network."
  type        = list(string)
  default     = ["10.0.100.0/24"]
}

variable "hub_vnet_subnet_address_space" {
  description = "The CIDR Subnet Address Prefix for the default Hub subnet. It must be in the Hub Virtual Network space.'"
  type        = string
  default     = "10.0.100.128/27"
}

variable "hub_virtual_network_diagnostics_logs" {
  description = "An array of Network Diagnostic Logs to enable for the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs for valid settings."
  type        = list(string)
  default     = []
}

variable "hub_virtual_network_diagnostics_metrics" {
  description = "An array of Network Diagnostic Metrics to enable for the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings."
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "hub_network_security_group_name" {
  description = "The name of the Network Security Group to apply to the Hub Virtual Network."
  type        = string
  default     = "hub-nsg"
}

variable "hub_network_security_group_diagnostics_logs" {
  description = "An array of Network Security Group diagnostic logs to apply to the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories for valid settings."
  type        = list(string)
  default     = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
}

variable "hub_network_security_group_diagnostics_metrics" {
  description = "An array of Network Security Group Metrics to apply to enable for the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings."
  type        = list(string)
  default     = []
}

variable "hub_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Hub subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = ["Microsoft.Storage"]
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection"
  type        = bool
  default     = false
}
variable "hub_logging_storage_account" {
  description = "Storage Account variables for the hub deployment"
  default     = {}
}

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
# Hub - Azure Firewall Configuration
#################################

variable "firewall_private_ip" {
  description = "The private IP address of the Azure Firewall. It must be in the Hub Virtual Network space."
  type        = string
  default     = ""
}
