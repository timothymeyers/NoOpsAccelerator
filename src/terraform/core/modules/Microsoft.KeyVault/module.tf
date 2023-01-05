# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys a Key Vault
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault

#############################################
# DATA                                      #
#############################################
data "azurerm_client_config" "current" {
}

##################################################
# RESOURCES                                      #
##################################################
########################################################################################################################
# Creates a New KeyVault & diagnostic settings
########################################################################################################################
resource "azurerm_key_vault" "key_vault" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = var.tenant_id
  sku_name                        = var.sku_name
  tags                            = var.tags
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.name == "" ? false : var.purge_protection_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days

  timeouts {
    delete = "60m"
  }

  dynamic "network_acls" {
    for_each = local.merged_network_acls == null ? [local.default_network_acls] : [local.merged_network_acls]
    content {
      bypass                     = network_acls.value.bypass
      default_action             = network_acls.value.default_action
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  lifecycle {
      ignore_changes = [
          tags
      ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "KeyVault-DiagnosticsSettings"
  target_resource_id         = azurerm_key_vault.key_vault.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }

  log {
    category = "AzurePolicyEvaluationDetails"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }
}
