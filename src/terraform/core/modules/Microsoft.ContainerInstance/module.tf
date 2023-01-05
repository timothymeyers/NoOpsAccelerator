# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a container instance to the specified resource group.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group

resource "azurerm_container_group" "aci" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = try(var.os_type, "Linux")
  dns_name_label      = try(var.dns_name_label, null)
  tags                = merge(local.tags, try(var.tags, null))
  ip_address_type     = try(var.ip_address_type, "Public")
  restart_policy      = try(var.restart_policy, "Always")

  dynamic "exposed_port" {
    for_each = try(var.exposed_port, [])

    content {
      port     = exposed_port.value.port
      protocol = upper(exposed_port.value.protocol)
    }
  }

  # Create containers based on for_each
  dynamic "container" {
    for_each = local.containers

    content {
      name                  = container.value.name
      image                 = container.value.image
      cpu                   = container.value.cpu
      memory                = container.value.memory
      environment_variables = try(container.value.environment_variables, null)

      secure_environment_variables = try(container.value.secure_environment_variables, null)

      dynamic "ports" {
        for_each = try(container.value.ports, {})

        content {
          port     = can(container.value.iterator) ? tonumber(ports.value.port) + container.value.iterator : ports.value.port
          protocol = try(upper(ports.value.protocol), "TCP")
        }
      }
    }
  }
}
