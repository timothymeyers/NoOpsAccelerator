# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a container instance to the specified resource group.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group

##################################################
# RESOURCES                                      #
##################################################
# Needed as introduced in >2.79.1 - https://github.com/hashicorp/terraform-provider-azurerm/issues/13585
resource "null_resource" "aks_registration_preview" {
  provisioner "local-exec" {
    command = "az feature register --namespace Microsoft.ContainerService -n AutoUpgradePreview"
  }
}

module "aks_identity" {
  source = "../Microsoft.ManagedIdentity"
  name   = var.name
  location = var.location
  resource_group_name = var.resource_group_name
}

### AKS cluster resource
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  for_each                = var.aks_clusters
  name                    = each.value["name"]
  resource_group_name     = var.resource_group_name
  location                = var.location
  sku_tier                = lookup(each.value, "sku_tier", null)
  dns_prefix              = each.value["dns_prefix"]
  private_cluster_enabled = true
  kubernetes_version      = each.value["kubernetes_version"]
  disk_encryption_set_id  = coalesce(lookup(each.value, "cmk_enabled"), false) == true ? lookup(azurerm_disk_encryption_set.this, each.key)["id"] : null

  api_server_authorized_ip_ranges = lookup(each.value, "api_server_authorized_ip_ranges", null)

  dynamic "default_node_pool" {
    for_each = list(each.value["aks_default_pool"])
    content {
      name                = default_node_pool.value.name
      vm_size             = default_node_pool.value.vm_size
      availability_zones  = lookup(default_node_pool.value, "availability_zones", null)
      enable_auto_scaling = coalesce(default_node_pool.value.enable_auto_scaling, true)
      max_pods            = lookup(default_node_pool.value, "max_pods", null)
      os_disk_size_gb     = lookup(default_node_pool.value, "os_disk_size_gb", null)
      type                = "VirtualMachineScaleSets"
      node_count          = coalesce(default_node_pool.value.enable_auto_scaling, true) == true ? lookup(default_node_pool.value, "node_count", null) : default_node_pool.value.node_count
      min_count           = coalesce(default_node_pool.value.enable_auto_scaling, true) == true ? default_node_pool.value.min_count : null
      max_count           = coalesce(default_node_pool.value.enable_auto_scaling, true) == true ? default_node_pool.value.max_count : null
      vnet_subnet_id      = lookup(default_node_pool.value, "subnet_name", null) == null ? null : (local.networking_state_exists == true ? lookup(data.terraform_remote_state.networking.outputs.map_subnet_ids, default_node_pool.value.subnet_name) : lookup(data.azurerm_subnet.default_pool, each.key)["id"]) # Required for advanced networking
      tags                = local.tags
    }
  }

  dynamic "service_principal" {
    for_each = coalesce(lookup(each.value, "assign_identity"), false) == false ? [true] : []
    content {
      client_id     = var.aks_client_id
      client_secret = var.aks_client_secret
    }
  }

  dynamic "identity" {
    for_each = coalesce(lookup(each.value, "assign_identity"), false) == false ? [] : list(coalesce(lookup(each.value, "assign_identity"), false))
    content {
      type = "SystemAssigned"
    }
  }

  addon_profile {
    oms_agent {
      enabled                    = local.oms_agent_enabled
      log_analytics_workspace_id = local.oms_agent_enabled == true ? (local.loganalytics_state_exists == true ? data.terraform_remote_state.loganalytics.outputs.law_id : data.azurerm_log_analytics_workspace.this.0.id) : null
    }

    kube_dashboard {
      enabled = true
    }
  }

  linux_profile {
    admin_username = each.value.admin_username
    ssh_key {
      key_data = lookup(tls_private_key.this, each.key)["public_key_openssh"]
    }
  }
    
  network_profile {
    network_plugin     = coalesce(each.value.network_plugin, "azure")
    network_policy     = coalesce(each.value.network_policy, "azure")
    docker_bridge_cidr = lookup(each.value, "docker_bridge_cidr", null)
    service_cidr       = lookup(each.value, "service_address_range", null)
    dns_service_ip     = lookup(each.value, "dns_ip", null)
    pod_cidr           = coalesce(each.value.network_plugin, "azure") == "kubenet" ? lookup(each.value, "pod_cidr", null) : null
    load_balancer_sku  = "Standard"
    dynamic "load_balancer_profile" {
      for_each = lookup(each.value, "load_balancer_profile", null) != null ? list(each.value.load_balancer_profile) : []
      content {
        outbound_ports_allocated  = lookup(load_balancer_profile.value, "outbound_ports_allocated", null)
        idle_timeout_in_minutes   = lookup(load_balancer_profile.value, "idle_timeout_in_minutes", null)
        managed_outbound_ip_count = coalesce(lookup(load_balancer_profile.value, "managed_outbound_ip_count"), [])
        outbound_ip_address_ids   = coalesce(lookup(load_balancer_profile.value, "outbound_ip_address_ids"), [])
      }
    }
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      tags
    ]
  }
}