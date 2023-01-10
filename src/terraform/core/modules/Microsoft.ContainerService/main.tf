# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

terraform {
  required_providers {
     azurerm = {
      source = "hashicorp/azurerm"
    }
  }

}

locals {  
  default_pool_subnets = {
    for aks_k, aks_v in var.aks_clusters : aks_k => {
      subnet_name               = aks_v.aks_default_pool.subnet_name
      vnet_name                 = aks_v.aks_default_pool.vnet_name
      networking_resource_group = aks_v.aks_default_pool.networking_resource_group
    } if(aks_v.aks_default_pool.subnet_name != null && aks_v.aks_default_pool.vnet_name != null)
  }

  extra_pool_subnets = {
    for np_k, np_v in var.aks_extra_node_pools : np_k => {
      subnet_name               = np_v.subnet_name
      vnet_name                 = np_v.vnet_name
      networking_resource_group = np_v.networking_resource_group
    } if(np_v.subnet_name != null && np_v.vnet_name != null)
  }

  oms_agent_enabled = data.terraform_remote_state.loganalytics.outputs.law_ids != null ? true : false

  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(var.tags, local.module_tag)
}