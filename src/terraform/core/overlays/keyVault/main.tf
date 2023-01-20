# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a Key Vault with private endpoints to an Virutal Network
DESCRIPTION: The following components will be options in this deployment
            * Key Vault
            * Private Endpoint
AUTHOR/S: jspinella
*/

# If the resource group name is not provided, create a new one
data "azurerm_resource_group" "kv_rg" {
  count = length(var.resource_group_name) > 0 ? 1 : 0
  name  = var.resource_group_name
}

module "key_vault" {
  source = "../../../modules/Microsoft.KeyVault"

  name                            = var.key_vault_name
  location                        = var.location
  resource_group_name             = length(var.resource_group_name) > 0 ? data.azurerm_resource_group.kv_rg.name : var.resource_group_name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_name
  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  bypass                          = var.key_vault_bypass
  default_action                  = var.key_vault_default_action
  log_analytics_workspace_id      = var.log_analytics_workspace_id
  log_analytics_retention_days    = var.log_analytics_retention_days

  tags = merge(var.tags, {
    DeployedBy = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

# Create the private DNS zone for the ACR
module "key_vault_private_dns_zone" {
  source                   = "../../../modules/Microsoft.Network/privateDnsZone"
  name                     = "privatelink.vaultcore.azure.net"
  resource_group_name      = length(var.resource_group_name) > 0 ? data.azurerm_resource_group.kv_rg.name : var.resource_group_name
  virtual_networks_to_link = var.virtual_networks_to_link
}

# Create the private endpoint for the ACR
module "key_vault_private_endpoint" {
  source                         = "../../../modules/Microsoft.Network/privateEndpoints"
  name                           = "${module.key_vault.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = length(var.resource_group_name) > 0 ? data.azurerm_resource_group.kv_rg.name : var.resource_group_name
  subnet_id                      = var.vnet_subnet_id
  tags                           = var.tags
  private_connection_resource_id = module.key_vault.id
  is_manual_connection           = false
  subresource_name               = "vault"
  private_dns_zone_group_name    = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.key_vault_private_dns_zone.id]
}

