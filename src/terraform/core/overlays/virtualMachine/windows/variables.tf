# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group the virtual machine resides in"
  type        = string
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network the virtual machine resides in"
  type        = string
}

variable subnet_id {
  description = "(Required) The name of the subnet the virtual machine resides in"
  type        = string
}

variable "network_interface_name" {
  description = "The name of the network interface the virtual machine resides in"
  type        = string
}

variable "network_security_group_name" {
  description = "The name of the network security group the virtual machine resides in"
  type        = string
  default = ""
}

variable "ip_configuration_name" {
  description = "The name of the ip configuration the virtual machine resides in"
  type        = string
}

variable "use_random_password" {
  description = "Specifies whether a random password should be generated for the virtual machine. If set to false, an admin_password must be specified."
  type        = bool
  default     = true
}

variable "vm_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default     = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

variable "size" {
  description = "The size of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "The admin username of the virtual machine"
  type        = string
  default = ""
}

variable "admin_password" {
  description = "The admin password of the virtual machine"
  type        = string
  sensitive   = true
  default = ""
}

variable "use_key_vault" {
  type = bool
  default = false
  description = "Set this to true to use a Key Vault to store the SSH public key"
}

variable "pwd_key_name" {
  type = string
  default = ""
  description = "The name of the Key Vault secret that holds the SSH public key to be used"
}

variable "key_vault_id" {
  type = string
  default = ""
  description = "The name of the Key Vault instance where the SSH public key is stored. Just the name of the vault, not the URI"
}

variable "script_storage_account_name" {
  description = "(Optional) Specifies the name of the storage account that contains the custom script."
  type        = string
  default     = ""
}

variable "script_storage_account_key" {
  description = "(Optional) Specifies the name of the storage account that contains the custom script."
  type        = string
  default     = ""
}

variable "container_name" {
  description = "(Optional) Specifies the name of the container that contains the custom script."
  type        = string
  default     = ""
}

variable "script_name" {
  description = "(Optional) Specifies the name of the custom script."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
  type        = map(string)
}

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace id"
  type        = string
}

variable "log_analytics_workspace_key" {
  description = "Specifies the log analytics workspace key"
  type        = string
}
