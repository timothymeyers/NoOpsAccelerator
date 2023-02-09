# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "admin_ssh_key_public" {
  description = "The generated public key data in PEM format"
  value       = var.disable_password_authentication == true && var.generate_admin_ssh_key == true ? tls_private_key.rsa[0].public_key_openssh : null
}

output "admin_ssh_key_private" {
  description = "The generated private key data in PEM format"
  sensitive   = true
  value       = var.disable_password_authentication == true && var.generate_admin_ssh_key == true ? tls_private_key.rsa[0].private_key_pem : null
}

output "windows_vm_password" {
  description = "Password for the windows VM"
  sensitive   = true
  value       = element(concat(random_password.password.*.result, [""]), 0) 
}

output "windows_vm_public_ips" {
  description = "Public IP's map for the all windows Virtual Machines"
  value       = var.enable_public_ip_address == true ? zipmap(azurerm_windows_virtual_machine.win_vm.*.name, azurerm_windows_virtual_machine.win_vm.*.public_ip_address) : null
}

output "windows_vm_private_ips" {
  description = "Public IP's map for the all windows Virtual Machines"
  value       = zipmap(azurerm_windows_virtual_machine.win_vm.*.name, azurerm_windows_virtual_machine.win_vm.*.private_ip_address)
}

output "windows_virtual_machine_ids" {
  description = "The resource id's of all Windows Virtual Machine."
  value       = concat(azurerm_windows_virtual_machine.win_vm.*.id, [""]) 
}

output "existing_network_security_group_id" {
  description = "List of Network security groups and ids"
  value       = var.existing_network_security_group_id
}

output "vm_availability_set_id" {
  description = "The resource ID of Virtual Machine availability set"
  value       = var.enable_vm_availability_set == true ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
}