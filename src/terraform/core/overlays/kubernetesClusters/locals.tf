# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

locals {
  default_agent_profile = {
    count               = 1
    vm_size             = "Standard_D2_v3"
    os_type             = "Linux"
    availability_zones  = null
    enable_auto_scaling = false
    min_count           = null
    max_count           = null
    type                = "VirtualMachineScaleSets"
    node_taints         = null
  }

  # Defaults for Linux profile
  # Generally smaller images so can run more pods and require smaller HD
  default_linux_node_profile = {
    max_pods        = 30
    os_disk_size_gb = 60
  }

  # Defaults for Windows profile
  # Do not want to run same number of pods and some images can be quite large
  default_windows_node_profile = {
    max_pods        = 20
    os_disk_size_gb = 200
  }

  agent_pools_with_defaults = [for ap in var.agent_pools :
    merge(local.default_agent_profile, ap)
  ]
  agent_pools = [for ap in local.agent_pools_with_defaults :
    ap.os_type == "Linux" ? merge(local.default_linux_node_profile, ap) : merge(local.default_windows_node_profile, ap)
  ]

  # Determine which load balancer to use
  agent_pool_availability_zones_lb = [for ap in local.agent_pools : ap.availability_zones != null ? "Standard" : ""]
  load_balancer_sku                = coalesce(flatten([local.agent_pool_availability_zones_lb, ["Standard"]])...)

  # Distinct subnets
  agent_pool_subnets = distinct(local.agent_pools.*.vnet_subnet_id)

  # Diagnostic settings
  diag_kube_logs = [
    "kube-apiserver",
    "kube-audit",
    "kube-controller-manager",
    "kube-scheduler",
    "cluster-autoscaler",
  ]
  diag_kube_metrics = [
    "AllMetrics",
  ]

  diag_resource_list = var.diagnostics != null ? split("/", var.diagnostics.destination) : []
  parsed_diag = var.diagnostics != null ? {
    log_analytics_id   = contains(local.diag_resource_list, "microsoft.operationalinsights") ? var.diagnostics.destination : null
    storage_account_id = contains(local.diag_resource_list, "Microsoft.Storage") ? var.diagnostics.destination : null
    event_hub_auth_id  = contains(local.diag_resource_list, "Microsoft.EventHub") ? var.diagnostics.destination : null
    metric             = contains(var.diagnostics.metrics, "all") ? local.diag_kube_metrics : var.diagnostics.metrics
    log                = contains(var.diagnostics.logs, "all") ? local.diag_kube_logs : var.diagnostics.metrics
    } : {
    log_analytics_id   = null
    storage_account_id = null
    event_hub_auth_id  = null
    metric             = []
    log                = []
  }
}