resource "azurerm_mssql_server" "main" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.sql_db_version
  administrator_login          = var.sql_db_login
  administrator_login_password = var.sql_db_password
  minimum_tls_version          = var.minimum_tls_version
}
