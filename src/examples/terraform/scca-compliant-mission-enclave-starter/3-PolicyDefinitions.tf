# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy Policy Definitions for Azure Policy
DESCRIPTION: The following components will be options in this deployment
             * Policy Definitions
AUTHOR/S: jspinella
*/

#################################################
### STAGE 3: Policy Definitions Configuations ###
#################################################

##################
# General
##################
module "deny_resources_types" {
  depends_on = [
    module.mod_management_group
  ]
  source              = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path           = "../../../policyascode/definitions/custom/general/deny_resources_types.json"
  policy_name         = "deny_resources_types"
  display_name        = "Deny Azure Resource types"
  policy_category     = "General"
  management_group_id = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/anoa"].id
}

module "allow_regions" {
  depends_on = [
    module.mod_management_group
  ]
  source              = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path           = "../../../policyascode/definitions/custom/general/allow_regions.json"
  policy_name         = "allow_regions"
  display_name        = "Allow Azure Regions"
  policy_category     = "General"
  management_group_id = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/anoa"].id
}

##################
# Monitoring
##################

# create definitions by looping around all files found under the Monitoring category folder
module "deploy_resource_diagnostic_setting" {
  depends_on = [
    module.mod_management_group
  ]
  source              = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  for_each            = toset([for p in fileset("../../../policyascode/definitions/custom/monitoring", "*.json") : trimsuffix(basename(p), ".json")])
  file_path           = "../../../policyascode/definitions/custom/monitoring/${each.key}.json"
  policy_name         = each.key
  policy_category     = "Monitoring"
  management_group_id = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/anoa"].id
}

##################
# Network
##################
module "deny_nic_public_ip" {
  depends_on = [
    module.mod_management_group
  ]
  source              = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path           = "../../../policyascode/definitions/custom/network/deny_nic_public_ip.json"
  policy_name         = "deny_nic_public_ip"
  display_name        = "Network interfaces should not have public IPs"
  policy_category     = "Network"
  management_group_id = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/anoa"].id
}

##################
# Storage
##################
module "storage_enforce_https" {
  depends_on = [
    module.mod_management_group
  ]
  source              = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path           = "../../../policyascode/definitions/custom/storage/storage_enforce_https.json"
  policy_name         = "storage_enforce_https"
  display_name        = "Secure transfer to storage accounts should be enabled"
  policy_category     = "Storage"
  policy_mode         = "Indexed"
  management_group_id = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/anoa"].id
}

module "storage_enforce_minimum_tls1_2" {
  depends_on = [
    module.mod_management_group
  ]
  source              = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path           = "../../../policyascode/definitions/custom/storage/storage_enforce_minimum_tls1_2.json"
  policy_name         = "storage_enforce_minimum_tls1_2"
  display_name        = "Minimum TLS version for data in transit to storage accounts should be set"
  policy_category     = "Storage"
  policy_mode         = "Indexed"
  management_group_id = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/anoa"].id
}

##################
# Tags
##################

module "inherit_resource_group_tags_modify" {
  depends_on = [
    module.mod_management_group
  ]
  source              = "../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path           = "../../../policyascode/definitions/custom/tags/inherit_resource_group_tags_modify.json"
  policy_name         = "inherit_resource_group_tags_modify"
  display_name        = "Resources should inherit Resource Group Tags and Values with Modify Remediation"
  policy_category     = "Tags"
  policy_mode         = "Indexed"
  management_group_id = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/anoa"].id
}

##############################################################
### STAGE 3.1: Policy Initiative Definitions Configuations ###
##############################################################

#####################################################
# Monitoring: Resource & Activity Log Forwarders  ###
#####################################################
module "platform_diagnostics_initiative" {
  depends_on = [
    module.deploy_resource_diagnostic_setting
  ]
  source                  = "../../../terraform/core/modules/Microsoft.Authorization/policyInitiative"
  initiative_name         = "platform_diagnostics_initiative"
  initiative_display_name = "[Platform]: Diagnostics Settings Policy Initiative"
  initiative_description  = "Collection of policies that deploy resource and activity log forwarders to logging core resources"
  initiative_category     = "Monitoring"
  merge_effects           = false # will not merge "effect" parameters
  management_group_id     = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/anoa"].id

  # Populate member_definitions with a for loop (not explicit)
  member_definitions = [for mon in module.deploy_resource_diagnostic_setting : mon.definition]
}