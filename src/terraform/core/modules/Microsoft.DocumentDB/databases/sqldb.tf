module "sql_databases" {
  source   = "./sqldb"
  for_each = try(var.sql_databases, {})
  
  settings              = each.value
  resource_group_name   = azurerm_cosmosdb_account.this.resource_group_name
  location              = azurerm_cosmosdb_account.this.location
  cosmosdb_account_name = azurerm_cosmosdb_account.this.name
}

output "sql_databases" {
  value = module.sql_databases

}