# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_eventhub" "eventhub" {
    name                = var.eventhub_name
    namespace_name      = var.namespace_name
    resource_group_name = var.resource_group_name
    location            = var.location
    partition_count     = var.partition_count
    message_retention   = var.message_retention
    
}