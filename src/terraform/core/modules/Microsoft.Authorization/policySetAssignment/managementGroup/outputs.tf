##################################################
# OUTPUTS                                        #
##################################################
output id {
  description = "The Policy Assignment Id"
  value       = azurerm_management_group_policy_assignment.set.id
}

output principal_id {
  description = "The Principal Id of this Policy Assignment's Managed Identity if type is SystemAssigned"
  value       = try(azurerm_management_group_policy_assignment.set.identity[0].principal_id, null)
}

output definition_references {
  description = "The Member Definition Reference Ids"
  value       = try(var.initiative.policy_definition_reference, [])
}
