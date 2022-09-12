// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

/*
SUMMARY: Overlay Module Example to deploy the Azure Kubernetes Cluster.
DESCRIPTION: The following components will be options in this deployment
              * Azure Kubernetes Cluster
AUTHOR/S: jspinella
VERSION: 1.x.x
*/

targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

// REQUIRED PARAMETERS
// Example (JSON)
// -----------------------------
// "parRequired": {
//   "value": {
//     "orgPrefix": "anoa",
//     "templateVersion": "v1.0",
//     "deployEnvironment": "mlz"
//   }
// }
@description('Required values used with all resources.')
param parRequired object

// REQUIRED TAGS
// Example (JSON)
// -----------------------------
// "parTags": {
//   "value": {
//     "organization": "anoa",
//     "region": "eastus",
//     "templateVersion": "v1.0",
//     "deployEnvironment": "platforms",
//     "deploymentType": "NoOpsBicep"
//   }
// }
@description('Required tags values used with all resources.')
param parTags object

@description('The region to deploy resources into. It defaults to the deployment location.')
param parLocation string = deployment().location

// AZURE KUBERNETES SERVICE - CLUSTER PARAMETERS

@description('Defines the Azure Kubernetes Service - Cluster.')
param parKubernetesCluster object 

// SUBSCRIPTIONS PARAMETERS

@description('The subscription ID for the Hub Network and resources. It defaults to the deployment subscription.')
param parTargetSubscriptionId string = subscription().subscriptionId

@description('The name of the resource group in which the key vault will be deployed. If unchanged or not specified, the NoOps Accelerator shared services resource group is used.')
param parTargetResourceGroup string

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()


@description('The current date - do not override the default value')
param dateUtcNow string = utcNow('yyyy-MM-dd HH:mm:ss')

/*
  NAMING CONVENTION
  Here we define a naming conventions for resources.
  First, we take `parDeployEnvironment` and `parDeployEnvironment` by params.
  Then, using string interpolation "${}", we insert those values into a naming convention.
*/

var varResourceToken = 'resource_token'
var varNameToken = 'name_token'
var varNamingConvention = '${toLower(parRequired.orgPrefix)}-${toLower(parLocation)}-${toLower(parRequired.deployEnvironment)}-${varNameToken}-${toLower(varResourceToken)}'

// RESOURCE NAME CONVENTIONS WITH ABBREVIATIONS

var varResourceGroupNamingConvention = replace(varNamingConvention, varResourceToken, 'rg')

// AZURE KUBERNETES SERVICE - CLUSTER NAMES

var varKubernetesClusterName = parKubernetesCluster.name
var varKubernetesClusterResourceGroupName = replace(varResourceGroupNamingConvention, varNameToken, varKubernetesClusterName)

var referential = {
  region: parLocation
  deploymentDate: dateUtcNow
}


@description('Resource group tags')
module modTags '../../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
  name: 'deploy-conreg-tags--${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parTargetSubscriptionId)
  params: {
    tags: union(parTags, referential)
  }
}

// AZURE KUBERNETES SERVICE - CLUSTER

// Create Azure Kubernetes Cluster resource group
resource rgKubernetesCluster 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: (!empty(parTargetResourceGroup)) ? parTargetResourceGroup : varKubernetesClusterResourceGroupName
  location: parLocation
}

// Create Azure Kubernetes Cluster
module modKubernetesCluster '../../../azresources/Modules/Microsoft.ContainerService/managedClusters/az.container.aks.cluster.bicep' = {
  scope: resourceGroup(parTargetSubscriptionId, rgKubernetesCluster.name)
  name: 'deploy-conReg-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    name: varKubernetesClusterName
    location: parLocation
    primaryAgentPoolProfile: parKubernetesCluster.primaryAgentPoolProfile
    tags: modTags.outputs.tags
  }
}
