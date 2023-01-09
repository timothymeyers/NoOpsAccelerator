# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy Private DNS Zones for VDSS in a Hub Network
DESCRIPTION: The following components will be options in this deployment
              Private DNS Zones
              Virtual Networks Links
PREREQS: Hub Network
AUTHOR/S: jspinella
*/

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

data "azurerm_client_config" "current" {
}

data "azurerm_resource_group" "hub_rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "hub_vnet" {
  name = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

# Private DNS Zone for Azure Operational insights
module "oms_opinsights_azure_com_private_dns_zone" {
  source                   = "../../../../modules/Microsoft.Network/privateDnsZone"
  name                     = var.environment == "public" ? "privatelink.oms.opinsights.azure.com" : "privatelink.oms.opinsights.azure.us"
  resource_group_name      = data.azurerm_resource_group.hub_rg.name
  virtual_networks_to_link = {
    (data.azurerm_virtual_network.hub_vnet.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = data.azurerm_resource_group.hub_rg.name
    }
  }
}

# Private DNS Zone for Azure Monitor
module "monitor_azure_com_private_dns_zone" {
  source                   = "../../../../modules/Microsoft.Network/privateDnsZone"
  name                     = var.environment == "public" ? "privatelink.monitor.azure.com" : "privatelink.monitor.azure.us"
  resource_group_name      = data.azurerm_resource_group.hub_rg.name
  virtual_networks_to_link = {
    (data.azurerm_virtual_network.hub_vnet.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = data.azurerm_resource_group.hub_rg.name
    }
  }
}

# Private DNS Zone for Azure Operational insights
module "ods_opinsights_azure_com_private_dns_zone" {
  source                   = "../../../../modules/Microsoft.Network/privateDnsZone"
  name                     = var.environment == "public" ? "privatelink.ods.opinsights.azure.com" : "privatelink.ods.opinsights.azure.us"
  resource_group_name      = data.azurerm_resource_group.hub_rg.name
  virtual_networks_to_link = {
    (data.azurerm_virtual_network.hub_vnet.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = data.azurerm_resource_group.hub_rg.name
    }
  }
}

# Private DNS Zone for Azure Automation
module "agentsvc_azure_automation_net_private_dns_zone" {
  source                   = "../../../../modules/Microsoft.Network/privateDnsZone"
  name                     = var.environment == "public" ? "privatelink.agentsvc.azure-automation.net" : "privatelink.agentsvc.azure-automation.us"
  resource_group_name      = data.azurerm_resource_group.hub_rg.name
  virtual_networks_to_link = {
    (data.azurerm_virtual_network.hub_vnet.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = data.azurerm_resource_group.hub_rg.name
    }
  }
}
