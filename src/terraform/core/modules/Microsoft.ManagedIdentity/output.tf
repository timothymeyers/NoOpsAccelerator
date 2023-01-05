# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.user_identity.id
}

output "user_assigned_identity_principal_id" {
  value = azurerm_user_assigned_identity.user_identity.principal_id
}
