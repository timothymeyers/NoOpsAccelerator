# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy Custom Roles for Azure RBAC
DESCRIPTION: The following components will be options in this deployment
             * Custom Roles
AUTHOR/S: jspinella
*/

#####################################
### STAGE 2: Roles Configuations  ###
#####################################

module "mod_custom_roles" {
  source              = "../../../terraform/core/overlays/customRoles"
  deploy_custom_roles = var.enable_services.deploy_custom_roles
  custom_role_definitions = [
    {
      role_definition_name = "Custom - Network Operations (NetOps)"
      description          = "Platform-wide global connectivity management: virtual networks, UDRs, NSGs, NVAs, VPN, Azure ExpressRoute, and others."
      permissions = {
        actions = [
          "Microsoft.Network/virtualNetworks/read",
          "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
          "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write",
          "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete",
          "Microsoft.Network/virtualNetworks/peer/action",
          "Microsoft.Resources/deployments/operationStatuses/read",
          "Microsoft.Resources/deployments/write",
          "Microsoft.Resources/deployments/read"
        ]
        data_actions     = []
        not_actions      = []
        not_data_actions = []
      }
    }
  ]
}