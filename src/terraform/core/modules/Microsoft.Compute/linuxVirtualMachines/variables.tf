# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################################################
# VARIABLES                                      #
##################################################
variable "resource_group_name" {
  description = "The name of the resource group the virtual machine resides in"
  type        = string
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "use_key_vault" {
  type        = bool
  default     = false
  description = "Set this to true to use a Key Vault to store the SSH public key"
}

variable "ssh_key_name" {
  type        = string
  default     = ""
  description = "The name of the Key Vault secret that holds the SSH public key to be used"
}

variable "key_vault_id" {
  type        = string
  default     = ""
  description = "The name of the Key Vault instance where the SSH public key is stored. Just the name of the vault, not the URI"
}

variable "virtual_network_name" {
  description = "The name of the virtual network the virtual machine resides in"
  type        = string
}

variable subnet_id {
  description = "(Required) Specifies the resource id of the subnet hosting the virtual machine"
  type        = string
}

variable "network_interface_name" {
  description = "The name of the network interface the virtual machine resides in"
  type        = string
}

variable "network_security_group_name" {
  description = "The name of the network security group the virtual machine resides in"
  type        = string
  default     = ""
}

variable "ip_configuration_name" {
  description = "The name of the ip configuration the virtual machine resides in"
  type        = string
}

/* data_disks = {
      data1 = {
        name                 = "server1-data1"
        storage_account_type = "Standard_LRS"
        # Only Empty is supported. More community contributions required to cover other scenarios
        create_option           = "Empty"
        disk_size_gb            = "10"
        lun                     = 1
        zones                   = ["1"]
        disk_encryption_set_key = "set1"
        caching                 = "ReadWrite"
      }
  } */
variable "data_disks" {
  type        = map(any)
  default     = {}
  description = "If data disks are to be created for this VM, list their sizes here"
}

variable "os_disk_caching" {
  type        = string
  default     = "ReadWrite"
  description = "The caching type for the OS disk. Defaults to ReadWrite. Possible values are None, ReadOnly, and ReadWrite. Defaults to None if not specified."
}

variable "os_disk_storage_account_type" {
  description = "(Optional) Specifies the storage account type of the os disk of the virtual machine"
  default     = "StandardSSD_LRS"
  type        = string

  validation {
    condition = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS",  "Standard_LRS"], var.os_disk_storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

variable "disable_password_authentication" {
  description = "Disable password authentication for the virtual machine"
  type        = bool
  default     = false
}

variable "name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "size" {
  description = "The size of the virtual machine"
  type        = string
}

variable "boot_diagnostics_storage_account" {
  description = "(Optional) The Primary/Secondary Endpoint for the Azure Storage Account (general purpose) which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor."
  default     = null
}

variable "admin_username" {
  description = "The admin username of the virtual machine"
  type        = string
}

variable "admin_password" {
  description = "The admin password of the virtual machine"
  type        = string
  sensitive   = true
}

variable "os_disk_image" {
  type        = map(string)
  description = "(Optional) Specifies the os disk image of the virtual machine"
  default     = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
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

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace id"
  type        = string
}

variable "log_analytics_workspace_key" {
  description = "Specifies the log analytics workspace key"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
  type        = map(string)
}
