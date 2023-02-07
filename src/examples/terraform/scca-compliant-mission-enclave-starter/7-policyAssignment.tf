# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy Policy Assignments for Azure Policy
DESCRIPTION: The following components will be options in this deployment
             * Policy Assignments
AUTHOR/S: jspinella
*/

################################################
### STAGE 5: Policy Assignment Configuations ###
################################################

##################
# Monitoring    ##
##################

module "mod_mg_platform_diagnostics_initiative" {
  source               = "../../../terraform/core/modules/Microsoft.Authorization/policySetAssignment/managementGroup"
  initiative           = module.platform_diagnostics_initiative.initiative
  assignment_scope     = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/anoa"].id
  assignment_location  = var.location
  skip_remediation     = true
  skip_role_assignment = false

  role_definition_ids = [
    data.azurerm_role_definition.contributor.id # using explicit roles
  ]

  non_compliance_messages = {
    null                                        = "The Default non-compliance message for all member definitions"
    "DeployApplicationGatewayDiagnosticSetting" = "The non-compliance message for the deploy_application_gateway_diagnostic_setting definition"
  }

  assignment_parameters = {
    workspaceId                                        = module.mod_operational_logging.laws_resource_id
    storageAccountId                                   = module.mod_operational_logging.laws_StorageAccount_Id
    eventHubName                                       = ""
    eventHubAuthorizationRuleId                        = ""
    metricsEnabled                                     = "True"
    logsEnabled                                        = "True"
    effect_DeployApplicationGatewayDiagnosticSetting   = "DeployIfNotExists"
    effect_DeployEventhubDiagnosticSetting             = "DeployIfNotExists"
    effect_DeployFirewallDiagnosticSetting             = "DeployIfNotExists"
    effect_DeployKeyvaultDiagnosticSetting             = "AuditIfNotExists"
    effect_DeployLoadbalancerDiagnosticSetting         = "AuditIfNotExists"
    effect_DeployNetworkInterfaceDiagnosticSetting     = "AuditIfNotExists"
    effect_DeployNetworkSecurityGroupDiagnosticSetting = "AuditIfNotExists"
    effect_DeployPublicIpDiagnosticSetting             = "AuditIfNotExists"
    effect_DeployStorageAccountDiagnosticSetting       = "DeployIfNotExists"
    effect_DeploySubscriptionDiagnosticSetting         = "DeployIfNotExists"
    effect_DeployVnetDiagnosticSetting                 = "AuditIfNotExists"
    effect_DeployVnetGatewayDiagnosticSetting          = "AuditIfNotExists"
  }
}


##################
# Storage
##################
module "mod_mg_storage_enforce_https" {
  source            = "../../../terraform/core/modules/Microsoft.Authorization/policyDefAssignment/managementGroup"
  definition        = module.storage_enforce_https.definition
  assignment_scope  = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/platforms"].id
  assignment_effect = "Deny"
}

module "mod_mg_storage_enforce_minimum_tls1_2" {
  source            = "../../../terraform/core/modules/Microsoft.Authorization/policyDefAssignment/managementGroup"
  definition        = module.storage_enforce_minimum_tls1_2.definition
  assignment_scope  = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/platforms"].id
  assignment_effect = "Deny"
}
