# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "id" {
  description = "The ID of the new MS SQL Database."
  value       = azurerm_mssql_database.main.id
}

output "name" {
    description = "The name of the new MS SQL Database."
    value = azurerm_mssql_database.main.name
}
