output "id" {
  value = azurerm_container_group.aci.id
}

output "name" {
  value = azurerm_container_group.aci.name
}

output "fqdn" {
  value = azurerm_container_group.aci.fqdn
}

output "tags" {
  value = var.tags
}

