// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

/*
SUMMARY: The Management Groups module deploys a management group hierarchy in a tenant under the 'Tenant Root Group'.
DESCRIPTION: Management Group hierarchy is created through a tenant-scoped Azure Resource Manager (ARM) deployment.  

AUTHOR/S: John Spinella
VERSION: 1.0.0
*/

targetScope = 'managementGroup'

@description('Provide prefix for the root management group structure.')
param parRootMg string

@description('Provide prefix for the management group structure.')
param parRequireAuthorizationForGroupCreation bool 

@description('These are the landing zone management groups.')
param parManagementGroups array 

@description('Provide prefix for the management group structure.')
param parSubscriptions array

@description('Provide prefix for the management group structure.')
param parTenantId string

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

// Create Management Groups
@batchSize(1)
module resource_managementGroups '../../azresources/Modules/Microsoft.Management/managementGroups/az.mgmt.groups.bicep' = [for managementGroup in parManagementGroups: {
    name: managementGroup.name     
    params:{
        displayName: managementGroup.displayName      
        name: managementGroup.name
        parentId: managementGroup.parentMGName
    }                                                                
}]

// Move Subscriptions to Management Groups
module movesubs '../../azresources/Modules/Microsoft.Management/managementGroups/subscriptionMovement/az.mgmt.groups.sub.movement.bicep' = [for subscription in parSubscriptions: {
  name: 'move-${subscription.subscriptionId}-${parDeploymentNameSuffix}'
  scope: tenant() 
  dependsOn: resource_managementGroups
  params: {
      parSubscriptionId: subscription.subscriptionId
      parTargetManagementGroupId: subscription.managementGroupName
  }
}]

// Configure Default Management Group Settings

resource rootmg 'Microsoft.Management/managementGroups@2021-04-01' existing = {
  name: parTenantId
  scope: tenant() 
}

resource mg_settings 'Microsoft.Management/managementGroups/settings@2021-04-01' = {
  parent: rootmg
  name: 'default'
  dependsOn: resource_managementGroups
  properties: {
      defaultManagementGroup: '/providers/Microsoft.Management/managementGroups/${parRootMg}'
      requireAuthorizationForGroupCreation: parRequireAuthorizationForGroupCreation
  }
}
