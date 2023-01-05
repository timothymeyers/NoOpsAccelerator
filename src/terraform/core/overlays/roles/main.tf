# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################################################
# MODULES                                        #
##################################################
module "custom_roles" {
  source                  = "../../modules/Microsoft.Authorization/roleDefinitions"
  count                   = var.deploy_custom_roles == true ? 1 : 0
  custom_role_definitions = var.custom_role_definitions
}
