/*
SUMMARY: Workload Module to deploy a Azure Kubernetes Service to an target sub.
DESCRIPTION: The following components will be options in this deployment
              Azure Kubernetes Service
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

@description('Tags for the resource')
param parTags object

@minLength(3)
@maxLength(15)
@description('A suffix, 3 to 15 characters in length, to append to resource names (e.g. "dev", "test", "prod", "platforms"). It defaults to "platforms".')
param parDeployEnvironment string = 'platforms'

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

// WORKLOAD PARAMETERS

@description('The subscription ID for the Hub Network and resources. It defaults to the deployment subscription.')
param parWorkloadSubscriptionId string = subscription().subscriptionId

@description('The CIDR Virtual Network Address Prefix for the Workload Virtual Network.')
param parWorkloadVirtualNetworkAddressPrefix string = '10.8.125.0/26'

@description('The CIDR Subnet Address Prefix for the default Workload subnet. It must be in the Workload Virtual Network space.')
param parWorkloadSubnetAddressPrefix string = '10.8.125.0/27'

// HUB NETWORK PARAMETERS

@description('The subscription ID for the Hub Network.')
param parHubSubscriptionId string

@description('The resource group name for the Hub Network.')
param parHubResourceGroupName string

@description('The virtual network name for the Hub Network.')
param parHubVirtualNetworkName string

@description('The virtual network resource Id for the Hub Network.')
param parHubVirtualNetworkResourceId string

// FIREWALL PARAMETERS

@description('The firewall private IP address for the Hub Network.')
param parFirewallPrivateIPAddress string

// LOGGING PARAMETERS

@description('Log Analytics Workspace Resource Id Needed for NSG, VNet and Activity Logging')
param parLogAnalyticsWorkspaceResourceId string

@description('Log Analytics Workspace Name Needed Activity Logging')
param parLogAnalyticsWorkspaceName string

// AKS PARAMETERS

@description('The name of the workload. Default: workload')
param parWorkloadName string = 'workload'

@description('Optional. Version of Kubernetes specified when creating the managed cluster.')
param parAksClusterKubernetesVersion string = ''

@description('Specifies the CIDR notation IP range assigned to the Docker bridge network. It must not overlap with any Subnet IP ranges or the Kubernetes service address range.')
param parAksClusterDockerBridgeCidr string = '172.17.0.1/16'

@description('Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools.')
param parAksClusterLoadBalancerSku string = 'standard'

@description('Specifies whether to create the cluster as a private cluster or not.')
param parEnablePrivateCluster bool = false

@description('Whether to enable Azure Defender.')
param parEnableAzureDefender bool = false

// === VARIABLES ===
/*
  NAMING CONVENTION
  Here we define a naming conventions for resources.
  First, we take `parDeployEnvironment` and `parDeployEnvironment` by params.
  Then, using string interpolation "${}", we insert those values into a naming convention.
*/
@description('The name of the Azure Kubernetes Service which will be created. Must be clobally unique, between 3 and 24 characters and only single hyphens permitted. If unchanged or not specified, the NoOps Accelerator resource prefix + "-akv" will be utilized.')
var varResourceToken = 'resource_token'
var varNameToken = 'name_token'
var varNamingConvention = '${toLower(parOrgPrefix)}-${toLower(parLocation)}-${toLower(parDeployEnvironment)}-${varNameToken}-${toLower(varResourceToken)}'

// RESOURCE NAME CONVENTIONS WITH ABBREVIATIONS
var varResourceGroupNamingConvention = replace(varNamingConvention, varResourceToken, 'rg')
var varAKSNamingConvention = replace(varNamingConvention, varResourceToken, 'aks')
var varACRNamingConvention = replace(varNamingConvention, varResourceToken, 'acr')

var varAKSResourceGroupName = replace(varResourceGroupNamingConvention, varNameToken, parWorkloadName)
var varACRName = replace(varACRNamingConvention, varNameToken, parWorkloadName)
var varAKSName = replace(varAKSNamingConvention, varNameToken, parWorkloadName)

//=== RESOURCES ===

//=== TAGS === 

var referential = {
  workload: parWorkloadName
}

@description('Resource group tags')
module modTags '../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
  name: 'Web-App-Resource-Tags-${parDeploymentNameSuffix}'
  params: {
    tags: union(parTags, referential)
  }
}

//=== Workload Tier 3 Buildout === 
module modTier3 '../../azresources/hub-spoke/tier3/anoa.lz.workload.network.bicep' = {
  name: 'deploy-wl-vnet-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    //Required Parameters
    parDeployEnvironment: parDeployEnvironment
    parLocation: parLocation
    parTags: modTags.outputs.tags

    //Hub Network Parameters
    parHubSubscriptionId: parHubSubscriptionId
    parHubVirtualNetworkResourceId: parHubVirtualNetworkResourceId
    parHubVirtualNetworkName: parHubVirtualNetworkName
    parHubResourceGroupName: parHubResourceGroupName
     
    //WorkLoad Parameters
    parWorkloadSubscriptionId: parWorkloadSubscriptionId
    parWorkloadVirtualNetworkAddressPrefix: parWorkloadVirtualNetworkAddressPrefix
    parWorkloadSubnetAddressPrefix: parWorkloadSubnetAddressPrefix 

    //Firewall Parameters
    parFirewallPrivateIPAddress: parFirewallPrivateIPAddress

    //Logging Parameters
    parLogAnalyticsWorkspaceName: parLogAnalyticsWorkspaceName
    parLogAnalyticsWorkspaceResourceId: parLogAnalyticsWorkspaceResourceId

    //Storage Parameters
    parStorageAccountAccess: {

    }

  }
}

//=== End Workload Tier 3 Buildout === 

//=== Azure Kubernetes Service Buildout === 

module modAksRg '../../azresources/Modules/Microsoft.Resources/resourceGroups/az.resource.groups.bicep' = {
  name: 'deploy-aks-rg-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parWorkloadSubscriptionId)
  params: {
    // Required parameters
    name: varAKSResourceGroupName
    location: parLocation
    tags: modTags.outputs.tags
  }
  dependsOn:[ 
    modTier3
  ]
}

module modAcrDeploy '../../azresources/Modules/Microsoft.ContainerRegistry/registries/az.container.registry.bicep' = {
  name: 'deploy-aks-acr-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parWorkloadSubscriptionId, modAksRg.name)
  params: {
    // Required parameters
    name: varACRName
    location: parLocation
    tags: modTags.outputs.tags
    // Non-required parameters
    acrAdminUserEnabled: false
    acrSku: 'Premium'
    privateEndpoints: [
      {
        service: 'registry'
        subnetResourceId: modTier3.outputs.subnetResourceIds[0]
        privateDnsZoneGroup: {

        }
      }
    ]
  }
  dependsOn:[ 
    modAksRg
  ]
}

module modPrivateDNS '../../azresources/Modules/Microsoft.Network/privateDnsZones/az.net.private.dns.bicep' = {
  name: 'deploy-aks-acr-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parWorkloadSubscriptionId, modAksRg.name)
  params: {
    // Required parameters
    name: ''
    location: parLocation
    tags: modTags.outputs.tags
  }
  dependsOn:[
    modAksRg
  ]
}

module aksIdentity '../../azresources/Modules/Microsoft.ManagedIdentity/userAssignedIdentities/az.managed.identity.user.assigned.bicep' = {
  scope: resourceGroup(parWorkloadSubscriptionId, modAksRg.name)
  name: 'aksIdentity'
  params: {
     name: 'baseName'
     location: parLocation
  }
  dependsOn:[ 
    modAksRg
  ]
}

module modDeployAzureKS '../../azresources/Modules/Microsoft.ContainerService/managedClusters/az.container.aks.cluster.bicep' = {
  scope: resourceGroup(parWorkloadSubscriptionId, modAksRg.name)
  name: 'deploy-aks-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    // Required parameters
    location: parLocation
    name: varAKSName
    userAssignedIdentities: {
      '${aksIdentity.outputs.resourceId}' : {}
    }  

    // Non-Required parameters
    aksClusterKubernetesVersion: parAksClusterKubernetesVersion
    nodeResourceGroup: '${varAKSName}-aksInfraRG'
    aksClusterDnsPrefix: '${varAKSName}aksInfra'

    //agentPoolProfiles
    primaryAgentPoolProfile: [
      {
        availabilityZones: [
          '1'
        ]
        count: 1
        enableAutoScaling: true
        maxCount: 3
        maxPods: 30
        minCount: 1
        mode: 'System'
        name: 'systempool'
        osDiskSizeGB: 0
        osType: 'Linux'       
        storageProfile: 'ManagedDisks'
        type: 'VirtualMachineScaleSets'
        vmSize: 'Standard_DS2_v2'
        vnetSubnetID: modTier3.outputs.subnetResourceIds[0]
      }
    ]  
  
    //NetworkProfile
    aksClusterLoadBalancerSku: parAksClusterLoadBalancerSku
    aksClusterNetworkPlugin: 'azure'
    aksClusterOutboundType: 'userDefinedRouting'
    aksClusterDockerBridgeCidr: parAksClusterDockerBridgeCidr
    aksClusterDnsServiceIP: '10.2.0.10'
    aksClusterServiceCidr: '10.2.0.0/24'
    aksClusterNetworkPolicy: 'azure'
  
    //ApiServerAccessProfile
    enablePrivateCluster: parEnablePrivateCluster
    usePrivateDNSZone: true
    enablePrivateClusterPublicFQDN: true

    //AadProfile
    aadProfileEnableAzureRBAC: true  
    aadProfileManaged: true
    aadProfileAdminGroupObjectIDs: [
      
    ]
    aadProfileTenantId: ''
    systemAssignedIdentity: true

    //AddonProfiles
    omsAgentEnabled: true 
    monitoringWorkspaceId: parLogAnalyticsWorkspaceName

    //Azure policy
    azurePolicyEnabled: true

    // Logging
    enableAzureDefender: parEnableAzureDefender         
    diagnosticLogsRetentionInDays: 7
    diagnosticStorageAccountId: modTier3.outputs.workloadLogStorageAccountResourceId
    diagnosticWorkspaceId: parLogAnalyticsWorkspaceName       
  }
  dependsOn:[ 
    modAksRg
  ]
}

//=== End Azure Kubernetes Service Buildout === 

output azureKubernetesName string = varAKSName
output azureKubernetesResourceId string = modDeployAzureKS.outputs.resourceId
output workloadResourceGroupName string = modTier3.outputs.workloadResourceGroupName
output aksResourceGroupName string = modAksRg.outputs.name
output tags object = modTags.outputs.tags
