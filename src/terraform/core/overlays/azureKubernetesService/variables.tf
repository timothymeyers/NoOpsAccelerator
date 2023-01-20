# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################################################
# Global Configuration                           #
##################################################
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
  description = "Specifies the name of the virtual network to use for the jumpbox"
  default     = "JumpboxVnet"
  type        = string
}

variable "resource_group_name" {
  description = "Specifies the resource group name"
  default     = "rG"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
  type        = map(string)
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

variable "enable_container_pull" {
  description = "(Optional) Should the cluster pull container images from the Azure Container Registry specified by the `var.acr_name` variable? Defaults to `true`."
  default     = false
  type        = bool
}

variable "acr_pe_vnet_subnet_id" {
  type        = string
  description = "(Optional) The ID of a Subnet where the Private Endpoint for the Azure Container Registry should exist. Changing this forces a new resource to be created."
  default     = null
}

variable "acr_dns_virtual_networks_to_link" {
  description = "(Optional) Specifies the subscription id, resource group name, and name of the virtual networks to which create a virtual network link for private dns zone"
  type        = map(any)
  default     = {}
}

#############################
# AKS Configuration         #
#############################

variable "aks_name" {
  description = "Specifies the prefix of the AKS cluster"
  type        = string
  default     = "msft"
}

variable "aks_node_pool_vnet_subnet_id" {
  type        = string
  description = "(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created."
  default     = null
}

variable "managed_identity_principal_id" {
  type    = string
  default = null
}

variable "network_plugin" {
  type    = string
  default = "kubenet"
}

variable "microsoft_defender_enabled" {
  type        = bool
  description = "(Optional) Is Microsoft Defender on the cluster enabled? Requires `var.log_analytics_workspace_enabled` to be `true` to set this variable to `true`."
  default     = false
  nullable    = false
}

variable "net_profile_dns_service_ip" {
  type        = string
  description = "(Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created."
  default     = null
}

variable "net_profile_docker_bridge_cidr" {
  type        = string
  description = "(Optional) IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Changing this forces a new resource to be created."
  default     = null
}

variable "net_profile_outbound_type" {
  type        = string
  description = "(Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer."
  default     = "loadBalancer"
}

variable "net_profile_pod_cidr" {
  type        = string
  description = " (Optional) The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet. Changing this forces a new resource to be created."
  default     = null
}

variable "net_profile_service_cidr" {
  type        = string
  description = "(Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
  default     = null
}

variable "agents_max_count" {
  type        = number
  description = "Maximum number of nodes in a pool"
  default     = null
}

variable "agents_min_count" {
  type        = number
  description = "Min number of nodes in a pool"
  default     = null
}

variable "control_plane_kubernetes_version" {
  type    = string
  default = "1.24.3"
}

variable "identity_type" {
  type        = string
  description = "(Optional) The type of identity used for the managed cluster. Conflict with `client_id` and `client_secret`. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`(to enable both). If `UserAssigned` or `SystemAssigned, UserAssigned` is set, an `identity_ids` must be set as well."
  default     = "SystemAssigned"

  validation {
    condition     = var.identity_type == "SystemAssigned" || var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned"
    error_message = "`identity_type`'s possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`(to enable both)."
  }
}

variable "sla_sku" {
  type    = string
  default = "Free"
}

variable "api_auth_ips" {
  type    = list(string)
  default = []
}

variable "private_cluster_enabled" {
  type    = bool
  default = false
}

#####################################
# AKS Jumpbox Configuration         #
#####################################

variable "create_jumpbox" {
  description = "Specifies whether to create a jumpbox"
  type        = bool
  default     = true
}

variable "vm_subnet_id" {
  description = "Specifies the subnet id of the jumpbox"
  type        = string
  default     = ""
}

variable "network_security_group_name" {
  description = "Specifies the name of the network security group"
  type        = string
  default     = "jumpbox-nsg"
}

variable "size_linux_jumpbox" {
  description = "Specifies the size of the jumpbox"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default     = {}
}

variable "admin_username" {
  description = "Specifies the admin username of the jumpbox"
  type        = string
  default     = "jumpboxadmin"
}

variable "admin_password" {
  description = "Specifies the admin password of the jumpbox"
  type        = string
  default     = ""
}