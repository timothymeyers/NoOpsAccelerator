# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "assignment" {
  source               = "./assignment"
  scope                = var.scope
  role_definition_name = var.mode == "built-in" ? var.role_definition_name : null
  role_definition_id   = var.mode == "custom" ? var.role_definition_resource_id : null
  principal_id         = var.principal_id
  skip_service_principal_aad_check = var.skip_service_principal_aad_check
}

