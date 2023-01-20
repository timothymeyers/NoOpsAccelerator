output "name" {
  description = "The name of the subnet."
  value       = azurerm_subnet.subnet.name
}
  
output "id" {
  description = "The ID of the subnet."
  value       = azurerm_subnet.subnet.id
}
