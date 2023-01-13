# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#####################################################
# Monitoring: Resource & Activity Log Forwarders  ###
#####################################################
module "platform_diagnostics_initiative" {
  source                  = "../../../terraform/core/modules/Microsoft.Authorization/policyInitiative"
  initiative_name         = "platform_diagnostics_initiative"
  initiative_display_name = "[Platform]: Diagnostics Settings Policy Initiative"
  initiative_description  = "Collection of policies that deploy resource and activity log forwarders to logging core resources"
  initiative_category     = "Monitoring"
  merge_effects           = false # will not merge "effect" parameters

  # Populate member_definitions with a for loop (not explicit)
  member_definitions = [for mon in module.deploy_resource_diagnostic_setting : mon.definition]
}