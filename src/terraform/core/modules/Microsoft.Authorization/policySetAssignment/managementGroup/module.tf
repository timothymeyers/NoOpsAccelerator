# Description: Creates a Policy Set Assignment
# Credit: gettek
##################################################
# RESOURCES                                      #
##################################################

resource azurerm_management_group_policy_assignment set {  
  name                 = local.assignment_name
  display_name         = local.display_name
  description          = local.description
  metadata             = local.metadata
  parameters           = local.parameters
  management_group_id  = var.assignment_scope
  not_scopes           = var.assignment_not_scopes
  enforce              = var.assignment_enforcement_mode
  policy_definition_id = var.initiative.id
  location             = var.assignment_location

  dynamic "non_compliance_message" {
    for_each = local.non_compliance_message
    content {
      content                        = non_compliance_message.value
      policy_definition_reference_id = non_compliance_message.key == "null" ? null : non_compliance_message.key
    }
  }

  dynamic "identity" {
    for_each = local.identity_type
    content {
      type         = identity.value
      identity_ids = []
    }
  }
}


## role assignments ##
resource azurerm_role_assignment rem_role {
  for_each                         = toset(local.role_definition_ids)
  scope                            = coalesce(var.role_assignment_scope, var.assignment_scope)
  role_definition_id               = each.value
  principal_id                     = azurerm_management_group_policy_assignment.set.identity.0.principal_id  
  skip_service_principal_aad_check = true
}

## remediation tasks ##
/* resource azurerm_management_group_policy_remediation rem {
  name                           = lower("${var.remediation_name}-${formatdate("DD-MM-YYYY-hh:mm:ss", timestamp())}")
  management_group_id            = var.remediation_scope
  policy_assignment_id           = azurerm_management_group_policy_assignment.set.id 
  location_filters               = var.location_filters
  failure_percentage             = var.failure_percentage
  parallel_deployments           = var.parallel_deployments
  resource_count                 = var.resource_count
} */

