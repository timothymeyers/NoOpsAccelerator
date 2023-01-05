# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the Firewall virtual network"
  type        = string
}

variable "firewall_client_publicIP_address_name" {
  description = "The name of the Azure Firewall Client Public IP Address."
  type        = string
  default     = ""
}


variable "firewall_management_publicIP_address_name" {
  description = "The name of the Azure Firewall Management Public IP Address."
  type        = string
  default     = ""
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

variable "firewall_client_subnet_address_prefix" {
  description = "The CIDR Subnet Address Prefix for the Azure Firewall Subnet. It must be in the Hub Virtual Network space. It must be /26."
  type        = string
  default     = "10.0.100.0/26"
}

variable "firewall_client_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Azure Firewall Client Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default = [
    "Microsoft.KeyVault",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
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

variable "firewall_policy_name" {
  description = "The name of the firewall policy"
  type        = string
}

variable "virtual_hub" {
  description = "An Azure Virtual WAN Hub with associated security and routing policies configured by Azure Firewall Manager. Use secured virtual hubs to easily create hub-and-spoke and transitive architectures with native security services for traffic governance and protection."
  type = object({
    virtual_hub_id  = string
    public_ip_count = number
  })
  default = null
}

variable "enable_forced_tunneling" {
  description = "Route all Internet-bound traffic to a designated next hop instead of going directly to the Internet"
  type        = bool
  default     = false
}

variable "publicIP_address_diagnostics_logs" {
  description = "An array of Public IP Address Diagnostic Logs for the Azure Firewall. See https://docs.microsoft.com/en-us/azure/ddos-protection/diagnostic-logging?tabs=DDoSProtectionNotifications#configure-ddos-diagnostic-logs for valid settings."
  type        = list(string)
  default     = []
}

variable "publicIP_address_diagnostics_metrics" {
  description = "An array of Public IP Address Diagnostic Metrics for the Azure Firewall. See https://docs.microsoft.com/en-us/azure/ddos-protection/diagnostic-logging?tabs=DDoSProtectionNotifications#configure-ddos-diagnostic-logs for valid settings."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_resource_id" {
  description = "The resource id of the Log Analytics Workspace"
  type        = string
  default     = ""
}

variable "log_analytics_storage_resource_id" {
  description = "The resource id of the Log Analytics Workspace Storage Account"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# With forced tunneling on, Configure Azure Firewall to never SNAT regardless of the destination IP address,
# use 0.0.0.0/0 as your private IP address range.
# With this configuration, Azure Firewall can never route traffic directly to the Internet.
# see: https://docs.microsoft.com/en-us/azure/firewall/snat-private-range
variable "disable_snat_ip_range" {
  description = "The address space to be used to ensure that SNAT is disabled."
  default     = ["0.0.0.0/0"]
  type        = list(any)
}

variable "enable_diagnostic_settings" {
  description = "Create a bastion host and jumpbox VM?"
  type        = bool
  default     = false
}

variable "fw_log_categories" {
  description = "List of Diagnostic Log Categories"
  type        = list(string)
  default     = []
}

variable "fw_metric_categories" {
  description = "List of Diagnostic Metric Categories"
  type        = list(string)
  default     = []
}

variable "flow_log_retention_in_days" {
  description = "The number of days to retain flow log data"
  default     = "7"
  type        = number
}

variable "enable_resource_locks" {
  description = "Flag to enable locks on the operations resources"
  type        = bool
  default     = true
}

variable "lock_level" {
  description = "The level of lock to apply to the resources. Valid values are CanNotDelete, ReadOnly, or NotSpecified."
  type        = string
  default     = "CanNotDelete"
}
