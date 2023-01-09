# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################
# General
##################
module "deny_resources_types" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path       = "../../../../../policyascode/definitions/custom/general/deny_resources_types.json"
  policy_name     = "deny_resources_types"
  display_name    = "Deny Azure Resource types"
  policy_category = "General"
  //management_group_id = module.management_group.management_groups[var.root_management_group_id].id
}

module "allow_regions" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path       = "../../../../../policyascode/definitions/custom/general/allow_regions.json"
  policy_name     = "allow_regions"
  display_name    = "Allow Azure Regions"
  policy_category = "General"
}

##################
# Monitoring
##################

# create definitions by looping around all files found under the Monitoring category folder
module "deploy_resource_diagnostic_setting" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  for_each        = toset([for p in fileset("../../../../../policyascode/definitions/custom/Monitoring", "*.json") : trimsuffix(basename(p), ".json")])
  file_path       = "../../../../../policyascode/definitions/custom/Monitoring/${each.key}.json"
  policy_name     = each.key
  policy_category = "Monitoring"
}

##################
# Network
##################
module "deny_nic_public_ip" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path       = "../../../../../policyascode/definitions/custom/Network/deny_nic_public_ip.json"
  policy_name     = "deny_nic_public_ip"
  display_name    = "Network interfaces should not have public IPs"
  policy_category = "Network"
}

##################
# Storage
##################
module "storage_enforce_https" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path       = "../../../../../policyascode/definitions/custom/Storage/storage_enforce_https.json"
  policy_name     = "storage_enforce_https"
  display_name    = "Secure transfer to storage accounts should be enabled"
  policy_category = "Storage"
  policy_mode     = "Indexed"
}

module "storage_enforce_minimum_tls1_2" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path       = "../../../../../policyascode/definitions/custom/Storage/storage_enforce_minimum_tls1_2.json"
  policy_name     = "storage_enforce_minimum_tls1_2"
  display_name    = "Minimum TLS version for data in transit to storage accounts should be set"
  policy_category = "Storage"
  policy_mode     = "Indexed"
}

##################
# Tags
##################

module "inherit_resource_group_tags_modify" {
  depends_on = [
    module.mod_management_group
  ]
  source          = "../../../../../terraform/core/modules/Microsoft.Authorization/policyDefinition"
  file_path       = "../../../../../policyascode/definitions/custom/Tags/inherit_resource_group_tags_modify.json"
  policy_name     = "inherit_resource_group_tags_modify"
  display_name    = "Resources should inherit Resource Group Tags and Values with Modify Remediation"
  policy_category = "Tags"
  policy_mode     = "Indexed"
}
