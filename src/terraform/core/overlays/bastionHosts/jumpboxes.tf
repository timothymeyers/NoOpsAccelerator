# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
#
# Linux Jumpbox
#
#
module "mod_linux_jumpbox" {
  count = var.create_bastion_linux_jumpbox ? 1 : 0

  depends_on = [azurerm_bastion_host.main]
  source     = "../virtualMachines/linux"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = data.azurerm_resource_group.rg.name
  location             = var.location
  deploy_environment   = var.deploy_environment
  org_name             = var.org_name
  workload_name        = "jumpbox-linux"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  vm_subnet_name       = var.vm_subnet_name
  virtual_machine_name = "linux"

  # This module support multiple Pre-Defined Linux and Windows Distributions.
  # Check the README.md file for more pre-defined images for Ubuntu, Centos, RedHat.
  # Please make sure to use gen2 images supported VM sizes if you use gen2 distributions
  # Specify `disable_password_authentication = false` to create random admin password
  # Specify a valid password with `admin_password` argument to use your own password 
  # To generate SSH key pair, specify `generate_admin_ssh_key = true`
  # To use existing key pair, specify `admin_ssh_key_data` to a valid SSH public key path.
  # Specify instance_count = 1 to create a single instance, or specify a higher number to create multiple instances  
  linux_distribution_name         = "ubuntu2004"
  virtual_machine_size            = var.size_linux_jumpbox
  admin_username                  = var.admin_username
  disable_password_authentication = true
  generate_admin_ssh_key          = true
  instances_count                 = 1

  # Proxymity placement group, Availability Set and adding Public IP to VM's are optional.
  # remove these argument from module if you dont want to use it.  
  enable_proximity_placement_group = false
  enable_vm_availability_set       = false
  enable_public_ip_address         = false  

  # Network Seurity group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.
  # Remove this NSG rules block, if `existing_network_security_group_id` is specified
  existing_network_security_group_id = var.network_security_group_bastion_id

  # Boot diagnostics to troubleshoot virtual machines, by default uses managed 
  # To use custom storage account, specify `storage_account_name` with a valid name
  # Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics
  enable_boot_diagnostics = var.enable_bastion_diagnostics
  storage_account_name    = var.log_analytics_storage_account_name

  # Attach a managed data disk to a Windows/Linux VM's. Possible Storage account type are: 
  # `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `Premium_ZRS`, `StandardSSD_LRS`
  # or `UltraSSD_LRS` (UltraSSD_LRS only available in a region that support availability zones)
  # Initialize a new data disk - you need to connect to the VM and run diskmanagemnet or fdisk
  data_disks = {
    disk1 = {
      name                 = "linux_data_disk1"
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
  deploy_log_analytics_agent                 = var.enable_bastion_diagnostics
  log_analytics_customer_id                  = var.log_analytics_workspace_id
  log_analytics_workspace_primary_shared_key = var.log_analytics_workspace_key

  // Tags
  extra_tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Linux VM for Azure Bastion %s", coalesce(var.custom_bastion_name, data.azurenoopsutils_resource_name.bastion.result))
  })
}

#
#
# Windows Jumpbox
#
#
module "mod_windows_jumpbox" {
  count = var.create_bastion_windows_jumpbox ? 1 : 0

  depends_on = [azurerm_bastion_host.main]
  source     = "../virtualMachines/windows"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = data.azurerm_resource_group.rg.name
  location             = var.location
  deploy_environment   = var.deploy_environment
  org_name             = var.org_name
  workload_name        = "jumpbox-win"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  vm_subnet_name       = var.vm_subnet_name
  virtual_machine_name = "windows"

  # This module support multiple Pre-Defined Linux and Windows Distributions.
  # Check the README.md file for more pre-defined images for Ubuntu, Centos, RedHat.
  # Please make sure to use gen2 images supported VM sizes if you use gen2 distributions
  # Specify `admin_username = null` to create random admin password
  # Specify a valid password with `admin_password` argument to use your own password, 
  # if not specified, a random password will be generated   
  # Specify instance_count = 1 to create a single instance, or specify a higher number to create multiple instances
  windows_distribution_name       = "windows2019dc"
  virtual_machine_size            = var.size_windows_jumpbox
  admin_username                  = var.admin_username  
  disable_password_authentication = false
  instances_count                 = 1

  # Proxymity placement group, Availability Set and adding Public IP to VM's are optional.
  # remove these argument from module if you dont want to use it.  
  enable_proximity_placement_group = false
  enable_vm_availability_set       = false
  enable_public_ip_address         = false

  # Network Seurity group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.
  # Remove this NSG rules block, if `existing_network_security_group_id` is specified
  existing_network_security_group_id = var.network_security_group_bastion_id

  # Boot diagnostics to troubleshoot virtual machines, by default uses managed 
  # To use custom storage account, specify `storage_account_name` with a valid name
  # Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics
  enable_boot_diagnostics = var.enable_bastion_diagnostics
  storage_account_name    = var.log_analytics_storage_account_name

  # Attach a managed data disk to a Windows/Linux VM's. Possible Storage account type are: 
  # `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `Premium_ZRS`, `StandardSSD_LRS`
  # or `UltraSSD_LRS` (UltraSSD_LRS only available in a region that support availability zones)
  # Initialize a new data disk - you need to connect to the VM and run diskmanagemnet or fdisk
  data_disks = {
    disk1 = {
      name                 = "win_data_disk1"
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
  deploy_log_analytics_agent                 = var.enable_bastion_diagnostics
  log_analytics_customer_id                  = var.log_analytics_workspace_id
  log_analytics_workspace_primary_shared_key = var.log_analytics_workspace_key

  // Tags
  extra_tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Windows VM for Azure Bastion %s", coalesce(var.custom_bastion_name, data.azurenoopsutils_resource_name.bastion.result))
  })
}
