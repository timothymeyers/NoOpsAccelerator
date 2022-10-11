/*
SUMMARY: Module to deploy the Workload Network (tier 3) and it's components based on the Azure Mission Landing Zone conceptual architecture 
DESCRIPTION: The following components will be options in this deployment
              Workload Virtual Network (Vnet)
              Subnets  
              Route Table
              Network Security Group
              Log Storage
              Activity Logging
              Netowrk Peering (Hub/Spoke)
AUTHOR/S: jspinella
VERSION: 1.x.x
*/

/*
Copyright (c) Microsoft Corporation. Licensed under the MIT license.
*/

targetScope = 'subscription'

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

@description('The subscription ID for the Workload Network and resources. It defaults to the deployment subscription.')
param parWorkloadSubscriptionId string = subscription().subscriptionId

@description('The region to deploy resources into. It defaults to the deployment location.')
param parLocation string = deployment().location

@minLength(3)
@maxLength(12)
@description('Prefix value which will be the workload name. Default: workload')
param parWorkloadName string = 'workload'

@minLength(3)
@maxLength(12)
@description('Prefix value which will be the workload name. Default: wk1')
param parWorkloadShortName string = 'wk1'

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

// HUB PARAMETERS

@description('The subscription ID for the Hub Network.')
param parHubSubscriptionId string

@description('The resource group name for the Hub Network.')
param parHubResourceGroupName string

@description('The virtual network name for the Hub Network.')
param parHubVirtualNetworkName string

@description('The virtual network resource Id for the Hub Network.')
param parHubVirtualNetworkResourceId string

// WORKLOAD NETWORK PARAMETERS

@description('Required values used with the workload, Please review the Read Me for required parameters')
param parWorkloadSpoke object

// LOGGING PARAMETERS

@description('The Storage Account SKU to use for log storage. It defaults to "Standard_GRS". See https://docs.microsoft.com/en-us/rest/api/storagerp/srp_sku_types for valid settings.')
param parLogStorageSkuName string = 'Standard_GRS'

@description('Log Analytics Workspace Resource Id Needed for NSG, VNet and Activity Logging')
param parLogAnalyticsWorkspaceResourceId string

@description('Log Analytics Workspace Name Needed Activity Logging')
param parLogAnalyticsWorkspaceName string

@description('Enable this setting if this network is on a different subscriptiom as the Hub. Will give conflict errors if on same sub as the Hub')
param parEnableActivityLogging bool = false

// ROUTE TABLE 

@description('An array of Route Table routes to apply to the Workload Virtual Network. If custom routes are enabled, over write the default. it  See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/routetables/routes?tabs=bicep#routepropertiesformat for valid settings.')
param parRouteTableRoutes array = [] 

@description('Switch which allows Bgp Route Propagation. Default: false') 
param parDisableBgpRoutePropagation bool = false

// STORAGE ACCOUNTS RBAC
@description('Account for access to Storage')
param parWorkloadStorageAccountAccess object

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

var varNetworkSecurityGroupNamingConvention = replace(varNamingConvention, varResourceToken, 'nsg')
var varResourceGroupNamingConvention = replace(varNamingConvention, varResourceToken, 'rg')
var varStorageAccountNamingConvention = toLower('${parRequired.orgPrefix}st${varNameToken}unique_storage_token')
var varSubnetNamingConvention = replace(varNamingConvention, varResourceToken, 'snet')
var varVirtualNetworkNamingConvention = replace(varNamingConvention, varResourceToken, 'vnet')
var varDdosNamingConvention = replace(varNamingConvention, varResourceToken, 'ddos')

// WORKLOAD NAMES

var varWorkloadName = parWorkloadName
var varWorkloadShortName = parWorkloadShortName
var varWorkloadResourceGroupName = replace(varResourceGroupNamingConvention, varNameToken, varWorkloadName)
var varWorkloadLogStorageAccountShortName = replace(varStorageAccountNamingConvention, varNameToken, replace(varWorkloadShortName, '-', ''))
var varWorkloadLogStorageAccountUniqueName = replace(varWorkloadLogStorageAccountShortName, 'unique_storage_token', uniqueString(parWorkloadSubscriptionId, parLocation, parRequired.deployEnvironment, parRequired.orgPrefix))
var varWorkloadLogStorageAccountName = take(varWorkloadLogStorageAccountUniqueName, 23)
var varWorkloadVirtualNetworkName = replace(varVirtualNetworkNamingConvention, varNameToken, varWorkloadName)
var varWorkloadNetworkSecurityGroupName = replace(varNetworkSecurityGroupNamingConvention, varNameToken, varWorkloadName)
var varWorkloadSubnetName = replace(varSubnetNamingConvention, varNameToken, varWorkloadName)
var workloadddosName = replace(varDdosNamingConvention, varNameToken, varWorkloadName)

// ROUTETABLE VALUES
var varRouteTableName = '${varWorkloadSubnetName}-routetable'

// TAGS

@description('Workload Resource group tags')
module modTags '../../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
  name: 'deploy-${varWorkloadShortName}-tags-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    tags: parTags
  }
}

// RESOURCE GROUPS

module modWorkloadResourceGroup '../../../azresources/Modules/Microsoft.Resources/resourceGroups/az.resource.groups.bicep' = {
  name: 'deploy-${varWorkloadShortName}-rg-${parDeploymentNameSuffix}'
  scope: subscription(parWorkloadSubscriptionId)
  params: {
    name: varWorkloadResourceGroupName
    location: parLocation
    tags: modTags.outputs.tags
  }
}

//STORAGE ACCOUNT

module modWorkloadLogStorage '../../../azresources/Modules/Microsoft.Storage/storageAccounts/az.data.storage.bicep' = {
  name: 'deploy-${varWorkloadShortName}-logStorage-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(varWorkloadResourceGroupName)
  params: {
    name: varWorkloadLogStorageAccountName
    location: parLocation
    storageAccountSku: parLogStorageSkuName
    tags: modTags.outputs.tags
    roleAssignments: (parWorkloadStorageAccountAccess.enableRoleAssignmentForStorageAccount) ? [
      {
        principalIds: [
          parWorkloadStorageAccountAccess.principalIds
        ]
        roleDefinitionIdOrName: parWorkloadStorageAccountAccess.roleDefinitionIdOrName
      }
    ] : []
    lock: 'CanNotDelete'
  }
  dependsOn: [
    modWorkloadResourceGroup
  ]
}

// NETWORK SECURITY GROUP

module modWorkloadNetworkSecurityGroup '../../../azresources/Modules/Microsoft.Network/networkSecurityGroups/az.net.network.security.group.with.diagnostics.bicep' = {
  name: 'deploy-${varWorkloadShortName}-nsg-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(varWorkloadResourceGroupName)
  params: {
    name: varWorkloadNetworkSecurityGroupName
    location: parLocation
    tags: modTags.outputs.tags

    securityRules: parWorkloadSpoke.network.networkSecurityGroupRules

    diagnosticWorkspaceId: parLogAnalyticsWorkspaceResourceId
    diagnosticStorageAccountId: modWorkloadLogStorage.outputs.resourceId

    diagnosticLogCategoriesToEnable: parWorkloadSpoke.network.networkSecurityGroupDiagnosticsLogs
  }
}

module modWorkloadRouteTable '../../../azresources/Modules/Microsoft.Network/routeTable/az.net.route.table.bicep' = {
  name: 'deploy-${varWorkloadShortName}-rt-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(varWorkloadResourceGroupName)
  params: {
    name: varRouteTableName
    location: parLocation
    tags: modTags.outputs.tags

    routes: parRouteTableRoutes
    disableBgpRoutePropagation: parDisableBgpRoutePropagation
  }
  dependsOn: [
    modWorkloadResourceGroup
  ]
}

module modWorkloadVirtualNetwork '../../../azresources/Modules/Microsoft.Network/virtualNetworks/az.net.virtual.network.with.diagnostics.bicep' = {
  name: 'deploy-${varWorkloadShortName}-vnet-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(varWorkloadResourceGroupName)
  params: {
    name: varWorkloadVirtualNetworkName
    location: parLocation
    tags: modTags.outputs.tags

    addressPrefixes: [
      parWorkloadSpoke.network.virtualNetworkAddressPrefix
    ]

    subnets: union([
      {
        addressPrefix: parWorkloadSpoke.network.subnetAddressPrefix
        name: varWorkloadSubnetName
        networkSecurityGroupId: modWorkloadNetworkSecurityGroup.outputs.resourceId
        routeTableId: modWorkloadRouteTable.outputs.resourceId
        serviceEndpoints: parWorkloadSpoke.network.subnetServiceEndpoints
      }
    ], parWorkloadSpoke.network.subnets) 
    
    diagnosticWorkspaceId: parLogAnalyticsWorkspaceResourceId
    diagnosticStorageAccountId: modWorkloadLogStorage.outputs.resourceId

    diagnosticLogCategoriesToEnable: parWorkloadSpoke.network.virtualNetworkDiagnosticsLogs
    diagnosticMetricsToEnable: parWorkloadSpoke.network.virtualNetworkDiagnosticsMetrics
    ddosProtectionPlanEnabled: parWorkloadSpoke.enableDdosProtectionPlan
    ddosProtectionPlanId: workloadddosName
  }
}

module modWorkloadVirtualNetworkPeerings '../../../azresources/hub-spoke-core/peering/spoke/anoa.lz.spoke.network.peering.bicep' = {
  name: 'deploy-hub-peerings-${varWorkloadShortName}-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parWorkloadSubscriptionId, varWorkloadResourceGroupName)
  params: {
    parHubVirtualNetworkName: parHubVirtualNetworkName
    parHubVirtualNetworkResourceId: parHubVirtualNetworkResourceId
    parSpokeName: parWorkloadName
    parSpokeResourceGroupName: modWorkloadResourceGroup.outputs.name
    parSpokeVirtualNetworkName: modWorkloadVirtualNetwork.outputs.name
  }
}

module modHubToWorkloadVirtualNetworkPeering '../../../azresources/hub-spoke-core/peering/hub/anoa.lz.hub.network.peerings.bicep' = {
  name: 'deploy-spoke-peerings-${varWorkloadShortName}-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubSubscriptionId, parHubResourceGroupName)
  params: {
    parHubVirtualNetworkName: parHubVirtualNetworkName
    parSpokes: [
      {
        name: parWorkloadName
        virtualNetworkResourceId: modWorkloadVirtualNetwork.outputs.resourceId
        virtualNetworkName: modWorkloadVirtualNetwork.outputs.name
      }
    ]
  }
}

module spokeWorkloadSubscriptionActivityLogging '../../../azresources/Modules/Microsoft.Insights/diagnosticSettings/az.insights.diagnostic.setting.bicep' = if (parEnableActivityLogging) {
  name: 'deploy-logs-${varWorkloadShortName}-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    name: 'log-workload-sub-activity-to-${parLogAnalyticsWorkspaceName}'
    diagnosticWorkspaceId: parLogAnalyticsWorkspaceResourceId
  }
  dependsOn: [
    modWorkloadVirtualNetwork
    modWorkloadLogStorage
  ]

}

output virtualNetworkName string = modWorkloadVirtualNetwork.outputs.name
output virtualNetworkResourceId string = modWorkloadVirtualNetwork.outputs.resourceId
output subnetNames array = modWorkloadVirtualNetwork.outputs.subnetNames
output subnetResourceIds array = modWorkloadVirtualNetwork.outputs.subnetResourceIds
output networkSecurityGroupName string = modWorkloadNetworkSecurityGroup.outputs.name
output networkSecurityGroupResourceId string = modWorkloadNetworkSecurityGroup.outputs.resourceId
output workloadResourceGroupName string = varWorkloadResourceGroupName
output workloadLogStorageAccountName string = varWorkloadLogStorageAccountName
output workloadLogStorageAccountResourceId string = modWorkloadLogStorage.outputs.resourceId
