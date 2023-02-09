# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

###########################
# Global Configuration   ##
###########################

variable "location" {
  description = "Azure region in which instance will be hosted"
  type        = string
}

variable "deploy_environment" {
  description = "Name of the workload's environnement"
  type        = string
}

variable "workload_name" {
  description = "Name of the workload_name"
  type        = string
}

variable "org_name" {
  description = "Name of the organization"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  default     = ""
}

variable "resource_group_name" {
  description = "Name of the workload ressource group"
  type        = string
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

#######################
# VM Configuration   ##
#######################

variable "create_vm_resource_group" {
  description = "Should a resource group be created for the VM? Defaults to false"
  type        = bool
  default     = false
}

variable "random_password_length" {
  description = "The desired length of random password created by this module"
  default     = 24
}

variable "virtual_machine_name" {
  description = "The name of the virtual machine."
  default     = ""
}

variable "instances_count" {
  description = "The number of Virtual Machines required."
  default     = 1
}

variable "virtual_machine_size" {
  description = "The Virtual Machine SKU for the Virtual Machine, Default is Standard_A2_V2"
  default     = "Standard_A2_v2"
}

variable "source_image_id" {
  description = "The ID of an Image which each Virtual Machine should be based on"
  default     = null
}

variable "dedicated_host_id" {
  description = "The ID of a Dedicated Host where this machine should be run on."
  default     = null
}

variable "custom_data" {
  description = "Base64 encoded file of a bash script that gets run once by cloud-init upon VM creation"
  default     = null
}

variable "enable_automatic_updates" {
  description = "Specifies if Automatic Updates are Enabled for the Windows Virtual Machine."
  default     = false
}

variable "enable_encryption_at_host" {
  description = " Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?"
  default     = false
}

variable "license_type" {
  description = "Specifies the type of on-premise license which should be used for this Virtual Machine. Possible values are None, Windows_Client and Windows_Server."
  default     = "None"
}

variable "vm_time_zone" {
  description = "Specifies the Time Zone which should be used by the Virtual Machine"
  default     = null
}

###############################################
# VM Password Authentication Configuration   ##
###############################################

variable "disable_password_authentication" {
  description = "Should Password Authentication be disabled on this Virtual Machine? Defaults to true."
  default     = true
}

variable "admin_username" {
  description = "The username of the local administrator used for the Virtual Machine."
  default     = "azureadmin"
}

variable "admin_password" {
  description = "The Password which should be used for the local-administrator on this Virtual Machine"
  default     = null
}

variable "generate_admin_ssh_key" {
  description = "Generates a secure private key and encodes it as PEM."
  default     = false
}

variable "admin_ssh_key_data" {
  description = "specify the path to the existing SSH key to authenticate Linux virtual machine"
  default     = null
}

variable "managed_identity_type" {
  description = "The type of Managed Identity which should be assigned to the Linux Virtual Machine. Possible values are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`"
  default     = null
}

variable "managed_identity_ids" {
  description = "A list of User Managed Identity ID's which should be assigned to the Linux Virtual Machine."
  default     = null
}

variable "identity" {
  description = "Map with identity block informations as described here https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#identity"
  type = object({
    type         = string
    identity_ids = list(string)
  })
  default = {
    type         = "SystemAssigned"
    identity_ids = []
  }
}

###########################
# VM SSH Configuration   ##
###########################

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
  default     = null
}

variable "ssh_private_key" {
  description = "SSH private key"
  type        = string
  default     = null
}

###############################
# VM Network Configuration   ##
###############################

variable "vm_subnet_name" {
  description = "Name of the Subnet in which create the Virtual Machine"
  type        = string
}

variable "nic_enable_accelerated_networking" {
  description = "Should Accelerated Networking be enabled? Defaults to `false`."
  type        = bool
  default     = false
}

variable "nic_nsg_id" {
  description = "NSG ID to associate on the Network Interface. No association if null."
  type        = string
  default     = null
}

variable "static_private_ip" {
  description = "Static private IP. Private IP is dynamic if not set."
  type        = string
  default     = null
}

###########################
# VM Dns Configuration   ##
###########################

variable "domain_name_label" {
  description = "Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default     = null
}

variable "dns_servers" {
  description = "List of dns servers to use for network interface"
  default     = []
}

variable "enable_accelerated_networking" {
  description = "Should Accelerated Networking be enabled? Defaults to false."
  default     = false
}

variable "internal_dns_name_label" {
  description = "The (relative) DNS Name used for internal communications between Virtual Machines in the same Virtual Network."
  default     = null
}

###########################
# VM PIP Configuration   ##
###########################

variable "enable_public_ip_address" {
  description = "Reference to a Public IP Address to associate with the NIC"
  default     = null
}

variable "enable_ip_forwarding" {
  description = "Should IP Forwarding be enabled? Defaults to false"
  default     = false
}

variable "public_ip_allocation_method" {
  description = "Defines the allocation method for this IP address. Possible values are `Static` or `Dynamic`"
  default     = "Static"
}

variable "public_ip_sku" {
  description = "SKU for the public IP attached to the VM. Can be `null` if no public IP needed."
  default     = "Standard"
}

variable "public_ip_sku_tier" {
  description = "The SKU Tier that should be used for the Public IP. Possible values are `Regional` and `Global`"
  default     = "Regional"
}

variable "public_ip_availability_zone" {
  description = "Zones for public IP attached to the VM. Can be `null` if no zone distpatch."
  type        = list(number)
  default     = [1, 2, 3]
}

variable "private_ip_address_allocation_type" {
  description = "The allocation method used for the Private IP Address. Possible values are Dynamic and Static."
  default     = "Dynamic"
}

variable "private_ip_address" {
  description = "The Static IP Address which should be used. This is valid only when `private_ip_address_allocation` is set to `Static` "
  default     = null
}

#####################################
# VM Load Balancer Configuration   ##
#####################################

variable "attach_load_balancer" {
  description = "True to attach this VM to a Load Balancer"
  type        = bool
  default     = false
}

variable "load_balancer_backend_pool_id" {
  description = "Id of the Load Balancer Backend Pool to attach the VM."
  type        = string
  default     = null
}

###########################################
# VM Application Gateway Configuration   ##
###########################################

variable "attach_application_gateway" {
  description = "True to attach this VM to an Application Gateway"
  type        = bool
  default     = false
}

variable "application_gateway_backend_pool_id" {
  description = "Id of the Application Gateway Backend Pool to attach the VM."
  type        = string
  default     = null
}

####################################
# VM Availability Configuration   ##
####################################

variable "enable_vm_availability_set" {
  description = "Manages an Availability Set for Virtual Machines."
  default     = false
}

variable "enable_proximity_placement_group" {
  description = "Manages a proximity placement group for virtual machines, virtual machine scale sets and availability sets."
  default     = false
}

variable "platform_fault_domain_count" {
  description = "Specifies the number of fault domains that are used"
  default     = 2
}
variable "platform_update_domain_count" {
  description = "Specifies the number of update domains that are used"
  default     = 5
}

variable "vm_availability_zone" {
  description = "The Zone in which this Virtual Machine should be created. Conflicts with availability set and shouldn't use both"
  default     = null
}

###########################
# VM NSG Configuration   ##
###########################

variable "existing_network_security_group_id" {
  description = "The resource id of existing network security group"
  default     = null
}

#############################
# VM Image Configuration   ##
#############################

variable "custom_image" {
  description = "Provide the custom image to this module if the default variants are not sufficient"
  type = map(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))
  default = null
}

variable "windows_distribution_list" {
  description = "Pre-defined Azure Windows VM images list"
  type = map(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))

  default = {
    windows2012r2dc = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2012-R2-Datacenter"
      version   = "latest"
    },

    windows2016dc = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter"
      version   = "latest"
    },

    windows2019dc = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    },

    windows2019dc-gensecond = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-datacenter-gensecond"
      version   = "latest"
    },

    windows2019dc-gs = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-datacenter-gs"
      version   = "latest"
    },

    windows2019dc-containers = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter-with-Containers"
      version   = "latest"
    },

    windows2019dc-containers-g2 = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-datacenter-with-containers-g2"
      version   = "latest"
    },

    windows2019dccore = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter-Core"
      version   = "latest"
    },

    windows2019dccore-g2 = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-datacenter-core-g2"
      version   = "latest"
    },

    windows2016dccore = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter-Server-Core"
      version   = "latest"
    },

    mssql2017exp = {
      publisher = "MicrosoftSQLServer"
      offer     = "SQL2017-WS2019"
      sku       = "express"
      version   = "latest"
    },

    mssql2017dev = {
      publisher = "MicrosoftSQLServer"
      offer     = "SQL2017-WS2019"
      sku       = "sqldev"
      version   = "latest"
    },

    mssql2017std = {
      publisher = "MicrosoftSQLServer"
      offer     = "SQL2017-WS2019"
      sku       = "standard"
      version   = "latest"
    },

    mssql2017ent = {
      publisher = "MicrosoftSQLServer"
      offer     = "SQL2017-WS2019"
      sku       = "enterprise"
      version   = "latest"
    },

    mssql2019std = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "standard"
      version   = "latest"
    },

    mssql2019dev = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "sqldev"
      version   = "latest"
    },

    mssql2019ent = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "enterprise"
      version   = "latest"
    },

    mssql2019ent-byol = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019-byol"
      sku       = "enterprise"
      version   = "latest"
    },

    mssql2019std-byol = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019-byol"
      sku       = "standard"
      version   = "latest"
    }
  }
}

variable "windows_distribution_name" {
  default     = "windows2019dc"
  description = "Variable to pick an OS flavour for Windows based VM. Possible values include: winserver, wincore, winsql"
}

#####################################
# VM Data Storage Configuration    ##
#####################################

variable "os_disk_storage_account_type" {
  description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values include Standard_LRS, StandardSSD_LRS and Premium_LRS."
  default     = "StandardSSD_LRS"
}

variable "os_disk_caching" {
  description = "The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`"
  default     = "ReadWrite"
}

variable "disk_encryption_set_id" {
  description = "The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. The Disk Encryption Set must have the `Reader` Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault"
  default     = null
}

variable "disk_size_gb" {
  description = "The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from."
  default     = null
}

variable "enable_os_disk_write_accelerator" {
  description = "Should Write Accelerator be Enabled for this OS Disk? This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`."
  default     = false
}

variable "os_disk_name" {
  description = "The name which should be used for the Internal OS Disk"
  default     = null
}

variable "enable_ultra_ssd_data_disk_storage_support" {
  description = "Should the capacity to enable Data Disks of the UltraSSD_LRS storage account type be supported on this Virtual Machine"
  default     = false
}

variable "winrm_protocol" {
  description = "Specifies the protocol of winrm listener. Possible values are `Http` or `Https`"
  default     = null
}

variable "key_vault_certificate_secret_url" {
  description = "The Secret URL of a Key Vault Certificate, which must be specified when `protocol` is set to `Https`"
  default     = null
}

variable "additional_unattend_content" {
  description = "The XML formatted content that is added to the unattend.xml file for the specified path and component."
  default     = null
}

variable "additional_unattend_content_setting" {
  description = "The name of the setting to which the content applies. Possible values are `AutoLogon` and `FirstLogonCommands`"
  default     = null
}

variable "enable_boot_diagnostics" {
  description = "Should the boot diagnostics enabled?"
  default     = false
}

variable "data_disks" {
  description = "A list of Data Disks which should be attached to the Virtual Machine. Each Data Disk can be configured with the following properties:"
  type = map(object({
    name                 = optional(string)
    create_option        = optional(string, "Empty")
    disk_size_gb         = number
    lun                  = optional(number)
    caching              = optional(string, "ReadWrite")
    storage_account_type = optional(string, "StandardSSD_ZRS")
    source_resource_id   = optional(string)
    extra_tags           = optional(map(string), {})
  }))
  default = {}
}

#####################################
# VM log analytics Configuration   ##
#####################################

variable "nsg_diag_logs" {
  description = "NSG Monitoring Category details for Azure Diagnostic setting"
  default     = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
}

variable "log_analytics_resource_id" {
  description = "The name of log analytics workspace resource id"
  default     = null
}

variable "log_analytics_customer_id" {
  description = "The Workspace (or Customer) ID for the Log Analytics Workspace."
  default     = null
}

variable "log_analytics_workspace_primary_shared_key" {
  description = "The Primary shared key for the Log Analytics Workspace"
  default     = null
}

variable "storage_account_name" {
  description = "The name of the hub storage account to store logs"
  default     = null
}

variable "storage_account_uri" {
  description = "The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor. Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics."
  default     = null
}

variable "deploy_log_analytics_agent" {
  description = "Install log analytics agent to windows or linux VM"
  default     = false
}

##############################
# VM Backup Configuration   ##
##############################

variable "backup_policy_id" {
  description = "Backup policy ID from the Recovery Vault to attach the Virtual Machine to (value to `null` to disable backup)"
  type        = string
  default     = null
}

variable "patch_mode" {
  description = "Specifies the mode of in-guest patching to Linux or Windows Virtual Machine. Possible values are `Manual`, `AutomaticByOS` and `AutomaticByPlatform`"
  default     = "AutomaticByPlatform"
}


