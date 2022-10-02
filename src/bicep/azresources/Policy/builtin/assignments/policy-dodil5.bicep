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

@description('Log Analytics Resource Id to integrate Microsoft Defender for Cloud.')
param parLogAnalyticsWorkspaceId string

@description('List of members that should be excluded from Windows VM Administrator Group.')
param parListOfMembersToExcludeFromWindowsVMAdministratorsGroup string

@description('List of members that should be included in Windows VM Administrator Group.')
param parListOfMembersToIncludeInWindowsVMAdministratorsGroup string

var varPolicyId = 'f9a961fa-3241-4b20-adc4-bbf8ad9d7197' // DoD Impact Level 5 (Azure Government) /providers/Microsoft.Authorization/policySetDefinitions/f9a961fa-3241-4b20-adc4-bbf8ad9d7197
var varAssignmentName = 'DoD Impact Level 5 (Azure Government)'

var varScope = tenantResourceId('Microsoft.Management/managementGroups', parPolicyAssignmentManagementGroupId)
var varPolicyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', varPolicyId)

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../../../azresources/Modules/Global/telemetry.json'))
module telemetryCustomerUsageAttribution '../../../../azresources//Modules/Global/partnerUsageAttribution/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.policy}-dod-il5'
}


resource resPolicySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'dodil5-${uniqueString('dod-il5-',parPolicyAssignmentManagementGroupId)}'
  properties: {
    displayName: varAssignmentName
    policyDefinitionId: varPolicyScopedId
    scope: varScope
    notScopes: [
    ]
    parameters: {
      logAnalyticsWorkspaceIdforVMReporting: {
        value: parLogAnalyticsWorkspaceId
       }
       listOfMembersToExcludeFromWindowsVMAdministratorsGroup: {
        value: parListOfMembersToExcludeFromWindowsVMAdministratorsGroup
       }
       listOfMembersToIncludeInWindowsVMAdministratorsGroup: {
        value: parListOfMembersToIncludeInWindowsVMAdministratorsGroup
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
  name: guid(parPolicyAssignmentManagementGroupId, 'dod-il5-contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    principalId: resPolicySetAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
