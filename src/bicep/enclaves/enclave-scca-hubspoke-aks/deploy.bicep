/*
SUMMARY: Module Example to deploy the Full Hub/ 1 Spoke Enclave with AKS Workload
DESCRIPTION: The following components will be options in this deployment
            * Managment Groups
            * Policy (Network, IAM, Data Protection, Monitoring, AKS)
            * Roles
            * Hub Virtual Network (VNet)              
              * Operations Artifacts (Optional)
              * Bastion Host (Optional)
              * DDos Standard Plan (Optional)
              * Microsoft Defender for Cloud (Optional)              
            * Spokes
             * Operations (Tier 1)
            * Logging
              * Azure Sentinel
              * Azure Log Analytics            
            * Azure Firewall
            * Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> [https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration) 
            * Workload: (Tier 3) - Azure Kubernetes Service
AUTHOR/S: jspinella
VERSION: 1.x.x
*/

/*
Copyright (c) Microsoft Corporation. Licensed under the MIT license.
*/

/*
  PARAMETERS
  Here are all the parameters a user can override.
  These are the required parameters that Network does not provide a default for:    
    - parDeployEnvironment
*/

// **Scope**
targetScope = 'managementGroup'

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

// SUBSCRIPTIONS

// HUB NETWORK
// Example (JSON)
// -----------------------------
@description('The object for the Hub Network and resources. It defaults to the deployment subscription.')
param parHub object

// OPERATIONS SPOKE NETWORK 
// Example (JSON)
// -----------------------------
@description('The object for the Operations Spoke Network and resources. It defaults to the deployment subscription.')
param parOperationsSpoke object

// OPERATIONS NETWORK ARTIFACTS
// Example (JSON)
// -----------------------------
// "parNetworkArtifacts": {
//   "value": {
//     "enable": false,
//     "artifactsKeyVault": {
//       "keyVaultPolicies": {
//         "objectId": "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx",
//         "permissions": {
//           "keys": [
//             "get",
//             "list",
//             "update"
//           ],
//           "secrets": [
//             "all"
//           ]
//         },
//         "tenantId": "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx"
//       }
//     }
//   }
// }
@description('Enables Operations Network Artifacts Resource Group with KV and Storage account for the ops subscriptions used in the deployment.')
param parNetworkArtifacts object

//DDOS PARAMETERS

@description('Enables DDOS deployment on the Hub Network.')
param parDdosStandard object

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

@description('The current date - do not override the default value')
param dateUtcNow string = utcNow('yyyy-MM-dd HH:mm:ss')

// FIREWALL PARAMETERS

@description('Switch which allows Azure Firewall deployment to be disabled. Default: true')
param parAzureFirewall object

// LOGGING PARAMETERS
// Logging
// Example (JSON)
// -----------------------------
// "parLogging": {
//   "value": {
//     "enableSentinel": "true",     When set to "true", enables Microsoft Sentinel within the Log Analytics Workspace
//     "logAnalyticsWorkspaceCappingDailyQuotaGb": -1,     The daily quota for Log Analytics Workspace logs in Gigabytes. The default is "-1" for no quota.
//     "logAnalyticsWorkspaceRetentionInDays": 30,     The number of days to retain Log Analytics Workspace logs. The default is "30"
//     "logAnalyticsWorkspaceSkuName": "PerGB2018",     [Free/Standard/Premium/PerNode/PerGB2018/Standalone] The SKU for the Log Analytics Workspace.
//     "logStorageSkuName": "Standard_GRS"      The Storage Account SKU to use for log storage. The default is "Standard_GRS".
//   }
// }
@description('Enables logging parmeters and Microsoft Sentinel within the Log Analytics Workspace created in this deployment.')
param parLogging object

// STORAGE ACCOUNTS RBAC

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

// MICROSOFT DEFENDER PARAMETERS

// Microsoft Defender for Cloud
// Example (JSON)
// -----------------------------
// "parSecurityCenter": {
//   "value": {
//       "enableDefender: true,
//       "emailSecurityContact": "anoa@microsoft.com",
//       "phoneSecurityContact": "5555555555"
//   }
// }
@description('Microsoft Defender for Cloud.  It includes email and phone.')
param parSecurityCenter object

// REMOTE ACCESS PARAMETERS

// Bastion Host (Remote Access)
// Example (JSON)
// -----------------------------
// "parRemoteAccess": {
//   "value": {
//     "enable": true,
//     "enableJumpBoxes": true,
//     "bastion": {
//       "sku": "Standard",
//       "subnetAddressPrefix": "10.0.100.160/27",
//       "publicIPAddressAvailabilityZones": [],
//       "linux": {
//         "vmAdminUsername": "azureuser",
//         "enableVmPasswordAuthentication": true,
//         "vmAuthenticationType": "password",
//         "vmAdminPasswordOrKey": "Rem0te@2020246",
//         "vmSize": "Standard_B2s",
//         "vmOsDiskCreateOption": "FromImage",
//         "vmOsDiskType": "Standard_LRS",
//         "vmImagePublisher": "Canonical",
//         "vmImageOffer": "UbuntuServer",
//         "vmImageSku": "18.04-LTS",
//         "vmImageVersion": "latest",
//         "networkInterfacePrivateIPAddressAllocationMethod": "Dynamic"
//       },
//       "windows": {
//         "vmAdminUsername": "azureuser",
//         "VmAdminPassword": "Rem0te@2020246",
//         "vmSize": "Standard_DS1_v2",
//         "vmOsDiskCreateOption": "FromImage",
//         "VmStorageAccountType": "StandardSSD_LRS",
//         "vmImagePublisher": "MicrosoftWindowsServer",
//         "vmImageOffer": "WindowsServer",
//         "vmImageSku": "2019-datacenter",
//         "vmImageVersion": "latest",
//         "networkInterfacePrivateIPAddressAllocationMethod": "Dynamic"
//       }
//     }
//   }
// }
@description('When set to "true", provisions Azure Bastion Host. It defaults to "false".')
param parRemoteAccess object

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

// WORKLOAD PARAMETERS

@description('The subscription ID for the Hub Network and resources. It defaults to the deployment subscription.')
param parWorkload object

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../azresources/Modules/Global/telemetry.json'))
module telemetryCustomerUsageAttribution '../../azresources/Modules/Global/partnerUsageAttribution/customer-usage-attribution-subscription.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.enclaves.sccahubspokeaks}'
  scope: subscription(parHub.subscriptionId)
}

// Module - TAGS
// -----------------------------

var referential = {
  region: parLocation
  deploymentDate: dateUtcNow
}

@description('Resource group tags')
module modTags '../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
  name: 'deploy-hubspoke-tags--${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parHub.subscriptionId)
  params: {
    tags: union(parTags, referential)
  }
}

// Module - Hub/ 1 Spoke Design - SCCA Compliant
// ----------------------------------------------
//
// ----------------------------------------------
module modHubSpoke '../../platforms/lz-platform-scca-hub-1spoke/deploy.bicep' = {
  name: 'deploy-HubSpoke-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parHub.subscriptionId)
  params: {
    // Required Parameters
    parRequired: parRequired
    parLocation: parLocation
    parTags: modTags.outputs.tags
    
    // Artifact Key Vault Parameters
    parNetworkArtifacts: parNetworkArtifacts.artifactsKeyVault.keyVaultPolicies

    // Enable DDOS Protection Plan
    parDdosStandard: parDdosStandard

    // Hub Network Parameters
    parHub: parHub  
      
    // Operations Network Parameters
    parOperationsSpoke: parOperationsSpoke

    // Logging/Sentinel
    parLogging: parLogging    

    // Enable Azure FireWall
    parAzureFirewall: parAzureFirewall

    //
    parSecurityCenter: parSecurityCenter

    //
    parRemoteAccess: parRemoteAccess
    
  }
}

// Module - AKS Workload
// ----------------------------------------------
//
// ----------------------------------------------
module modAKSWorkload '../../workloads/wl-aks-spoke/deploy.bicep' = {
  name: 'deploy-HubSpoke-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parHub.subscriptionId)
  params: {
    // Required Parameters
    parRequired: parRequired
    parLocation: parLocation
    parContainerRegistry: parContainerRegistry
    parFirewallPrivateIPAddress: modHubSpoke.outputs.firewallPrivateIPAddress
    parHubFirewallPolicyName: modHubSpoke.outputs.firewallPolicyName
    parHubResourceGroupName: modHubSpoke.outputs.hub.resourceGroupName
    parHubSubscriptionId: modHubSpoke.outputs.hub.subscriptionId
    parHubVirtualNetworkName: modHubSpoke.outputs.hub.virtualNetworkName
    parHubVirtualNetworkResourceId: modHubSpoke.outputs.hub.virtualNetworkResourceId
    parKubernetesCluster: parKubernetesCluster
    parLogAnalyticsWorkspaceName: modHubSpoke.outputs.logAnalyticsWorkspaceName
    parLogAnalyticsWorkspaceResourceId: modHubSpoke.outputs.logAnalyticsWorkspaceResourceId
    parStorageAccountAccess: parStorageAccountAccess
    parTags: parTags
    parWorkload: parWorkload
  }    
}
