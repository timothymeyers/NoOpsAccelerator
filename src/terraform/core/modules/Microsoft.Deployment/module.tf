# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "random_string" "random1" {
  length  = 16
  special = false
}

resource "azurerm_template_deployment" "arm_deployment" {
  name                = "${var.name}-${random_string.random1.result}"
  resource_group_name = var.resource_group_name

  template_body = file(var.path_deploy_template)
  parameters = {
    "name"              = var.name
    "region"            = var.location
  }
  deployment_mode = "Incremental"
}
