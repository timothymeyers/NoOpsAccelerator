// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

/*
SUMMARY: Module to deploy a Application Gateway to the Hub Network
DESCRIPTION: The following components will be options in this deployment
              Application Gateway
AUTHOR/S: jspinella
VERSION: 1.x.x
*/

// === PARAMETERS ===
targetScope = 'resourceGroup'

// REQUIRED PARAMETERS

@description('Prefix value which will be prepended to all resource names. Default: anoa')
param parOrgPrefix string = 'anoa'

@description('The resource group name for the Hub Network and resources.')
param parHubResourceGroupName string

@description('The resource group name for the Hub Network name.')
param parHubVirtualNetworkName string

@description('The region to deploy resources into. It defaults to the deployment location.')
param parLocation string = resourceGroup().location

@description('Tags for the Resource')
param parTags object

@minLength(3)
@maxLength(15)
@description('A suffix, 3 to 15 characters in length, to append to resource names (e.g. "dev", "test", "prod", "platforms"). It defaults to "platforms".')
param parDeployEnvironment string

@description('The resource group name for the Hub Network and resources. It defaults to the deployment resource group.')
param parLogAnalyticsWorkspaceResourceId string

@description('The resource group name for the Hub Network and resources. It defaults to the deployment resource group.')
param parHubLogStorageResourceId string

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

//

var subnetName = 'AppGWSubnet' // The subnet name for VNG Hosts must be 'AppGWSubnet'
param subnetAddressPrefix string

// APP GATEWAY PARAMETERS

@description('Application gateway tier')
@allowed([
  'Standard'
  'WAF'
  'Standard_v2'
  'WAF_v2'
])
param parTier string

@description('Application gateway sku')
@allowed([
  'Standard_Small'
  'Standard_Medium'
  'Standard_Large'
  'WAF_Medium'
  'WAF_Large'
  'Standard_v2'
  'WAF_v2'
])
param parSku string

@description('Array containing front end ports')
@metadata({
  name: 'Front port name'
  port: 'Integer containing port number'
})
param parFrontEndPorts array

@description('Array containing http listeners')
@metadata({
  name: 'Listener name'
  protocol: 'Listener protocol'
  frontEndPort: 'Front end port name'
  sslCertificate: 'SSL certificate name' // only required for https listeners
  hostNames: 'Array containing host names'
  firewallPolicy: 'Enabled/Disabled. Configures firewall policy on listener'
})
param parHttpListeners array

@description('Array containing request routing rules')
@metadata({
  name: 'Rule name'
  ruleType: 'Rule type'
  listener: 'Http listener name'
  backendPool: 'Backend pool name'
  backendHttpSettings: 'Backend http setting name'
  redirectConfiguration: 'Redirection configuration name'
})
param parRules array

@description('Public ip address name')
param parPublicIpAddressName string

@description('Application gateway subnet name')
param parSubnetName string

/*
  NAMING CONVENTION
  Here we define a naming conventions for resources.
  First, we take `parDeployEnvironment` and `parDeployEnvironment` by params.
  Then, using string interpolation "${}", we insert those values into a naming convention.
*/

var varResourceToken = 'resource_token'
var varNameToken = 'name_token'
var varNamingConvention = '${toLower(parOrgPrefix)}-${toLower(parLocation)}-${toLower(parDeployEnvironment)}-${varNameToken}-${toLower(varResourceToken)}'

var varApplicationGatewayNamingConvention = replace(varNamingConvention, varResourceToken, 'agway')

var varHubName = 'hub'
var varHubApplicationGatewayName = replace(varApplicationGatewayNamingConvention, varNameToken, varHubName)

//=== TAGS === 

var referential = {
  workload: 'appGateway'
}

@description('Resource group tags')
module modTags '../../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
  name: 'appg-tags-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription()
  params: {    
    resourceGroupName: parHubResourceGroupName
    tags: union(parTags, referential)
  }
}

// HUB VNET

resource resHubVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: parHubVirtualNetworkName
}

// ADD GATEWAY SUBNET TO HUB

resource resSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: '${parHubVirtualNetworkName}/${subnetName}'

  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

// HUB VNET GATEWAY - VDMS

module modHubAppGateway '../../../azresources/Modules/Microsoft.Network/applicationGateway/az.net.application.gateway.bicep' = {
  name: 'deploy-${varHubName}-vnet-gateway-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    // Required parameters
    applicationGatewayName: varHubApplicationGatewayName
    location: parLocation    
    frontEndPorts: parFrontEndPorts
    httpListeners: parHttpListeners
    publicIpAddressName: parPublicIpAddressName
    rules: parRules
    sku: parSku
    subnetName: parSubnetName
    tier: parTier
    vNetName: resHubVirtualNetwork.name
    vNetResourceGroup: parHubResourceGroupName
    diagnosticStorageAccountId: parHubLogStorageResourceId
    enableDiagnostics: true
  }
  dependsOn: [
    resSubnet
  ]
}
