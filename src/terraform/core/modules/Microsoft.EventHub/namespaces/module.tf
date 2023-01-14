# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################################################
# RESOURCES                                      #
##################################################

resource "azurerm_eventhub_namespace" "events" {
  name                = "${var.name}-ns"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  capacity            = var.capacity

  auto_inflate_enabled     = var.auto_inflate != null ? var.auto_inflate.enabled : null
  maximum_throughput_units = var.auto_inflate != null ? var.auto_inflate.maximum_throughput_units : null

  dynamic "network_rulesets" {
    for_each = var.network_rules != null ? ["true"] : []
    content {
      default_action = "Deny"

      dynamic "ip_rule" {
        for_each = var.network_rules.ip_rules
        iterator = iprule
        content {
          ip_mask = iprule.value
        }
      }

      dynamic "virtual_network_rule" {
        for_each = var.network_rules.subnet_ids
        iterator = subnet
        content {
          subnet_id = subnet.value
        }
      }
    }
  }

  tags = var.tags
}

module "eventHubNamespace_authorizationRules" {
  source   = "./authorizationRules"
  for_each = local.authorization_rules

  authorization_rule_name = each.key
  eventhub_namespace_name = azurerm_eventhub_namespace.events.name
  resource_group_name     = var.resource_group_name

  listen = each.value.listen
  send   = each.value.send
  manage = each.value.manage
}

# 
module "eventHubNamespace_eventHubs" {
  source   = "./eventHub"
  for_each = local.hubs

  eventhub_name       = each.key
  namespace_name      = azurerm_eventhub_namespace.events.name
  resource_group_name = var.resource_group_name
  partition_count     = each.value.partitions
  message_retention   = each.value.message_retention
}

module "eventHubNamespace_authorizationRules" {
  source   = "./authorizationRules"
  for_each = local.keys

  authorization_rule_name = each.value.key.name
  eventhub_namespace_name = azurerm_eventhub_namespace.events.name
  eventhub_name           = each.value.hub
  resource_group_name     = var.resource_group_name

  listen = each.value.key.listen
  send   = each.value.key.send
  manage = false

  depends_on = [azurerm_eventhub.events]
}
