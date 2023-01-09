output id {
 description = "The id of the subnet."
  value       = element(concat(azurerm_subnet.subnet.*.id, [""]), 0)
}

output name {
 description = "The name of the subnet."
  value       = element(concat(azurerm_subnet.subnet.*.name, [""]), 0)
}