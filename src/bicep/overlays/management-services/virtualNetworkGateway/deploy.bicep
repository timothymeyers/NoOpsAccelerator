// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

/*
SUMMARY: Module to deploy a Virutal Network Gateway to the Hub Network
DESCRIPTION: The following components will be options in this deployment
              Virutal Network Gateway
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

@description('The ANOA template version')
@minLength(3)
param parTemplateVersion string = '1.0'

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

var subnetName = 'GatewaySubnet' // The subnet name for VNG Hosts must be 'GatewaySubnet'
param subnetAddressPrefix string

// VIRTUAL NETWORK GATEWAY PARAMETERS

@allowed([
  'Vpn'
  'ExpressRoute'
  'LocalGateway'
])
@description('The type of this virtual network gateway.')
param parGatewayType string = 'Vpn'

@allowed([
  'Basic'
  'ErGw1AZ'
  'ErGw2AZ'
  'ErGw3AZ'
  'HighPerformance'
  'Standard'
  'UltraPerformance'
  'VpnGw1'
  'VpnGw1AZ'
  'VpnGw2'
  'VpnGw2AZ'
  'VpnGw3'
  'VpnGw3AZ'
  'VpnGw4'
  'VpnGw4AZ'
  'VpnGw5'
  'VpnGw5AZ'
])
@description('Gateway SKU name.')
param parGatewaySku string = 'HighPerformance'

@allowed([
  'RouteBased'
  'PolicyBased'
])
@description('The type of this virtual network gateway.')
param parVpnType string = 'RouteBased'

@description('Switch which set the VNet Gateway to Active/Active Default: true')
param parSetActiveActive bool = true

@description('Switch which set the VNet Gateway to Bgp Default: false')
param parEnableBgp bool = false

/*
  NAMING CONVENTION
  Here we define a naming conventions for resources.
  First, we take `parDeployEnvironment` and `parDeployEnvironment` by params.
  Then, using string interpolation "${}", we insert those values into a naming convention.
*/

var varResourceToken = 'resource_token'
var varNameToken = 'name_token'
var varNamingConvention = '${toLower(parOrgPrefix)}-${toLower(parLocation)}-${toLower(parDeployEnvironment)}-${varNameToken}-${toLower(varResourceToken)}'

var varVirtualNetworkGatewayNamingConvention = replace(varNamingConvention, varResourceToken, 'vgway')

var varHubName = 'hub'
var varHubVirtualNetworkGatewayName = replace(varVirtualNetworkGatewayNamingConvention, varNameToken, varHubName)

//=== TAGS === 

@description('Resource group tags')
module modTags '../../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
  name: 'vnetg-tags-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription()
  params: {
    onlyUpdate: true
    resourceGroupName: parHubResourceGroupName
    tags: {
      hostName: parDeployEnvironment
      regionName: parLocation
      templateVersion: parTemplateVersion
      applicationName: 'vNetGateway'
      organizationName: parOrgPrefix
    }
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

module modHubVNetGateway '../../../azresources/Modules/Microsoft.Network/virtualNetworkGateway/az.net.hub.virtual.network.gateway.bicep' = {
  name: 'deploy-${varHubName}-vnet-gateway-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    // Required parameters
    name: varHubVirtualNetworkGatewayName
    location: parLocation
    tags: modTags.outputs.tags
    virtualNetworkGatewaySku: parGatewaySku
    virtualNetworkGatewayType: parGatewayType
    vNetResourceId: resHubVirtualNetwork.id

    // Non-required parameters
    lock: 'CanNotDelete'
    publicIpZones: [
      '1'
    ]
    activeActive: parSetActiveActive
    enableBgp: parEnableBgp
    asn: 65000
    vpnType: parVpnType

    diagnosticWorkspaceId: parLogAnalyticsWorkspaceResourceId
    diagnosticStorageAccountId: parHubLogStorageResourceId
  }
  dependsOn: [
    resSubnet
  ]
}
