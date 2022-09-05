// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

// PARAMETERS
param policySource string = 'ANOA'
param policyCategory string = 'Network'

// VARAIBLES
var builtinPolicies_network = json(loadTextContent('../../../policy_id_library/network.json'))

resource computePolicySet 'Microsoft.Authorization/policySetDefinitions@2020-03-01' = {
  name: 'custom-keyVault'
  properties: {
    displayName: 'Custom - Network Governance Initiative'
    description: 'Network Governance Initiative - MG Scope via ${policySource}'
    metadata: {
      category: policyCategory
      source: policySource
      version: '1.0.0'      
      author: policySource
    }
    parameters: {
      
    }
    policyDefinitionGroups: [
      {
        name: 'Network'
        displayName: 'Network Governance Controls'
      }
      {
        name: 'CUSTOM'
        displayName: 'Additional Controls as Custom Policies'
      }
    ]
    policyDefinitions: [
      {
        groupNames: [
          'Network'
        ]
        policyDefinitionId: builtinPolicies_network.NetworkWatcherShouldBeEnabled
        policyDefinitionReferenceId: toLower(replace('Network Watcher Should Be Enabled', ' ', '-'))
        parameters: {}
      }      
    ]
  }
}
