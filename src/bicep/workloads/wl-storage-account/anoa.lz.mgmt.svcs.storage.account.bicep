/*
SUMMARY: Workload Module to deploy premium storage account to support hardware backed secrets and certificates storage to an target sub and RG.
DESCRIPTION: The following components will be options in this deployment
              Azure Storage Account 
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

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

// STORAGE ACCOUNTS PARAMETERS

param parSkuName string

// STORAGE ACCOUNTS RBAC

@description('Account for access to Storage')
param parStorageAccountAccessObjectId string

@description('Account Type Defaults: Group')
param parStorageAccountAccessType string

@description('Switch which allows Role Assignment for the Storage Account. Default: true')
param parAddRoleAssignmentForStorageAccount bool = true

// === VARIABLES ===

@description('The name of the key vault which will be created. Must be clobally unique, between 3 and 24 characters and only single hyphens permitted. If unchanged or not specified, the NoOps Accelerator resource prefix + "-akv" will be utilized.')
var nameToken = 'name_token'
var sharedServicesShortName = 'svcs'
var storageAccountNamingConvention = toLower('${parDeployEnvironment}st${nameToken}unique_storage_token')
var sharedServicesStorageAccountShortName = replace(storageAccountNamingConvention, nameToken, sharedServicesShortName)
var sharedServicesStorageAccountUniqueName = replace(sharedServicesStorageAccountShortName, 'unique_storage_token', uniqueString(parOrgPrefix, parDeployEnvironment, parTargetSubscriptionId))
var sharedServicesStorageAccountName = take(sharedServicesStorageAccountUniqueName, 23)

//=== RESOURCES ===

//=== TAGS === 

@description('Resource group tags')
module tags '../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
  name: 'Storage-Service-Resource-Tags-${parDeploymentNameSuffix}'
  params: {
    tags: {
      hostName: parDeployEnvironment
      regionName: parLocation
      templateVersion: parTemplateVersion
    }
  }
}

//=== Storage Account Buildout === 
resource resTargetASPResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: parTargetResourceGroup
  location: parLocation
}

module modDeployAzureStorageAccount '../../azresources/Modules/Microsoft.Storage/storageAccounts/az.data.storage.bicep' = {
  scope: resourceGroup(parTargetSubscriptionId, resTargetASPResourceGroup.name)
  name: 'deploy-storage-account-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    location: parLocation
    name: sharedServicesStorageAccountName
    storageAccountSku: parSkuName
    tags: tags
    roleAssignments: (parAddRoleAssignmentForStorageAccount) ? [
      {
        principalIds: [
          parStorageAccountAccessObjectId
        ]
        roleDefinitionIdOrName: parStorageAccountAccessType
      }
    ] : []
  } 
}
//=== End Storage Account Buildout === 

output azureStorageAccountName string = sharedServicesStorageAccountName
output resourceGroupName string = resTargetASPResourceGroup.name
output tags object = tags
