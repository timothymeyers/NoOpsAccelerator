# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_eventhub_namespace_authorization_rule" "events" {
  name                = var.authorization_rule_name
  namespace_name      = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name

  listen = var.listen
  send   = var.send
  manage = var.manage

}
