# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "laws_name" {
  description = "LAWS Name"
  value       = module.laws.name
}

output "laws_rgname" {
  description = "Resource Group for Laws"
  value       = module.laws.resource_group_name
}

output "laws_StorageAccount_Id" {
  description = "StorageAccount Respurce Id for Laws"
  value       = module.mod_logging_storage_account.storage_account_id
}

output "laws_storage_account_name" {
  description = "LAWS Name"
  value       = module.mod_logging_storage_account.storage_account_name
}

output "laws_storage_account_uri" {
  description = "LAWS Name"
  value       = module.mod_logging_storage_account.storage_account_uri
}
 
output "laws_workspace_id" {
  description = "LAWS Workspace Id"
  value       = module.laws.workspace_id
}

output "laws_workspace_key" {
  description = "LAWS Workspace Id"
  value       = module.laws.primary_shared_key
}

output "laws_resource_id" {
  description = "LAWS Resource Id"
  value       = module.laws.id
}

output "resource_group_name" {
  description = "Logging Resource Group Name"
  value       = module.mod_logging_rg.resource_group_name
}