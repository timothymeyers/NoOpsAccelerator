// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

/*
SUMMARY: Overlay Example to deploy role defintions to a existing enclave
DESCRIPTION: The following components will be options in this deployment
              * Roles
                * Custom - VM Operator
                * Custom - Network Operations (NetOps)
                * Custom - Security Operations (SecOps)
                * Custom - Landing Zone Application Owner
                * Custom - Landing Zone Subscription Owner
                * Custom - Storage Operator
              
AUTHOR/S: jspinella
VERSION: 1.x.x
*/

targetScope = 'managementGroup'

// REQUIRED PARAMETERS
param parRoleDefinitionInfo object
param parDefaultManagementGroupIdForRoleDefinitions string

param parLocation string = deployment().location

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

//module to trigger custom role vm_operator 
module role_definitions '../../azresources/Modules/Microsoft.Authorization/roleDefinitions/az.auth.role.definition.bicep' = [for (definitionInfo, i) in array(parRoleDefinitionInfo): {
  name: 'enclave-RoleDef-${i}-${parDeploymentNameSuffix}'
  params: {    
    location: parLocation
    roleName:  definitionInfo.roleName
    actions: definitionInfo.actions
    managementGroupId: parDefaultManagementGroupIdForRoleDefinitions   
  }
}]

