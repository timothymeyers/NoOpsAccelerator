# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------
# Local declarations
#---------------------------------
locals {
  firewall_client_subnet_name     = "AzureFirewallSubnet"
  firewall_management_subnet_name = "AzureFirewallManagementSubnet"
}

data "azurerm_resource_group" "hub" {
  name = var.resource_group_name
}

data "azurerm_firewall_policy" "firewallpolicy" {
  name                = var.firewall_policy_name
  resource_group_name = data.azurerm_resource_group.hub.name
}

#---------------------------------------------------------
# Firewall Subnet Creation or selection
#----------------------------------------------------------
module "fw_client_subnet" {
  source = "../subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  name                                          = var.firewall_client_subnet_name
  address_prefixes                              = [cidrsubnet(var.firewall_client_subnet_address_prefix, 0, 0)]
  service_endpoints                             = var.firewall_client_subnet_service_endpoints
  private_link_service_network_policies_enabled = false
  private_endpoint_network_policies_enabled     = false

  // Subnet Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

#---------------------------------------------------------
# Firewall Subnet Creation or selection
#----------------------------------------------------------
module "fw_managment_subnet" {
  source = "../subnets"
  count = var.enable_forced_tunneling ? 1 : 0

  // Global Settings
  location = var.location

  // Subnet Parameters
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  name                                          = var.firewall_management_subnet_name
  address_prefixes                              = [cidrsubnet(var.firewall_management_subnet_address_prefix, 0, 0)]
  service_endpoints                             = var.firewall_management_subnet_service_endpoints
  private_link_service_network_policies_enabled = false
  private_endpoint_network_policies_enabled     = false


  // Subnet Tags
  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

#------------------------------------------
# Public IP resources for Azure Firewall
#------------------------------------------
module "mod_firewall_client_publicIP_address" {
  source = "../publicIPAddress"

  // Global Settings
  location = var.location

  // PIP Client Parameters
  public_ip_address_name = lower("${var.firewall_client_publicIP_address_name}")
  resource_group_name    = var.resource_group_name

  // PIP Client Diagnostics
  enable_diagnostic_settings          = var.enable_diagnostic_settings
  log_analytics_workspace_resource_id = var.log_analytics_workspace_resource_id
  log_analytics_storage_resource_id   = var.log_analytics_storage_resource_id
  pip_log_categories                  = var.publicIP_address_diagnostics_logs
  pip_metric_categories               = var.publicIP_address_diagnostics_metrics

  // PIP Client Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Network Firewall Resource: %s", var.firewall_client_publicIP_address_name)
  }) # Tags to be applied to all resources
}

module "mod_firewall_management_publicIP_address" {
  count  = var.enable_forced_tunneling ? 1 : 0
  source = "../publicIPAddress"

  // Global Settings
  location = var.location

  // PIP Management Parameters
  public_ip_address_name = lower("${var.firewall_management_publicIP_address_name}")
  resource_group_name    = var.resource_group_name

  // PIP Management Diagnostics
  enable_diagnostic_settings          = var.enable_diagnostic_settings
  log_analytics_workspace_resource_id = var.log_analytics_workspace_resource_id
  log_analytics_storage_resource_id   = var.log_analytics_storage_resource_id
  pip_log_categories                  = var.publicIP_address_diagnostics_logs
  pip_metric_categories               = var.publicIP_address_diagnostics_metrics

  // PIP Management Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Network Firewall Resource: %s", var.firewall_management_publicIP_address_name)
  }) # Tags to be applied to all resources
}

#-----------------
# Azure Firewall
#-----------------
resource "azurerm_firewall" "firewall" {
  name                = var.firewall_config.name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.hub.name
  sku_name            = var.firewall_config.sku_name
  sku_tier            = var.firewall_config.sku_tier
  dns_servers         = var.firewall_config.dns_servers
  threat_intel_mode   = lookup(var.firewall_config, "threat_intel_mode", "Alert")
  zones               = var.firewall_config.zones

  ip_configuration {
    name                 = lower("${var.firewall_config.name}-ipconfig")
    subnet_id            = module.fw_client_subnet.id
    public_ip_address_id = module.mod_firewall_client_publicIP_address.id
  }

  dynamic "management_ip_configuration" {
    for_each = var.enable_forced_tunneling ? [1] : []
    content {
      name                 = lower("${var.firewall_config.name}-forced-tunnel")
      subnet_id            = module.fw_managment_subnet.id
      public_ip_address_id = module.mod_firewall_management_publicIP_address.0.id
    }
  }

  dynamic "virtual_hub" {
    for_each = var.virtual_hub != null ? [var.virtual_hub] : []
    content {
      virtual_hub_id  = virtual_hub.value.virtual_hub_id
      public_ip_count = virtual_hub.value.public_ip_count
    }
  }

  // Azure Firewall Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Network Firewall Resource: %s", var.firewall_config.name)
  }) # Tags to be applied to all resources
}
