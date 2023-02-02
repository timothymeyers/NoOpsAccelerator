# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a Network Artifacts for a VDSS
DESCRIPTION: The following components will be options in this deployment
               Storage Account
               Key Vault
AUTHOR/S: jspinella
*/

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

############################
### STAGE 0: Scaffolding ###
############################

module "mod_netart_resource_group" {
  count  = var.enable_network_artifacts == true ? 1 : 0
  source  = "azurenoops/overlays-resource-group/azurerm"
  version = "1.0.0"

  //Global Settings
  location       = var.location
  org_name       = var.org_prefix
  environment    = var.required.deploy_environment
  workload_name  = "network-artifacts"
  custom_rg_name = var.custom_resource_group_name != null ? var.custom_resource_group_name : null

  // Tags
  add_tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)   
  }) # Tags to be applied to all resources
}

############################################################
### STAGE 1: Build out network artifacts storage account ###
############################################################

module "mod_netart_logging_storage" {
  count  = var.enable_network_artifacts == true ? 1 : 0
  source = "../../../storageAccounts"

  //Global Settings
  location = var.location

  // Storage Account Parameters
  name                = var.netart_log_storage_account_name
  resource_group_name = var.resource_group_name
  storage_account     = var.netart_storage_account

  // Storage Account Resource Lock Parameters
  enable_resource_lock = true
  lock_level           = "CanNotDelete"

  // Storage Account Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Network Artifacts Resource: %s", var.netart_log_storage_account_name)
  }) # Tags to be applied to all resources
}

output "storage_accounts" {
  value     = module.mod_netart_logging_storage
  sensitive = true
}


#######################################################
### STAGE 2: Build out network artifacts key vault  ###
#######################################################

module "mod_netart_key_vault" {
  count  = var.enable_network_artifacts == true ? 1 : 0
  source = "../../../../overlays/keyVaults"

  //Global Settings
  location = var.location

  // Key Vault Parameters
  key_vault_name                            = var.netart_key_vault_name
  vnet_subnet_id                            = var.vnet_subnet_id
  resource_group_name                       = var.resource_group_name
  key_vault_sku_name                        = var.sku_name // standard or premium
  key_vault_soft_delete_retention_days      = var.soft_delete_retention_days
  key_vault_enabled_for_deployment          = var.enabled_for_deployment
  key_vault_enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  key_vault_enabled_for_template_deployment = var.enabled_for_template_deployment
  key_vault_purge_protection_enabled        = var.purge_protection_enabled
  key_vault_enable_rbac_authorization       = var.enable_rbac_authorization
  key_vault_bypass                          = var.key_vault_bypass
  key_vault_default_action                  = var.key_vault_default_action

  // Key Vault logging parameters
  log_analytics_workspace_id = var.log_analytics_workspace_id

  // Key Vault Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Network Artifacts Resource: %s", var.netart_key_vault_name)
  }) # Tags to be applied to all resources
}

output "key_vaults" {
  value     = module.mod_netart_key_vault
  sensitive = true
}
