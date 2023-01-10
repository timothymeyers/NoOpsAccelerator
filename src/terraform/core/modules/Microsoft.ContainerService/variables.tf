# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the Kubernetes Cluster."
}

variable "aks_clusters" {
  type = map(object({
    name                            = string
    sku_tier                        = string
    dns_prefix                      = string
    kubernetes_version              = string
    docker_bridge_cidr              = string
    service_address_range           = string
    dns_ip                          = string
    rbac_enabled                    = bool
    cmk_enabled                     = bool
    assign_identity                 = bool
    admin_username                  = string
    api_server_authorized_ip_ranges = list(string)
    network_plugin                  = string
    network_policy                  = string
    pod_cidr                        = string
    managed                         = bool
    admin_group_object_ids          = list(string)
    aks_default_pool = object({
      name                      = string
      vm_size                   = string
      availability_zones        = list(string)
      enable_auto_scaling       = bool
      max_pods                  = number
      os_disk_size_gb           = number
      subnet_name               = string
      vnet_name                 = string
      networking_resource_group = string
      node_count                = number
      max_count                 = number
      min_count                 = number
    })
    auto_scaler_profile = object({
      balance_similar_node_groups      = bool
      max_graceful_termination_sec     = number
      scale_down_delay_after_add       = string
      scale_down_delay_after_delete    = string
      scale_down_delay_after_failure   = string
      scan_interval                    = string
      scale_down_unneeded              = string
      scale_down_unready               = string
      scale_down_utilization_threshold = number
    })
    load_balancer_profile = object({
      outbound_ports_allocated  = number
      idle_timeout_in_minutes   = number
      managed_outbound_ip_count = number
      outbound_ip_address_ids   = list(string)
    })
  }))
  default = {}
}

variable "aks_extra_node_pools" {
  type = map(object({
    name                      = string
    aks_key                   = string
    vm_size                   = string
    availability_zones        = list(string)
    enable_auto_scaling       = bool
    max_pods                  = number
    mode                      = string
    os_disk_size_gb           = number
    subnet_name               = string
    vnet_name                 = string
    networking_resource_group = string
    node_count                = number
    max_count                 = number
    min_count                 = number
  }))
  description = "(Optional) List of additional node pools"
  default     = {}
}