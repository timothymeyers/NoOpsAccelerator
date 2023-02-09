# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

###################################
# Bastion Global Configuration   ##
###################################

variable "resource_group_name" {
  description = "The name of the resource group the Bastion Host resides in"
  type        = string
  default     = ""
}

variable "org_name" {
  description = "A name for the organization. It defaults to anoa."
  type        = string
}

variable "workload_name" {
  description = "A name for the workload. It defaults to 'core'."
  type        = string
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "deploy_environment" {
  description = "The environment to deploy to. It defaults to 'dev'."
  type        = string
  default     = "dev"
}

variable "virtual_network_name" {
  description = "The name of the virtual network the Bastion Host resides in"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
  type        = map(string)
}

#################################
# Bastion Host Configuration
#################################

variable "create_bastion_linux_jumpbox" {
  description = "Create a bastion host and linux jumpbox VM?"
  type        = bool
  default     = true
}

variable "create_bastion_windows_jumpbox" {
  description = "Create a bastion host and windows jumpbox VM?"
  type        = bool
  default     = true
}

variable "bastion_sku" {
  description = "The SKU of the bastion host. Accepted values are Basic and Standard. Defaults to Basic"
  default     = "Basic"
}

variable "subnet_bastion_cidr" {
  description = "CIDR range for the dedicated Bastion subnet. Must be a range available in the VNet."
  type        = string
  default     = "10.0.100.160/27"
}

variable "subnet_bastion_service_endpoints" {
  description = "List of service endpoints to be enabled on the Bastion Host subnet."
  type        = list(string)
  default     = []
}

variable "network_security_group_bastion_id" {
  description = " The id of the network security group to associate with the Bastion Host subnet."
  type        = string
  default     = " "
}

variable "bastion_host_nsg_inbound_rules" {
  type        = list(map(string))
  default     = []
  description = "List of objects that represent the configuration of each inbound rule."
  # inbound_rules = [
  #   {
  #     name                       = ""
  #     priority                   = ""
  #     access                     = ""
  #     protocol                   = ""
  #     source_address_prefix      = ""
  #     source_port_range          = ""
  #     destination_address_prefix = ""
  #     destination_port_range     = ""
  #     description                = ""
  #   }
  # ]
}

variable "bastion_host_nsg_outbound_rules" {
  type        = list(map(string))
  default     = []
  description = "List of objects that represent the configuration of each outbound rule."
  # outbound_rules = [
  #   {
  #     name                       = ""
  #     priority                   = ""
  #     access                     = ""
  #     protocol                   = ""
  #     source_address_prefix      = ""
  #     source_port_range          = ""
  #     destination_address_prefix = ""
  #     destination_port_range     = ""
  #     description                = ""
  #   }
  # ]
}

variable "domain_name_label" {
  description = "Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system"
  default     = null
}

variable "enable_copy_paste" {
  description = "Is Copy/Paste feature enabled for the Bastion Host?"
  default     = true
}

variable "enable_file_copy" {
  description = "Is File Copy feature enabled for the Bastion Host. Only supported whne `sku` is `Standard`"
  default     = false
}

variable "bastion_host_sku" {
  description = "The SKU of the Bastion Host. Accepted values are `Basic` and `Standard`"
  default     = "Basic"
}

variable "enable_ip_connect" {
  description = "Is IP Connect feature enabled for the Bastion Host?"
  default     = false
}

variable "enable_shareable_link" {
  description = "Is Shareable Link feature enabled for the Bastion Host. Only supported whne `sku` is `Standard`"
  default     = false
}

variable "enable_tunneling" {
  description = "Is Tunneling feature enabled for the Bastion Host. Only supported whne `sku` is `Standard`"
  default     = false
}

variable "scale_units" {
  description = "The number of scale units which to provision the Bastion Host. Possible values are between `2` and `50`."
  type        = number
  default     = 2
  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50
    error_message = "The scale_units must be between 2 and 50."
  }
}

################################## 
# Bastion PIP Configuration    ###
##################################

variable "public_ip_allocation_method" {
  description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic"
  default     = "Static"
}

variable "public_ip_sku" {
  description = "The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic"
  default     = "Standard"
}

variable "public_ip_zones" {
  description = "Zones for public IP attached to the Bastion Host. Can be `null` if no zone distpatch."
  type        = list(number)
  default     = [1, 2, 3]
}

##########################################
# Bastion Diagnostics Configuration    ###
##########################################

variable "enable_bastion_diagnostics" {
  description = "Enable diagnostics for the Bastion Host?"
  type        = bool
  default     = true
}

variable "log_analytics_storage_account_id" {
  description = "Specifies the log analytics storage account id"
  type        = string
  default     = ""
}

variable "log_analytics_storage_account_name" {
  description = "Specifies the log analytics storage account name"
  type        = string
  default     = ""
}

variable "log_analytics_resource_id" {
  description = "Specifies the log analytics resource id"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace id"
  type        = string
}

variable "log_analytics_workspace_key" {
  description = "Specifies the log analytics workspace key"
  type        = string
}

##########################################
# Key Vault Jumpbox Configuration       ##
##########################################

variable "use_key_vault" {
  type        = bool
  default     = false
  description = "Set this to true to use a Key Vault to store the SSH public key for the linux VM. If set to false, the public key will be stored in the terraform state file."
}

variable "key_vault_id" {
  type        = string
  default     = ""
  description = "The name of the Key Vault instance where the SSH public key is stored. Just the name of the vault, not the URI"
}


variable "keyvault_name" {
  description = "The name of the keyvault to store the admin password"
  type        = string
  default     = ""
}

#################################
# Jumpbox VM Configuration     ##
#################################

variable "vm_subnet_name" {
  description = "The subnet name of the virtual machine"
  type        = string
  default     = ""
}

variable "use_random_password" {
  description = "Set this to true to use a random password for the windows VM. If set to false, the password will be stored in the terraform state file."
  type        = bool
  default     = true
}

variable "ssh_key_name" {
  type        = string
  default     = ""
  description = "The name of the Key Vault secret that holds the SSH public key to be used"
}

variable "size_linux_jumpbox" {
  description = "The size of the windows virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "size_windows_jumpbox" {
  description = "The size of the windows virtual machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_os_windows_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "vm_os_linux_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "admin_username" {
  description = "The admin username of the linux virtual machine"
  type        = string
  default     = "azure"
}

variable "admin_password" {
  description = "The admin password of the virtual machines"
  type        = string
  default     = ""
  sensitive   = true
}

