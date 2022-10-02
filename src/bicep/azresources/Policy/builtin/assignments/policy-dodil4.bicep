// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

@description('Location for the deployment.')
param parLocation string = deployment().location

@description('Management Group scope for the policy assignment.')
param parPolicyAssignmentManagementGroupId string

@allowed([
  'Default'
  'DoNotEnforce'
])
@description('Policy set assignment enforcement mode.  Possible values are { Default, DoNotEnforce }.  Default value:  Default')
param parEnforcementMode string = 'Default'

@description('Log Analytics Workspace Data Retention in days.')
param parRequiredRetentionDays string

var varPolicyId = '8d792a84-723c-4d92-a3c3-e4ed16a2d133' // DoD Impact Level 4 (Azure Government) /providers/Microsoft.Authorization/policySetDefinitions/8d792a84-723c-4d92-a3c3-e4ed16a2d133
var varAssignmentName = 'DoD Impact Level 4 (Azure Government)'

var varScope = tenantResourceId('Microsoft.Management/managementGroups', parPolicyAssignmentManagementGroupId)
var varPolicyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', varPolicyId)

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../../../azresources/Modules/Global/telemetry.json'))
module telemetryCustomerUsageAttribution '../../../../azresources//Modules/Global/partnerUsageAttribution/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.policy}-dod-il4'
}


resource resPolicySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'dodil4-${uniqueString('dod-il4-',parPolicyAssignmentManagementGroupId)}'
  properties: {
    displayName: varAssignmentName
    policyDefinitionId: varPolicyScopedId
    scope: varScope
    notScopes: [
    ]
    parameters: {
      parRequiredRetentionDays: {
        value: parRequiredRetentionDays
      }
    }
    enforcementMode: parEnforcementMode
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: parLocation
}

// These role assignments are required to allow Policy Assignment to remediate.
resource policySetRoleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(parPolicyAssignmentManagementGroupId, 'dod-il4-contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalId: resPolicySetAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
