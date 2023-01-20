# Description: Module to create policy definition and assignment
##################################################
# RESOURCES                                      #
##################################################
resource azurerm_management_group_policy_assignment def {  
  name                 = local.assignment_name
  display_name         = local.display_name
  description          = local.description
  metadata             = local.metadata
  parameters           = local.parameters
  management_group_id  = var.assignment_scope
  not_scopes           = var.assignment_not_scopes
  enforce              = var.assignment_enforcement_mode
  policy_definition_id = var.definition.id
  location             = var.assignment_location

  dynamic "non_compliance_message" {
    for_each = local.non_compliance_message
    content {
      content = non_compliance_message.value
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