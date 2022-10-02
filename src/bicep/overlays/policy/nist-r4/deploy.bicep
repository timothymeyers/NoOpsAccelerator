// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

/*
SUMMARY: Overlay Example to deploy Bulit-In/Custom policy defintions/assignments to a existing enclave
DESCRIPTION: The following components will be options in this deployment
              * Policies
                * Bulit-In - NIST SP 800-53 R4                      
              
AUTHOR/S: jspinella
*/

targetScope = 'managementGroup'

//REQUIRED PARAMETERS
param parPolicy object

@description('The region to deploy resources into. It defaults to the deployment location.')
param parLocation string = deployment().location

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../../azresources/Modules/Global/telemetry.json'))
module telemetryCustomerUsageAttribution '../../../azresources//Modules/Global/partnerUsageAttribution/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.policy}-nist-80053-r4'
}

// BUILT-IN POLICIES
//NIST SP 800-53 R4 Policy
module polNISTR4 '../../../azresources/Policy/builtin/assignments/policy-nist80053r4.bicep' = if (parPolicy.bulitInPolicy.policies.enabled) {
  name: 'NISTR5DefintionDeployment-${parDeploymentNameSuffix}'
  params: {
    parPolicyAssignmentManagementGroupId: parPolicy.bulitInPolicy.policies.policyAssignmentManagementGroupId
    parLocation: parLocation
    parListOfMembersToExcludeFromWindowsVMAdministratorsGroup: parPolicy.bulitInPolicy.policies.listOfMembersToExcludeFromWindowsVMAdministratorsGroup
    parListOfMembersToIncludeInWindowsVMAdministratorsGroup: parPolicy.bulitInPolicy.policies.listOfMembersToIncludeInWindowsVMAdministratorsGroup
    parLogAnalyticsWorkspaceId: parPolicy.bulitInPolicy.policies.logAnalyticsWorkspaceId
  }
}

