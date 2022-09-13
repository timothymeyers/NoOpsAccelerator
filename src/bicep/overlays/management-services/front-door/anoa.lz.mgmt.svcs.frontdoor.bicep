// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

/*
SUMMARY: Module to deploy a Front Door Host to the Hub Network
DESCRIPTION: The following components will be options in this deployment
              Front Door Host             
AUTHOR/S: jspinella
VERSION: 1.x.x
*/

// REQUIRED PARAMETERS

@description('Prefix value which will be prepended to all resource names. Default: anoa')
param parOrgPrefix string = 'anoa'

@description('The region to deploy resources into. It defaults to the deployment location.')
param parLocation string = resourceGroup().location

@minLength(3)
@maxLength(15)
@description('A suffix, 3 to 15 characters in length, to append to resource names (e.g. "dev", "test", "prod", "platforms"). It defaults to "platforms".')
param parDeployEnvironment string = 'platforms'

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

@description('Tags')
param parTags object = {}

@description('The Hub Virtual Network Name')
param parHubVirtualNetworkName string

@description('The Hub Subnet Resource Id')
param parHubSubnetResourceId string

/*
  NAMING CONVENTION
  Here we define a naming conventions for resources.
  First, we take `parDeployEnvironment` and `parDeployEnvironment` by params.
  Then, using string interpolation "${}", we insert those values into a naming convention.
*/

var varResourceToken = 'resource_token'
var varNameToken = 'name_token'
var varNamingConvention = '${toLower(parOrgPrefix)}-${toLower(parLocation)}-${toLower(parDeployEnvironment)}-${varNameToken}-${toLower(varResourceToken)}'

// RESOURCE NAME CONVENTIONS WITH ABBREVIATIONS

var varBastionHostNamingConvention = replace(varNamingConvention, varResourceToken, 'bas')
var varVirtualMachineNamingConvention = replace(varNamingConvention, varResourceToken, 'vm')
var varPublicIpAddressNamingConvention = replace(varNamingConvention, varResourceToken, 'pip')
var varIpConfigurationNamingConvention = replace(varNamingConvention, varResourceToken, 'ipconf')
var varNetworkInterfaceNamingConvention = replace(varNamingConvention, varResourceToken, 'nic')

@description('Resource group tags')
module modTags '../../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = if (empty(parTags)) {
  name: 'deploy-ra-tags--${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription()
  params: {
    tags: parTags
  }
}

resource resHubVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: parHubVirtualNetworkName
}

resource resBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: '${parHubVirtualNetworkName}/AzureBastionSubnet'

  properties: {
    addressPrefix: parBastionHostSubnetAddressPrefix
  }
}

module modfrontDoorHost '../../../azresources/Modules/Microsoft.Network/frontDoor/az.net.front.door.bicep' = {
  name: 'deploy-frontDoor-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    name: '' 
    location: parLocation     
  }
}
