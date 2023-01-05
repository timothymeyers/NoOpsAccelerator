# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_host_pool

resource "azurerm_virtual_desktop_host_pool" "wvdpool" {
  location                         = var.location
  resource_group_name              = var.resource_group_name
  name                             = var.name
  friendly_name                    = try(var.friendly_name, null)
  description                      = try(var.description, null)
  validate_environment             = try(var.validate_environment, null)
  type                             = var.type
  maximum_sessions_allowed         = try(var.maximum_sessions_allowed, null)
  load_balancer_type               = try(var.load_balancer_type, null)
  personal_desktop_assignment_type = try(var.personal_desktop_assignment_type, null)
  preferred_app_group_type         = try(var.preferred_app_group_type, null)
  custom_rdp_properties            = try(var.custom_rdp_properties, null)
  start_vm_on_connect              = try(var.start_vm_on_connect, null)
  tags                             = local.tags
}

# Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_host_pool_registration_info

resource "azurerm_virtual_desktop_host_pool_registration_info" "wvdpool" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.wvdpool.id
  expiration_date = try(var.registration_info.expiration_date, timeadd(timestamp(), var.registration_info.token_validity))
}
