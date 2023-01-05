output subnet_ids {
 description = "Contains a list of the the resource id of the subnets"
  value       = { for subnet in azurerm_subnet.subnet : subnet.name => subnet.id }
}
