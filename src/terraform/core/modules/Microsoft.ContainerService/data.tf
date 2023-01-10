
data "azurerm_resource_group" "this" {
  name  = var.resource_group_name
}

data "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  resource_group_name = data.azurerm_resource_group.this.0.name
}

data "azurerm_log_analytics_workspace" "this" {
  name                = var.loganalytics_workspace_name
  resource_group_name = data.azurerm_resource_group.this.0.name
}

data "azurerm_subnet" "default_pool" {
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.networking_resource_group != null ? each.value.networking_resource_group : (local.resourcegroup_state_exists == true ? var.resource_group_name : data.azurerm_resource_group.this.0.name)
}

data "azurerm_subnet" "extra_pool" {
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.networking_resource_group != null ? each.value.networking_resource_group : (local.resourcegroup_state_exists == true ? var.resource_group_name : data.azurerm_resource_group.this.0.name)
}