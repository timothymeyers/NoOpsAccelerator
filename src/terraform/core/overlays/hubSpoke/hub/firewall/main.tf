# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the firewall to the Hub Network and it's components based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              Subnets
              Azure Firewall
              Public IPs
PREREQS: Hub
AUTHOR/S: jspinella
*/

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

#
#
# Firewall Policy
#
#
module "mod_firewall_policy" {
  source = "../../../../modules/Microsoft.Network/firewallPolicies"

  // Global Settings
  location = var.location

  //
  resource_group_name                   = var.resource_group_name
  firewall_policy_collection_group_name = var.firewall_policy_name
  firewall_policy_name                  = var.firewall_policy_name
  firewall_sku                          = var.firewall_sku_tier

  // Rules Collections
  // App Rules
  application_rule_collection = var.firewall_application_rule_collection
  
  // Network Rules
  network_rule_collection = var.firewall_network_rule_collection
}

#
#
# Firewall
#
#
module "mod_firewall" {
  source = "../../../../modules/Microsoft.Network/firewalls"

  // Global Settings
  location            = var.location
  resource_group_name = var.resource_group_name

  # Azure firewall network configuration
  virtual_network_name = var.virtual_network_name

  # Azure firewall general configuration
  # If `virtual_hub` is specified, the threat_intel_mode has to be explicitly set as `""`
  firewall_client_subnet_name              = "AzureFirewallSubnet"
  firewall_client_subnet_address_prefix    = var.firewall_client_subnet_address_prefix
  firewall_client_subnet_service_endpoints = var.firewall_client_subnet_service_endpoints
  firewall_policy_name                     = module.mod_firewall_policy.azurerm_firewall_policy_name

  firewall_config = {
    name              = var.firewall_name
    sku_name          = var.firewall_sku_name
    sku_tier          = var.firewall_sku_tier
    threat_intel_mode = var.firewall_threat_intel_mode
  }

  # Allow force-tunnelling of traffic to be performed by the firewall
  # The Management Subnet used for the Firewall must have the name `AzureFirewallManagementSubnet`
  # and the subnet mask must be at least a /26.
  enable_forced_tunneling                   = var.enable_forced_tunneling
  firewall_management_subnet_name           = "AzureFirewallManagementSubnet"
  firewall_management_publicIP_address_name = var.firewall_management_public_ip_address_name
  firewall_management_subnet_address_prefix = var.firewall_management_subnet_address_prefix

  # Allow the firewall to be accessed from the internet
  # The Client Subnet used for the Firewall must have the name `AzureFirewallSubnet`
  # and the subnet mask must be at least a /26.
  firewall_client_publicIP_address_name = var.firewall_client_public_ip_address_name

  // Enable Resource Locks
  enable_resource_locks = var.enable_resource_locks
  lock_level            = var.lock_level

  // Enable Diagnostics
  publicIP_address_diagnostics_logs    = var.publicIP_address_diagnostics_logs
  publicIP_address_diagnostics_metrics = var.publicIP_address_diagnostics_metrics

  // Firewall Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Hub Network Firewall Resource: %s", var.firewall_name)
  }) # Tags to be applied to all resources
}
