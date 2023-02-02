# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
#
# Linux Jumpbox
#
#
module "mod_linux_jumpbox" {
  count = var.create_bastion_linux_jumpbox ? 1 : 0

  depends_on = [data.azurerm_resource_group.hub, module.mod_bastion_host]
  source     = "../virtualMachines/linux"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = data.azurerm_resource_group.hub.name
  location             = var.location
  location_short       = var.location_short
  environment          = var.environment
  org_name             = var.org_prefix
  workload_name        = "jumpbox"
  virtual_network_name = data.azurerm_virtual_network.hub_bastion_host_vnet.guid
  vm_subnet_name       = var.vm_subnet_name
  virtual_machine_name = "linux"

  # This module support multiple Pre-Defined Linux and Windows Distributions.
  # Check the README.md file for more pre-defined images for Ubuntu, Centos, RedHat.
  # Please make sure to use gen2 images supported VM sizes if you use gen2 distributions
  # Specify `disable_password_authentication = false` to create random admin password
  # Specify a valid password with `admin_password` argument to use your own password 
  # To generate SSH key pair, specify `generate_admin_ssh_key = true`
  # To use existing key pair, specify `admin_ssh_key_data` to a valid SSH public key path.  
  linux_distribution_name = "ubuntu2004"
  virtual_machine_size    = "Standard_B2s"
  admin_username          = var.admin_username
  generate_admin_ssh_key  = true
  instances_count         = 1

  # Proxymity placement group, Availability Set and adding Public IP to VM's are optional.
  # remove these argument from module if you dont want to use it.  
  enable_proximity_placement_group = false
  enable_vm_availability_set       = true
  enable_public_ip_address         = true

  # Network Seurity group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.
  # Remove this NSG rules block, if `existing_network_security_group_id` is specified
  existing_network_security_group_id = var.bastion_network_security_group_id

  # Boot diagnostics to troubleshoot virtual machines, by default uses managed 
  # To use custom storage account, specify `storage_account_name` with a valid name
  # Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics
  enable_boot_diagnostics = true
  storage_account_name    = var.log_analytics_storage_account_id

  # Attach a managed data disk to a Windows/Linux VM's. Possible Storage account type are: 
  # `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `Premium_ZRS`, `StandardSSD_LRS`
  # or `UltraSSD_LRS` (UltraSSD_LRS only available in a region that support availability zones)
  # Initialize a new data disk - you need to connect to the VM and run diskmanagemnet or fdisk
  data_disks = {
    disk1 = {
      name                 = "disk1"
      disk_size_gb         = 100
      lun                  = 0
      storage_account_type = "StandardSSD_LRS"
    }
    disk2 = {
      name                 = "disk2"
      disk_size_gb         = 100
      lun                  = 0
      storage_account_type = "StandardSSD_LRS"
    }
  }

  # (Optional) To enable Azure Monitoring and install log analytics agents
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage.   
  log_analytics_resource_id = var.log_analytics_resource_id

  # Deploy log analytics agents to virtual machine. 
  # Log analytics workspace customer id and primary shared key required.
  deploy_log_analytics_agent                 = true
  log_analytics_customer_id                  = var.log_analytics_workspace_id
  log_analytics_workspace_primary_shared_key = var.log_analytics_workspace_key

  // Tags
  extra_tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Linux VM for Azure Bastion %s", local.bastionHostName)
  })
}
