# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#-----------------------------------
# Public IP for Virtual Machine
#-----------------------------------
resource "azurerm_public_ip" "pip" {
  count               = var.enable_public_ip_address == true ? var.instances_count : 0
  name                = lower("${local.vm_pub_ip_name}-0${count.index + 1}")
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  sku_tier            = var.public_ip_sku_tier
  domain_name_label   = coalesce(var.internal_dns_name_label, local.vm_name)  
  tags                = merge(local.default_tags, var.extra_tags, var.public_ip_extra_tags)

  lifecycle {
    ignore_changes = [
      tags,
      ip_tags,
    ]
  }
}

#---------------------------------------
# Network Interface for Virtual Machine
#---------------------------------------
resource "azurerm_network_interface" "nic" {
  count                         = var.instances_count
  name                          = var.instances_count == 1 ? lower("${format("%s", lower(replace(local.vm_nic_name, "/[[:^alnum:]]/", "")))}") : lower("${format("%s-%s", lower(replace(local.vm_nic_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
  location                      = var.location
  resource_group_name           = var.resource_group_name
  dns_servers                   = var.dns_servers
  enable_ip_forwarding          = var.enable_ip_forwarding
  enable_accelerated_networking = var.nic_enable_accelerated_networking
  internal_dns_name_label       = var.internal_dns_name_label
  tags                          = merge(local.default_tags, var.extra_tags, var.nic_extra_tags)

  ip_configuration {
    name                          = lower("${format("%s-%s", lower(replace(local.vm_nic_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
    primary                       = true
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address_allocation = var.static_private_ip == null ? "Dynamic" : "Static"
    private_ip_address            = var.static_private_ip
    public_ip_address_id          = var.enable_public_ip_address == true ? element(concat(azurerm_public_ip.pip.*.id, [""]), count.index) : null
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#----------------------------------------------------------------------------------------------------
# Proximity placement group for virtual machines, virtual machine scale sets and availability sets.
#----------------------------------------------------------------------------------------------------
resource "azurerm_proximity_placement_group" "appgrp" {
  count               = var.enable_proximity_placement_group ? 1 : 0
  name                = lower("proxigrp-${local.vm_name}-${var.location}")
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = merge({ "ResourceName" = lower("proxigrp-${local.vm_name}-${var.location}") }, var.tags, )

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#-----------------------------------------------------
# Manages an Availability Set for Virtual Machines.
#-----------------------------------------------------
resource "azurerm_availability_set" "aset" {
  count                        = var.enable_vm_availability_set ? 1 : 0
  name                         = lower("${local.avail_set_name}")
  resource_group_name          = var.resource_group_name
  location                     = var.location
  platform_fault_domain_count  = var.platform_fault_domain_count
  platform_update_domain_count = var.platform_update_domain_count
  proximity_placement_group_id = var.enable_proximity_placement_group ? azurerm_proximity_placement_group.appgrp.0.id : null
  managed                      = true
  tags                         = merge({ "ResourceName" = lower("${local.avail_set_name}") }, var.tags, )

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_network_interface_security_group_association" "nsgassoc" {
  count                     = var.instances_count
  network_interface_id      = element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)
  network_security_group_id = var.existing_network_security_group_id
}

resource "azurerm_network_interface_backend_address_pool_association" "lb_pool_association" {
  count = var.attach_load_balancer ? 1 : 0

  backend_address_pool_id = var.load_balancer_backend_pool_id
  ip_configuration_name   = local.ip_configuration_name
  network_interface_id    = azurerm_network_interface.nic.0.id
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "appgw_pool_association" {
  count = var.attach_application_gateway ? 1 : 0

  backend_address_pool_id = var.application_gateway_backend_pool_id
  ip_configuration_name   = local.ip_configuration_name
  network_interface_id    = azurerm_network_interface.nic.0.id
}
