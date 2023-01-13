
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#################################
# Global Configuration
#################################

variable "required" {
  description = "A map of required variables for the deployment"
  default = {
    org_prefix         = "anoa"
    deploy_environment = "dev"
  }
}

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)
  default = {
    "Organization" : "anoa",
    "Region" : "eastus",
    "DeployEnvironment" : "dev"
  }
}

variable "environment" {
  description = "The Terraform backend environment e.g. public or usgovernment"
  type        = string
}

variable "metadata_host" {
  description = "The metadata host for the Azure Cloud e.g. management.azure.com or management.usgovcloudapi.net."
  type        = string
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
# Hub Configuration
#################################

variable "hub_subscription_id" {
  description = "Subscription ID for the Hub deployment"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.hub_subscription_id)) || var.hub_subscription_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "hub_resource_group_name" {
  description = "Resource Group name for the Hub Virtual Network deployment"
  type        = string
  default     = ""
}

variable "hub_virtual_network_id" {
  description = "Virtual Network id for the Hub Virtual Network deployment"
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
# Workload Configuration
#################################

variable "wl_subscription_id" {
  description = "Subscription ID for the Development Environment Virtual Network deployment"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.wl_subscription_id)) || var.wl_subscription_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "wl_resource_group_name" {
  description = "Resource Group name for the Hub Virtual Network deployment"
  type        = string
}

variable "wl_virtual_network_name" {
  description = "Virtual Network name for the Development Environment Virtual Network deployment"
  type        = string
}

variable "wl_network_security_group_name" {
  description = "Network Security Group name for the Development Environment Virtual Network deployment"
  type        = string
}

variable "wl_route_table_name" {
  description = "Route Table name for the Development Environment Virtual Network deployment"
  type        = string
}

variable "wl_spoke_vnet_address_space" {
  description = "Address space prefixes for the Development Environment Virtual Network"
  type        = list(string)
}

variable "wl_spoke_subnets" {
  description = "A complex object that describes subnets for the Development Environment Virtual Network"
  type = list(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = list(string)

    enforce_private_link_endpoint_network_policies = bool
    enforce_private_link_service_network_policies  = bool
  }))
}

variable "wl_network_security_group_rules" {
  description = "A complex object that describes network security group rules for the spoke network"
  type = map(object({
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
}

variable "wl_log_storage_account_name" {
  description = "Storage Account name for the Development Environment Virtual Network deployment"
  type        = string
}

variable "wl_logging_storage_account_config" {
  description = "Storage Account variables for the Development Environment Virtual Network deployment"
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
  default     = "Acr"
}

variable "acr_sku" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
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

variable "acr_dns_virtual_networks_to_link" {
  type        = list(string)
  description = "(Optional) A list of Virtual Network IDs to link to the Azure Container Registry DNS Zone. Changing this forces a new resource to be created."
  default     = []
}  

####################################################
# Azure Kuvernates Cluster configuration section  ##
####################################################
variable "aks_prefix_name" {
  description = "Specifies the prefix of the AKS cluster"
  type        = string
  default     = "msft"
}

variable "agents_max_count" {
  type        = number
  description = "Maximum number of nodes in a pool"
  default     = 10
}

variable "agents_min_count" {
  type        = number
  description = "Minimum number of nodes in a pool"
  default     = 3
}

variable "use_user_defined_identity" {
  type        = bool
  description = "Use user defined identity"
  default     = true
}

variable "enable_container_pull" {
  description = "(Optional) Should the cluster pull container images from the Azure Container Registry specified by the `var.acr_name` variable? Defaults to `true`."
  default     = true
  type        = bool
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free."
  default     = "Free"
  type        = string

  validation {
    condition     = contains(["Free", "Paid"], var.sku_tier)
    error_message = "The sku tier is invalid."
  }
}

variable "control_plane_kubernetes_version" {
  description = "Specifies the AKS Kubernetes version"
  default     = "1.23.12"
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

variable "net_profile_docker_bridge_cidr" {
  description = "Specifies the Docker bridge CIDR"
  default     = "172.18.0.1/16"
  type        = string
}

variable "net_profile_dns_service_ip" {
  description = "Specifies the DNS service IP"
  default     = "172.16.0.10"
  type        = string
}

variable "net_profile_service_cidr" {
  description = "Specifies the service CIDR"
  default     = "172.16.0.0/16"
  type        = string
}

variable "net_profile_pod_cidr" {
  description = "Specifies the service CIDR"
  default     = "172.15.0.0/16"
  type        = string
}

variable "network_plugin" {
  description = "Specifies the network plugin of the AKS cluster"
  default     = "kubenet"
  type        = string
}

variable "private_cluster_enabled" {
  type    = bool
  default = false
}

variable "enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = true
}

variable "agent_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 50
}

variable "agent_node_labels" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = map(any)
  default     = {}
}

variable "agent_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Ephemeral"
}

variable "agent_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type        = number
  default     = 3
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
  type        = bool
  default     = false
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
    condition     = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Standard_LRS"], var.vm_os_disk_storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

// Use the following code if you want to use a Data Science Virtual Machine
variable "vm_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default = {
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
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
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
  default     = ""
}

variable "script_storage_account_name" {
  description = "(Required) Specifies the name of the storage account that contains the custom script."
  type        = string
  default     = ""
}

variable "script_storage_account_key" {
  description = "(Required) Specifies the name of the storage account that contains the custom script."
  type        = string
  default     = ""
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
