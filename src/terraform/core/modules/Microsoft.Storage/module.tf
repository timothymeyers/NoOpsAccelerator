# Tested with :  AzureRM version 2.61.0
# Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account

resource "azurerm_storage_account" "storage_account" {
  access_tier                       = try(var.storage_account.access_tier, "Hot")
  account_kind                      = try(var.storage_account.account_kind, "StorageV2")
  account_replication_type          = try(var.storage_account.account_replication_type, "LRS")
  account_tier                      = try(var.storage_account.account_tier, "Standard")
  enable_https_traffic_only         = try(var.storage_account.enable_https_traffic_only, true)
  infrastructure_encryption_enabled = try(var.storage_account.infrastructure_encryption_enabled, null)
  is_hns_enabled                    = try(var.storage_account.is_hns_enabled, false)
  large_file_share_enabled          = try(var.storage_account.large_file_share_enabled, null)
  location                          = var.location
  min_tls_version                   = try(var.storage_account.min_tls_version, "TLS1_2")
  name                              = var.name
  nfsv3_enabled                     = try(var.storage_account.nfsv3_enabled, false)
  queue_encryption_key_type         = try(var.storage_account.queue_encryption_key_type, null)
  resource_group_name               = var.resource_group_name
  table_encryption_key_type         = try(var.storage_account.table_encryption_key_type, null)
  tags                              = var.tags

  network_rules {
    default_action             = (length(var.ip_rules) + length(var.virtual_network_subnet_ids)) > 0 ? "Deny" : var.default_action
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

}
