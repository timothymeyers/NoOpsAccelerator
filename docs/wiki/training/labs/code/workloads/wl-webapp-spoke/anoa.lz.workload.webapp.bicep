/*
SUMMARY: Workload Module to deploy a premium Azure Web App to an target sub and RG.
DESCRIPTION: The following components will be options in this deployment
              Azure Web App    
AUTHOR/S: jspinella
VERSION: 1.x.x
*/

/*
Copyright (c) Microsoft Corporation.
Licensed under the MIT License.
*/

// === PARAMETERS ===
targetScope = 'subscription'

// REQUIRED PARAMETERS

@description('Prefix value which will be prepended to all resource names. Default: anoa')
param parOrgPrefix string = 'anoa'

@description('The region to deploy resources into. It defaults to the deployment location.')
param parLocation string = deployment().location

@description('The ANOA template version')
@minLength(3)
param parTemplateVersion string = '1.0'

@minLength(3)
@maxLength(15)
@description('A suffix, 3 to 15 characters in length, to append to resource names (e.g. "dev", "test", "prod", "platforms"). It defaults to "platforms".')
param parDeployEnvironment string = 'platforms'

// SUBSCRIPTIONS PARAMETERS

@description('The subscription ID for the Hub Network and resources. It defaults to the deployment subscription.')
param parTargetSubscriptionId string = subscription().subscriptionId

@description('The name of the resource group in which the key vault will be deployed. If unchanged or not specified, the NoOps Accelerator shared services resource group is used.')
param parTargetResourceGroup string

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

// === VARIABLES ===

@description('The name of the key vault which will be created. Must be clobally unique, between 3 and 24 characters and only single hyphens permitted. If unchanged or not specified, the NoOps Accelerator resource prefix + "-akv" will be utilized.')
var nameToken = 'name_token'
var resourceToken = 'resource_token'
var sharedServicesShortName = 'svcs'
var kvNamingConvention = '${toLower(parOrgPrefix)}-${toLower(parLocation)}-${nameToken}-${toLower(resourceToken)}'
var keyVaultNamingConvention = replace(kvNamingConvention, resourceToken, 'kv')
var sharedServicesKeyVaultName = replace(keyVaultNamingConvention, nameToken, sharedServicesShortName)

//=== RESOURCES ===

//=== TAGS === 

@description('Resource group tags')
module modTags '../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
  name: 'Web-App-Resource-Tags-${parDeploymentNameSuffix}'
  params: {
    tags: {
      hostName: parDeployEnvironment
      regionName: parLocation
      templateVersion: parTemplateVersion
      organizationName: parOrgPrefix
    }
  }
}

//=== Web App Buildout === 
resource resTargetASPResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: parTargetResourceGroup
  location: parLocation
}

module modDeployAzureWebApp '../../azresources/Modules/Microsoft.Web/sites/az.web.app.bicep' = {
  scope: resourceGroup(parTargetSubscriptionId, resTargetASPResourceGroup.name)
  name: 'deploy-web-app-${parLocation}-${parDeploymentNameSuffix}'
  params: {    
    location: parLocation
    kind: 'app'
    name: ''
    serverFarmResourceId: ''
  }
}
//=== End Web App Buildout === 

output azureKeyVaultName string = sharedServicesKeyVaultName
output resourceGroupName string = resTargetASPResourceGroup.name
output tags object = modTags.outputs.tags
