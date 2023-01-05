##################################################
# OUPUTS                                         #
##################################################
output "public_ip" {
  description = "Specifies the public IP address of the virtual machine"
  value       = azurerm_linux_virtual_machine.virtual_machine.public_ip_address
}

output "username" {
  description = "Specifies the username of the virtual machine"
  value       = var.admin_username
}

output "id" {
  description = "Specifies the name of the virtual machine"
  value       = azurerm_linux_virtual_machine.virtual_machine.id
}

output "name" {
  description = "Specifies the name of the virtual machine"
  value       = azurerm_linux_virtual_machine.virtual_machine.name
}

output "vm_network_interface_id" {
  description = "Specifies the name of the virtual machine"
  value       = module.mod_virtual_machine_nic.network_interface_id
}
