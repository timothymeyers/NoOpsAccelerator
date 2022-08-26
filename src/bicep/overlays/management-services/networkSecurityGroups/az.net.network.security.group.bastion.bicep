/* Copyright (c) Microsoft Corporation. Licensed under the MIT license. */
// ----------------------------------------------------------------------------------
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

/*
SUMMARY: Module to deploy the Network Security Group (Bastion Rules) to an metwork 
DESCRIPTION: The following components will be options in this deployment
              Network Security Group
AUTHOR/S: jspinella
VERSION: 1.x.x
*/

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

@description('Network Security Group Name.')
param parName string

@description('Tags for Network Security Group.')
param parTags object = {}

@description('Resource group tags')
module modTags '../../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = if (empty(parTags)) {
  name: 'hubspoke-tags-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription()
  params: {
    onlyUpdate: true
    tags: {
      organizationName: parOrgPrefix
      hostName: parDeployEnvironment
      regionName: parLocation
      templateVersion: '1.0'
    }
  }
}

module networkSecurityGroupBastion '../../../azresources/Modules/Microsoft.Network/networkSecurityGroup/az.net.network.security.group.with.diagnostics.bicep' = {
  name: 'deploy-nsg-bastion-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    name: parName
    location: parLocation
    tags: (empty(parTags)) ? modTags : parTags
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          priority: 130
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'GatewayManager'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Allow'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '22'
            '3389'
          ]
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          priority: 110
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureCloud'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

// Outputs
output nsgId string = networkSecurityGroupBastion.outputs.resourceId
