# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_resource_group" "nwatcher" {
  count    = var.create_network_watcher != false ? 1 : 0
  name     = "NetworkWatcherRG"
  location = var.location
  tags     = merge({ "Name" = "NetworkWatcherRG" }, var.tags, )
}

resource "azurerm_network_watcher" "nwatcher" {
  count               = var.create_network_watcher != false ? 1 : 0
  name                = "NetworkWatcher_${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.nwatcher.0.name
  tags                = merge({ "Name" = format("%s", "NetworkWatcher_${var.location}") }, var.tags, )
}
