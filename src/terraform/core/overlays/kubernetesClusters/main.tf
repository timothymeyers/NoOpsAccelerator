# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a Azure Kubernetes Private Cluster workload with Linux Jump Boxes to an Network
DESCRIPTION: The following components will be options in this deployment
              * Azure Container Registry
              * Azure Kubernetes Cluster
              * Azure Kubernetes Cluster Node Pool
              * Linux VM Jumpbox
AUTHOR/S: jspinella
*/

resource "azurerm_kubernetes_cluster" "aks" {
  name                            = "${var.name}-aks"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  dns_prefix                      = var.name
  kubernetes_version              = var.kubernetes_version
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  node_resource_group             = var.node_resource_group
  enable_pod_security_policy      = var.enable_pod_security_policy
  private_cluster_enabled         = var.private_cluster_enabled
  
  dynamic "agent_pool_profile" {
    for_each = local.agent_pools
    iterator = ap
    content {
      name                = ap.value.name
      count               = ap.value.count
      vm_size             = ap.value.vm_size
      availability_zones  = ap.value.availability_zones
      enable_auto_scaling = ap.value.enable_auto_scaling
      min_count           = ap.value.min_count
      max_count           = ap.value.max_count
      max_pods            = ap.value.max_pods
      os_disk_size_gb     = ap.value.os_disk_size_gb
      os_type             = ap.value.os_type
      type                = ap.value.type
      vnet_subnet_id      = ap.value.vnet_subnet_id
      node_taints         = ap.value.node_taints
    }
  }

  service_principal {
    client_id     = var.service_principal.client_id
    client_secret = var.service_principal.client_secret
  }

  addon_profile {
    oms_agent {
      enabled                    = var.addons.oms_agent
      log_analytics_workspace_id = var.addons.oms_agent ? var.addons.oms_agent_workspace_id : null
    }

    kube_dashboard {
      enabled = var.addons.dashboard
    }

    azure_policy {
      enabled = var.addons.policy
    }
  }

  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [true] : []
    iterator = lp
    content {
      admin_username = var.linux_profile.username

      ssh_key {
        key_data = var.linux_profile.ssh_key
      }
    }
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    dns_service_ip     = cidrhost(var.service_cidr, 10)
    docker_bridge_cidr = var.net_profile_docker_bridge_cidr
    service_cidr       = var.net_profile_service_cidr

    # Use Standard if availability zones are set, Basic otherwise
    load_balancer_sku = local.load_balancer_sku
  }

  microsoft_defender {
    enabled = var.microsoft_defender_enabled
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      client_app_id     = var.azure_active_directory.client_app_id
      server_app_id     = var.azure_active_directory.server_app_id
      server_app_secret = var.azure_active_directory.server_app_secret
    }
  }

  tags = var.tags
}
