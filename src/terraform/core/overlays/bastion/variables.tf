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

variable "subnet_name" {
  description = "(Required) The name of the subnet the Bastion Host resides in"
  type        = string
}

variable "network_security_group_name" {
  description = "The name of the network security group the virtual machine resides in"
  type        = string
  default     = ""
}

variable "org_prefix" {
  description = "A name for the organization. It defaults to anoa."
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

#########################################
# Bastion Resource Locks Configuration ##
#########################################

variable "enable_resource_lock" {
  description = "(Optional) Enable resource locks"
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
  default     = "CanNotDelete"
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

variable "bastion_address_space" {
  description = "The address space to be used for the Bastion Host subnet (must be /27 or larger)."
  type        = string
  default     = "10.0.100.160/27"
}

variable "bastion_subnet_service_endpoints" {
  description = "List of service endpoints to be enabled on the Bastion Host subnet."
  type        = list(string)
  default     = []
}

/* variable "bastion_nsg_rules" {
  description = "A list of maps containing the following keys: name, description, access, priority, protocol, direction, source_port_ranges, source_address_prefix, destination_port_ranges, destination_address_prefix"
  type        = list(object)
  default = [
    {
      name                       = "AllowSshInbound"
      priority                   = "100"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "22"
      destination_port_range     = ""
      source_address_prefix      = "*"
      destination_address_prefix = ""
    },
    {
      name                       = "AllowRdpInbound"
      priority                   = "101"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "3389"
      destination_port_range     = ""
      source_address_prefix      = "*"
      destination_address_prefix = ""
    }
  ]
} */

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

variable "size_jumpbox" {
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

