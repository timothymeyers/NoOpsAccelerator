
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#################################
# Global Configuration
#################################

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)
  default = {
    "Organization" : "anoa",
    "Region" : "eastus",
    "DeployEnvironment" : "dev"
  }
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

###################################
# Resource Locks
###################################

variable "enable_resource_locks" {
  description = "(Optional) Specifies if a lock should be applied to the Resources."
  type        = bool
  default     = true
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
  default     = "CanNotDelete"
}

#################################
# Hun Configuration
#################################

variable "hub_resource_group_name" {
  description = "Resource Group name for the Hub Virtual Network deployment"
  type        = string
  default     = ""
}

variable "hub_virtual_network_name" {
  description = "Virtual Network name for the Hub Virtual Network deployment"
  type        = string
  default     = ""
}

#################################
# Spokes Configuration
#################################

#################################
# Operarions Configuration
#################################

variable "wl_subid" {
  description = "Subscription ID for the Operations Virtual Network deployment"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.wl_subid)) || var.wl_subid == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "wl_resource_group_name" {
  description = "Resource Group name for the Hub Virtual Network deployment"
  type        = string  
}

variable "wl_virtual_network_name" {
  description = "Virtual Network name for the Operations Virtual Network deployment"
  type        = string
}

variable "wl_network_security_group_name" { 
  description = "Network Security Group name for the Operations Virtual Network deployment"
  type        = string 
}

variable "wl_route_table_name" { 
  description = "Route Table name for the Operations Virtual Network deployment"
  type        = string
}

variable "wl_spoke_vnet_address_space" {
  description = "Address space prefixes for the Operations Virtual Network"
  type        = list(string)
}

variable "wl_spoke_subnets" {
  description = "A complex object that describes subnets for the Operations Virtual Network"
  type = map(object({
    subnet_name          = string
    subnet_address_space = list(string)
    service_endpoints    = list(string)

    enforce_private_link_endpoint_network_policies = bool
    enforce_private_link_service_network_policies  = bool

    network_security_group_rules = map(object({
      name                       = string
      priority                   = string
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = list(string)
      source_address_prefix      = list(string)
      destination_address_prefix = string
    }))
    enable_ddos_protection  = bool
    ddos_protection_plan_id = string
  }))  
}

variable "wl_log_storage_account_name" { 
  description = "Storage Account name for the Workload Virtual Network deployment"
  type        = string  
}

variable "wl_logging_storage_account_config" {
  description = "Storage Account variables for the Workload Virtual Network deployment"
  type = object({
    sku_name                 = string
    kind                     = string
    min_tls_version          = string
    account_replication_type = string
  })  
}

##################################
# Network Peering Configuration ##
##################################

variable "peer_to_hub_virtual_network" {
  description = "A boolean value to indicate if the Virtual Network should peer to the hub Virtual Network."
  type        = bool
  default     = true
}

variable "allow_virtual_network_access" {
  description = "Allow access from the remote virtual network to use this virtual network's gateways. Defaults to false."
  type        = bool
  default     = true
}

variable "use_remote_gateways" {
  description = "Use remote gateways from the remote virtual network. Defaults to false."
  type        = bool
  default     = false
}

#####################################
# Firewall configuration section   ##
#####################################

variable "firewall_private_ip" {
  description = "The private IP address of the firewall"
  type        = string
  default     = ""
}

####################################################
# Azure Container Registry configuration section  ##
####################################################
variable "acr_name" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "BaboAcr"
}

variable "acr_sku" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "Premium"

  validation {
    condition = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "The container registry sku is invalid."
  }
}

variable "acr_admin_enabled" {
  description = "Specifies whether admin is enabled for the container registry"
  type        = bool
  default     = true
}

variable "acr_georeplication_locations" {
  description = "(Optional) A list of Azure locations where the container registry should be geo-replicated."
  type        = list(string)
  default     = []
}

####################################################
# Azure Kuvernates Cluster configuration section  ##
####################################################
variable "aks_vnet_name" {
  description = "Specifies the name of the AKS subnet"
  default     = "AksVNet"
  type        = string
}

variable "aks_vnet_address_space" {
  description = "Specifies the address prefix of the AKS subnet"
  default     =  ["10.0.0.0/16"]
  type        = list(string)
}

variable "aks_cluster_name" {
  description = "(Required) Specifies the name of the AKS cluster."
  default     = "BaboAks"
  type        = string
}

variable "role_based_access_control_enabled" {
  description = "(Required) Is Role Based Access Control Enabled? Changing this forces a new resource to be created."
  default     = true
  type        = bool
}

variable "automatic_channel_upgrade" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, and stable."
  default     = "stable"
  type        = string

  validation {
    condition = contains( ["patch", "rapid", "stable"], var.automatic_channel_upgrade)
    error_message = "The upgrade mode is invalid."
  }
}

variable "admin_group_object_ids" {
  description = "(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
  default     = ["6e5de8c1-5a4b-409b-994f-0706e4403b77", "78761057-c58c-44b7-aaa7-ce1639c6c4f5"]
  type        = list(string)
}

variable "azure_rbac_enabled" {
  description = "(Optional) Is Role Based Access Control based on Azure AD enabled?"
  default     = true
  type        = bool
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free."
  default     = "Free"
  type        = string

  validation {
    condition = contains( ["Free", "Paid"], var.sku_tier)
    error_message = "The sku tier is invalid."
  }
}

variable "kubernetes_version" {
  description = "Specifies the AKS Kubernetes version"
  default     = "1.21.1"
  type        = string
}

variable "default_node_pool_vm_size" {
  description = "Specifies the vm size of the default node pool"
  default     = "Standard_F8s_v2"
  type        = string
}

variable "default_node_pool_availability_zones" {
  description = "Specifies the availability zones of the default node pool"
  default     = ["1", "2", "3"]
  type        = list(string)
}

variable "network_docker_bridge_cidr" {
  description = "Specifies the Docker bridge CIDR"
  default     = "172.17.0.1/16"
  type        = string
}

variable "network_dns_service_ip" {
  description = "Specifies the DNS service IP"
  default     = "10.2.0.10"
  type        = string
}

variable "network_service_cidr" {
  description = "Specifies the service CIDR"
  default     = "10.2.0.0/24"
  type        = string
}

variable "network_plugin" {
  description = "Specifies the network plugin of the AKS cluster"
  default     = "azure"
  type        = string
}

variable "default_node_pool_name" {
  description = "Specifies the name of the default node pool"
  default     =  "system"
  type        = string
}

variable "default_node_pool_subnet_name" {
  description = "Specifies the name of the subnet that hosts the default node pool"
  default     =  "SystemSubnet"
  type        = string
}

variable "default_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the default node pool"
  default     =  ["10.0.0.0/21"]
  type        = list(string)
}

variable "default_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type          = bool
  default       = true
}

variable "default_node_pool_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type          = bool
  default       = false
}

variable "default_node_pool_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type          = bool
  default       = false
}

variable "default_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type          = number
  default       = 50
}

variable "default_node_pool_node_labels" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type          = map(any)
  default       = {}
}

variable "default_node_pool_node_taints" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type          = list(string)
  default       = []
}

variable "default_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type          = string
  default       = "Ephemeral"
}

variable "default_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type          = number
  default       = 10
}

variable "default_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type          = number
  default       = 3
}

variable "default_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type          = number
  default       = 3
}

variable "additional_node_pool_subnet_name" {
  description = "Specifies the name of the subnet that hosts the default node pool"
  default     =  "UserSubnet"
  type        = string
}

variable "additional_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the additional node pool"
  type        = list(string)
  default     = ["10.0.16.0/20"]
}

variable "additional_node_pool_name" {
  description = "(Required) Specifies the name of the node pool."
  type        = string
  default     = "user"
}

variable "additional_node_pool_vm_size" {
  description = "(Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard_F8s_v2"
}

variable "additional_node_pool_availability_zones" {
  description = "(Optional) A list of Availability Zones where the Nodes in this Node Pool should be created in. Changing this forces a new resource to be created."
  type        = list(string)
  default = ["1", "2", "3"]
}

variable "additional_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type          = bool
  default       = true
}

variable "additional_node_pool_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type          = bool
  default       = false
}

variable "additional_node_pool_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type          = bool
  default       = false
}

variable "additional_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type          = number
  default       = 50
}

variable "additional_node_pool_mode" {
  description = "(Optional) Should this Node Pool be used for System or User resources? Possible values are System and User. Defaults to User."
  type          = string
  default       = "User"
}

variable "additional_node_pool_node_labels" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type          = map(any)
  default       = {}
}

variable "additional_node_pool_node_taints" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type          = list(string)
  default       = ["CriticalAddonsOnly=true:NoSchedule"]
}

variable "additional_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type          = string
  default       = "Ephemeral"
}

variable "additional_node_pool_os_type" {
  description = "(Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are Linux and Windows. Defaults to Linux."
  type          = string
  default       = "Linux"
}

variable "additional_node_pool_priority" {
  description = "(Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
  type          = string
  default       = "Regular"
}

variable "additional_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type          = number
  default       = 10
}

variable "additional_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type          = number
  default       = 3
}

variable "additional_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type          = number
  default       = 3
}

######################################
# VM Jumpbox configuration section  ##
######################################
variable "vm_name" {
  description = "Specifies the name of the jumpbox virtual machine"
  default     = "aks-jumpbox"
  type        = string
}

variable "vm_public_ip" {
  description = "(Optional) Specifies whether create a public IP for the virtual machine"
  type = bool
  default = false
}

variable "vm_size" {
  description = "Specifies the size of the jumpbox virtual machine"
  default     = "Standard_DS1_v2"
  type        = string
}

variable "vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type of the os disk of the jumpbox virtual machine"
  default     = "Premium_LRS"
  type        = string

  validation {
    condition = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS",  "Standard_LRS"], var.vm_os_disk_storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

// Use the following code if you want to use a Data Science Virtual Machine
variable "vm_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default     = {
    publisher = "microsoft-dsvm"
    offer     = "ubuntu-2004"
    sku       = "2004-gen2"
    version   = "latest"
  }
}

// if you want to use a custom image, you can use the following code
/* variable "vm_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default     = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
} */

variable "vm_subnet_name" {
  description = "Specifies the name of the jumpbox subnet"
  default     = "VmSubnet"
  type        = string
}

variable "vm_subnet_address_prefix" {
  description = "Specifies the address prefix of the jumbox subnet"
  default     = ["10.0.8.0/21"]
  type        = list(string)
}

variable "domain_name_label" {
  description = "Specifies the domain name for the jumbox virtual machine"
  default     = "babotestvm"
  type        = string
}

variable "storage_account_tier" {
  description = "(Optional) Specifies the account tier of the storage account"
  default     = "Standard"
  type        = string

   validation {
    condition = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "The account tier of the storage account is invalid."
  }
}

variable "admin_username" {
  description = "(Required) Specifies the admin username of the jumpbox virtual machine and AKS worker nodes."
  type        = string
  default     = "azadmin"
}

variable "ssh_public_key" {
  description = "(Required) Specifies the SSH public key for the jumpbox virtual machine and AKS worker nodes."
  type        = string
  default = ""
}

variable "script_storage_account_name" {
  description = "(Required) Specifies the name of the storage account that contains the custom script."
  type        = string
  default = ""
}

variable "script_storage_account_key" {
  description = "(Required) Specifies the name of the storage account that contains the custom script."
  type        = string
  default = ""
}

variable "container_name" {
  description = "(Required) Specifies the name of the container that contains the custom script."
  type        = string
  default     = "scripts"
}

variable "script_name" {
  description = "(Required) Specifies the name of the custom script."
  type        = string
  default     = "configure-jumpbox-vm.sh"
}
