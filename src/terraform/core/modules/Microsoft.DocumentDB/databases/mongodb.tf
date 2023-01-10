module "mongo_databases" {
  source   = "./mongodb"
  for_each = try(var.mongo_databases, {})

  resource_group_name   = azurerm_cosmosdb_account.this.resource_group_name
  cosmosdb_account_name = azurerm_cosmosdb_account.this.name
  db_name               = each.value.name
  throughput            = each.value.throughput
}

output "mongo_databases" {
  value = module.mongo_databases

}
