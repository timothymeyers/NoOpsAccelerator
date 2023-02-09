# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy an Bastion Host with Jumpboxes to the Hub/Spoke Landing Zone
DESCRIPTION: The following components will be options in this deployment
                * Bastion Host
                * Jumpbox
AUTHOR/S: jspinella
*/

############################################
### STAGE 6: Bastion Host Configuations  ###
############################################

#########################################################################
### This stage is optional based on the value of `enable_bastion_hosts`
#########################################################################

module "mod_bastion_host" {
  providers = { azurerm = azurerm.hub }
  depends_on = [
    module.mod_hub_network,
    module.mod_svcs_network,
    //module.mod_svcs_kv
  ]
  source = "../../../terraform/core/overlays/bastionHosts"

  count = var.enable_services.enable_bastion_hosts ? 1 : 0

  // Global Settings
  org_name            = var.required.org_prefix
  resource_group_name = module.mod_hub_network.resource_group_name
  location            = module.mod_hub_network.resource_group_location
  deploy_environment  = var.required.deploy_environment
  workload_name       = "hub-core"

  // Bastion Host Settings
  virtual_network_name             = module.mod_hub_network.virtual_network_name
  subnet_bastion_cidr              = var.bastion_address_space
  subnet_bastion_service_endpoints = var.bastion_subnet_service_endpoints

  // Bastions Diagnostics Settings
  enable_bastion_diagnostics         = var.enable_services.enable_bastion_diagnostics
  log_analytics_storage_account_name = module.mod_operational_logging.laws_storage_account_name
  log_analytics_storage_account_id   = module.mod_operational_logging.laws_StorageAccount_Id
  log_analytics_resource_id          = module.mod_operational_logging.laws_resource_id

  // Jumpbox Settings
  vm_subnet_name                    = module.mod_hub_network.default_subnet_name # The subnet name for the jumpbox
  admin_username                    = var.jumpbox_admin_username                 # The admin username for the jumpbox
  use_random_password               = var.use_random_password                    # If true, a random password will be generated and stored in the Azure Key Vault
  log_analytics_workspace_id        = module.mod_operational_logging.laws_resource_id
  log_analytics_workspace_key       = module.mod_operational_logging.laws_workspace_key
  network_security_group_bastion_id = module.mod_hub_network.nsg_id

  // Linux Jumpbox Settings
  create_bastion_linux_jumpbox = var.enable_services.bastion_linux_virtual_machines # If true, a Linux jumpbox will be created
  vm_os_linux_disk_image       = var.jumpbox_linux_os_disk_image
  size_linux_jumpbox           = var.size_linux_jumpbox

  // Windows Jumpbox Settings
  create_bastion_windows_jumpbox = var.enable_services.bastion_windows_virtual_machines # If true, a Windows jumpbox will be created
  vm_os_windows_disk_image       = var.jumpbox_windows_os_disk_image
  size_windows_jumpbox           = var.size_windows_jumpbox

  // Locks
  enable_resource_locks = var.enable_services.enable_resource_locks
  lock_level            = var.lock_level

  // Tags
  tags = var.tags # Tags to be applied to all resources
}
