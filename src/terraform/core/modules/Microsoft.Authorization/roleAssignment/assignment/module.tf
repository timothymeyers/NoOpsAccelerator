# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################################################
# RESOURCES                                      #
##################################################
resource "azurerm_role_assignment" "msi" {
  scope                            = var.scope
  role_definition_name             = var.role_definition_name == null ? null : var.role_definition_name
  role_definition_id               = var.role_definition_id == null ? null : var.role_definition_id
  principal_id                     = var.principal_id
  skip_service_principal_aad_check = var.skip_service_principal_aad_check
}
