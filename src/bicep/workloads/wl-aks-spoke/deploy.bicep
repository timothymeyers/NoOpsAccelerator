/*
SUMMARY: Workload Module to deploy a Azure Kubernetes Service to an target sub.
DESCRIPTION: The following components will be options in this deployment
              Azure Kubernetes Service
AUTHOR/S: jspinella
VERSION: 1.x.x
*/

/*
Copyright (c) Microsoft Corporation. Licensed under the MIT license.
*/

// === PARAMETERS ===
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

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

// WORKLOAD PARAMETERS

@description('Required values used with the workload, Please review the Read Me for required parameters')
param parWorkload object

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

@description('The virtual network name for the Hub Network.')
param parHubFirewallPolicyName string

@description('The firewall private IP address for the Hub Network.')
param parFirewallPrivateIPAddress string

@description('The firewall source addresses for the Rule Collection Groups, Must be Hub/Spoke addresses.')
param parSourceAddresses array = []

// LOGGING PARAMETERS

@description('Log Analytics Workspace Resource Id Needed for NSG, VNet and Activity Logging')
param parLogAnalyticsWorkspaceResourceId string

@description('Log Analytics Workspace Name Needed Activity Logging')
param parLogAnalyticsWorkspaceName string

// Azure Container Registry
// Example (JSON)
// -----------------------------
// "parContainerRegistry": {
//   "value": {
//     "name": "anoa-eastus-dev-acr",
//     "acrSku": "Premium",
//     "enableResourceLock": true,
//     "privateEndpoints": [
//       {
//         "privateDnsZoneGroup": {
//           "privateDNSResourceIds": [
//             "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
//           ]
//         },
//         "service": "registry",
//         "subnetResourceId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-005-privateEndpoints"
//       }
//     ]
//   }
// }
@description('Defines the Container Registry.')
param parContainerRegistry object

// Azure Kubernetes Service - Cluster
// Example (JSON)
// -----------------------------
// "parKubernetesCluster": {
//   "value": {
//     "name": "anoa-eastus-dev-aks",
//     "enableSystemAssignedIdentity": true,
//     "aksClusterKubernetesVersion": "1.21.9",
//     "enableResourceLock": true,
//     "primaryAgentPoolProfile": [
//       {
//         "name": "aksPoolName",
//         "vmSize": "Standard_DS3_v2",
//         "osDiskSizeGB": 128,
//         "count": 2,
//         "osType": "Linux",
//         "type": "VirtualMachineScaleSets",
//         "mode": "System"
//       }
//     ],
//     "aksClusterLoadBalancerSku": "standard",
//     "aksClusterNetworkPlugin": "azure",
//     "aksClusterNetworkPolicy": "azure",
//     "aksClusterDnsServiceIP": "",
//     "aksClusterServiceCidr": "",
//     "aksClusterDockerBridgeCidr": "",
//     "aksClusterDnsPrefix": "anoaaks"
//   }
// }
@description('Parmaters Object of Azure Kubernetes specified when creating the managed cluster.')
param parKubernetesCluster object

// Storage Account RBAC
// Example (JSON)
// -----------------------------
// "parStorageAccountAccess": {
//   "value": {
//     "enableRoleAssignmentForStorageAccount": true,
//     "principalIds": [
//       "xxxxxx-xxxxx-xxxxx-xxxx-xxxxxxx"
//     ],
//     "roleDefinitionIdOrName": "Group"
//   }
// },  
@description('Account for access to Storage')
param parStorageAccountAccess object

// SUPPORTED CLOUDS PARAMETERS

param parSupportedClouds array = [
  'AzureCloud'
  'AzureUSGovernment'
]

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../azresources/Modules/Global/telemetry.json'))
module telemetryCustomerUsageAttribution '../../azresources/Modules/Global/partnerUsageAttribution/customer-usage-attribution-subscription.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.workloads.aks}'
  scope: subscription(parWorkload.subscriptionId)
}

//=== TAGS === 

var referential = {
  workload: parWorkload.name
}

@description('Resource group tags')
module modTags '../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
  name: 'AKS-Resource-Tags-${parDeploymentNameSuffix}'
  scope: subscription()
  params: {
    tags: union(parTags, referential)
  }
}

//=== Workload Tier 3 Buildout === 
module modTier3 '../../azresources/hub-spoke-core/tier3/anoa.lz.workload.network.bicep' = {
  name: 'deploy-wl-vnet-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parWorkload.subscriptionId)
  params: {
    //Required Parameters
    parWorkloadName: parWorkload.name
    parWorkloadShortName: parWorkload.shortName
    parDeployEnvironment: parRequired.deployEnvironment
    parLocation: parLocation
    parTags: modTags.outputs.tags

    //Hub Network Parameters
    parHubSubscriptionId: parHubSubscriptionId
    parHubVirtualNetworkResourceId: parHubVirtualNetworkResourceId
    parHubVirtualNetworkName: parHubVirtualNetworkName
    parHubResourceGroupName: parHubResourceGroupName

    //WorkLoad Parameters
    parWorkloadSubscriptionId: parWorkload.subscriptionId
    parWorkloadVirtualNetworkAddressPrefix: parWorkload.network.virtualNetworkAddressPrefix
    parWorkloadSubnetAddressPrefix: parWorkload.network.subnetAddressPrefix

    //Firewall Parameters
    parFirewallPrivateIPAddress: parFirewallPrivateIPAddress

    //Logging Parameters
    parLogAnalyticsWorkspaceName: parLogAnalyticsWorkspaceName
    parLogAnalyticsWorkspaceResourceId: parLogAnalyticsWorkspaceResourceId

    //Storage Parameters
    parStorageAccountAccess: parStorageAccountAccess
    enableActivityLogging: true

  }
}

//=== End Workload Tier 3 Buildout === 

//=== Azure Kubernetes Service Workload Buildout === 

module firewallAKSAppRuleCollectionGroup '../../azresources/Modules/Microsoft.Network/firewallPolicies/ruleCollectionGroups/az.net.rule.groups.bicep' = {
  name: 'deploy-aks-appruleGroup-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: '${parWorkload.shortName}ApplicationRuleCollectionGroup'
    firewallPolicyName: parHubFirewallPolicyName
    priority: 210
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            name: 'Allow-ifconfig'
            ruleType: 'ApplicationRule'
            protocols: [
              {
                port: 80
                protocolType: 'Http'
              }
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              'ifconfig.co'
              'api.snapcraft.io'
              'jsonip.com'
              'kubernaut.io'
              'motd.ubuntu.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: parSourceAddresses
            destinationAddresses: []
            sourceIpGroups: []
          }
        ]
        name: 'Helper-tools'
        priority: 101
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            name: 'Egress'
            ruleType: 'ApplicationRule'
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            ipProtocols: [
              'Https'
            ]
            targetFqdns: [
              '*.azmk8s.io'
              'aksrepos.azurecr.io'
              '*.blob.core.windows.net'
              'mcr.microsoft.com'
              '*.cdn.mscr.io'
              'management.azure.com'
              'login.microsoftonline.com'
              'packages.azure.com'
              'acs-mirror.azureedge.net'
              '*.opinsights.azure.com'
              '*.monitoring.azure.com'
              'dc.services.visualstudio.com'
            ]
            sourceAddresses: parSourceAddresses
          }
          {
            name: 'Registries'
            ruleType: 'ApplicationRule'
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            ipProtocols: [
              'Https'
            ]
            targetFqdns: [
              '*.data.mcr.microsoft.com'
              '*.azurecr.io'
              '*.gcr.io'
              'gcr.io'
              'storage.googleapis.com'
              '*.docker.io'
              'quay.io'
              '*.quay.io'
              '*.cloudfront.net'
              'production.cloudflare.docker.com'
            ]
            sourceAddresses: parSourceAddresses
          }
          {
            name: 'Additional-Usefull-Address'
            ruleType: 'ApplicationRule'
            protocols: [
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            ipProtocols: [
              'Https'
            ]
            targetFqdns: [
              'grafana.net'
              'grafana.com'
              'stats.grafana.org'
              'github.com'
              'raw.githubusercontent.com'
              'security.ubuntu.com'
              'security.ubuntu.com'
              'packages.microsoft.com'
              'azure.archive.ubuntu.com'
              'security.ubuntu.com'
              'hack32003.vault.azure.net'
              '*.letsencrypt.org'
              'usage.projectcalico.org'
              'gov-prod-policy-data.trafficmanager.net'
              'vortex.data.microsoft.com'
            ]
            sourceAddresses: parSourceAddresses
          }
          {
            name: 'AKS-FQDN-TAG'
            ruleType: 'ApplicationRule'
            protocols: [
              {
                port: 80
                protocolType: 'Http'
              }
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            targetFqdns: []
            fqdnTags: [
              'AzureKubernetesService'
            ]
            sourceAddresses: parSourceAddresses
          }
        ]
        name: 'AKS-egress-application'
        priority: 102
      }
    ]
  }
}

module firewallAKSNetworkRuleCollectionGroup '../../azresources/Modules/Microsoft.Network/firewallPolicies/ruleCollectionGroups/az.net.rule.groups.bicep' = {
  name: 'deploy-aks-networkruleGroup-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubResourceGroupName)
  params: {
    name: '${parWorkload.shortName}NetworkRuleCollectionGroup'
    firewallPolicyName: parHubFirewallPolicyName
    priority: 250
    ruleCollections: [     
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'NTP'
            ipProtocols: [
              'UDP'
            ]
            sourceAddresses: parSourceAddresses
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '123'
            ]
          }
        ]
        name: 'AKS-egress'
        priority: 100
      }
    ]
  }
}

module modAcrDeploy '../../overlays/management-services/containerRegistry/deploy.bicep' = {
  name: 'deploy-aks-acr-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parWorkload.subscriptionId)
  params: {
    parLocation: parLocation
    parContainerRegistry: parContainerRegistry
    parRequired: parRequired
    parTags: modTags.outputs.tags
    parTargetResourceGroup: modTier3.outputs.workloadResourceGroupName
    parTargetSubscriptionId: parWorkload.subscriptionId
    parTargetSubnetName: modTier3.outputs.subnetNames[0]
    parTargetVNetName: modTier3.outputs.virtualNetworkName
  }
  dependsOn: [
    modTier3
  ]
}

// Create a AKS Cluster
module modDeployAzureKS '../../overlays/management-services/kubernetesCluster/deploy.bicep' = {
  scope: subscription(parWorkload.subscriptionId)
  name: 'deploy-aks-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    parLocation: parLocation
    parKubernetesCluster: parKubernetesCluster
    parRequired: parRequired
    parTags: modTags.outputs.tags
    parTargetResourceGroup: modTier3.outputs.workloadResourceGroupName
    parTargetSubnetName: modTier3.outputs.subnetNames[0]
    parTargetVNetName: modTier3.outputs.virtualNetworkName
    parTargetSubscriptionId: parWorkload.subscriptionId
    parHubVirtualNetworkResourceId: parHubVirtualNetworkResourceId
    parLogAnalyticsWorkspaceResourceId: parLogAnalyticsWorkspaceResourceId
  }
  dependsOn: [
    modTier3
  ]
}

//=== End Azure Kubernetes Service Workload Buildout === 

output azureKubernetesName string = parKubernetesCluster.name
output azureKubernetesResourceId string = modDeployAzureKS.outputs.aksResourceId
output azureContainerRegistryResourceId string = modAcrDeploy.outputs.acrResourceId
output workloadResourceGroupName string = modTier3.outputs.workloadResourceGroupName
output tags object = modTags.outputs.tags
