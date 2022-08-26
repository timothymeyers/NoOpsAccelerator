/* Copyright (c) Microsoft Corporation. Licensed under the MIT license. */
/*
SUMMARY: Module Example to deploy the Full Hub/ 3 Spoke Enclave with AKS Workload
DESCRIPTION: The following components will be options in this deployment
            * Managment Groups
            * Policy
            * Roles
            * Hub Virtual Network (VNet)              
              * Operations Artifacts (Optional)
              * Bastion Host (Optional)
              * DDos Standard Plan (Optional)
              * Microsoft Defender for Cloud (Optional)              
            * Spokes
              * Identity (Tier 0)
              * Operations (Tier 1)
              * Shared Services (Tier 2)
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
  PARAMETERS
  Here are all the parameters a user can override.
  These are the required parameters that Network does not provide a default for:    
    - parDeployEnvironment
*/

// **Scope**
targetScope = 'tenant'

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

// SUBSCRIPTIONS PARAMETERS

@description('The subscription ID for the Hub Network and resources. It defaults to the deployment subscription.')
param parHubSubscriptionId string

@description('The subscription ID for the Identity Network and resources. It defaults to the deployment subscription.')
param parIdentitySubscriptionId string

@description('The subscription ID for the Operations Network and resources. It defaults to the deployment subscription.')
param parOperationsSubscriptionId string

@description('The subscription ID for the Shared Services Network and resources. It defaults to the deployment subscription.')
param parSharedServicesSubscriptionId string

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

// NETWORK ADDRESS SPACE PARAMETERS

@description('The CIDR Virtual Network Address Prefix for the Hub Virtual Network.')
param parHubVirtualNetworkAddressPrefix string = '10.0.100.0/24'

@description('The CIDR Subnet Address Prefix for the default Hub subnet. It must be in the Hub Virtual Network space.')
param parHubSubnetAddressPrefix string = '10.0.100.128/27'

@description('The CIDR Subnet Address Prefix for the Azure Firewall Subnet. It must be in the Hub Virtual Network space. It must be /26.')
param parFirewallClientSubnetAddressPrefix string = '10.0.100.0/26'

@description('The CIDR Subnet Address Prefix for the Azure Firewall Management Subnet. It must be in the Hub Virtual Network space. It must be /26.')
param parFirewallManagementSubnetAddressPrefix string = '10.0.100.64/26'

@description('The CIDR Virtual Network Address Prefix for the Identity Virtual Network.')
param parIdentityVirtualNetworkAddressPrefix string = '10.0.110.0/26'

@description('The CIDR Subnet Address Prefix for the default Identity subnet. It must be in the Identity Virtual Network space.')
param parIdentitySubnetAddressPrefix string = '10.0.110.0/27'

@description('The CIDR Virtual Network Address Prefix for the Operations Virtual Network.')
param parOperationsVirtualNetworkAddressPrefix string = '10.0.115.0/26'

@description('The CIDR Subnet Address Prefix for the default Operations subnet. It must be in the Operations Virtual Network space.')
param parOperationsSubnetAddressPrefix string = '10.0.115.0/27'

@description('The CIDR Virtual Network Address Prefix for the Shared Services Virtual Network.')
param parSharedServicesVirtualNetworkAddressPrefix string = '10.0.120.0/26'

@description('The CIDR Subnet Address Prefix for the default Shared Services subnet. It must be in the Shared Services Virtual Network space.')
param parSharedServicesSubnetAddressPrefix string = '10.0.120.0/27'

// FIREWALL PARAMETERS

@description('Switch which allows Azure Firewall deployment to be disabled. Default: true')
param parAzureFirewallEnabled bool = true

@description('Azure Firewall Tier associated with the Firewall to deploy. Default: Standard ')
@allowed([
  'Standard'
  'Premium'
])
param parFirewallSkuTier string

@description('Supernet CIDR address for the entire network of vnets, this address allows for communication between spokes. Recommended to use a Supernet calculator if modifying vnet addresses')
param parFirewallSupernetIPAddress string = '10.0.96.0/19'

@allowed([
  'Alert'
  'Deny'
  'Off'
])
param parFirewallThreatIntelMode string

@allowed([
  'Alert'
  'Deny'
  'Off'
])
@description('[Alert/Deny/Off] The Azure Firewall Intrusion Detection mode. Valid values are "Alert", "Deny", or "Off". The default value is "Alert".')
param parFirewallIntrusionDetectionMode string = 'Alert'

@description('An array of Firewall Diagnostic Logs categories to collect. See "https://docs.microsoft.com/en-us/azure/firewall/firewall-diagnostics#enable-diagnostic-logging-through-the-azure-portal" for valid values.')
param parFirewallDiagnosticsLogs array = [
  'AzureFirewallApplicationRule'
  'AzureFirewallNetworkRule'
  'AzureFirewallDnsProxy'
]

@description('An array of Firewall Diagnostic Metrics categories to collect. See "https://docs.microsoft.com/en-us/azure/firewall/firewall-diagnostics#enable-diagnostic-logging-through-the-azure-portal" for valid values.')
param parFirewallDiagnosticsMetrics array = [
  'AllMetrics'
]

@description('Subnet name for the Firewall Default is "AzureFirewallSubnet"')
param parFirewallClientSubnetName string = 'AzureFirewallSubnet'

@description('An array of Service Endpoints to enable for the Azure Firewall Client Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings.')
param parFirewallClientSubnetServiceEndpoints array = []

@description('An array of Azure Firewall Public IP Address Availability Zones. It defaults to empty, or "No-Zone", because Availability Zones are not available in every cloud. See https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku for valid settings.')
param parFirewallClientPublicIPAddressAvailabilityZones array = []

@description('Subnet name for the Firewall Default is "AzureFirewallManagementSubnet"')
param parFirewallManagementSubnetName string = 'AzureFirewallManagementSubnet'

@description('An array of Service Endpoints to enable for the Azure Firewall Management Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings.')
param parFirewallManagementSubnetServiceEndpoints array = []

@description('An array of Azure Firewall Public IP Address Availability Zones. It defaults to empty, or "No-Zone", because Availability Zones are not available in every cloud. See https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku for valid settings.')
param parFirewallManagementPublicIPAddressAvailabilityZones array = []

@description('An array of Public IP Address Diagnostic Logs for the Azure Firewall. See https://docs.microsoft.com/en-us/azure/ddos-protection/diagnostic-logging?tabs=DDoSProtectionNotifications#configure-ddos-diagnostic-logs for valid settings.')
param parPublicIPAddressDiagnosticsLogs array = [
  {
    category: 'DDoSProtectionNotifications'
    enabled: true
  }
  {
    category: 'DDoSMitigationFlowLogs'
    enabled: true
  }
  {
    category: 'DDoSMitigationReports'
    enabled: true
  }
]

@description('An array of Public IP Address Diagnostic Metrics for the Azure Firewall. See https://docs.microsoft.com/en-us/azure/ddos-protection/diagnostic-logging?tabs=DDoSProtectionNotifications for valid settings.')
param parPublicIPAddressDiagnosticsMetrics array = [
  {
    category: 'AllMetrics'
    enabled: true
  }
]

// HUB NETWORK PARAMETERS

@description('An array of Network Diagnostic Logs to enable for the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs for valid settings.')
param parHubVirtualNetworkDiagnosticsLogs array = []

@description('An array of Network Diagnostic Metrics to enable for the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings.')
param parHubVirtualNetworkDiagnosticsMetrics array = []

@description('An array of Network Security Group Rules to apply to the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat for valid settings.')
param parHubNetworkSecurityGroupRules array = []

@description('An array of Network Security Group diagnostic logs to apply to the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories for valid settings.')
param parHubNetworkSecurityGroupDiagnosticsLogs array = [
  {
    category: 'NetworkSecurityGroupEvent'
    enabled: true
  }
  {
    category: 'NetworkSecurityGroupRuleCounter'
    enabled: true
  }
]

@description('An array of Service Endpoints to enable for the Hub subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings.')
param parHubSubnetServiceEndpoints array = [
  {
    service: 'Microsoft.Storage'
  }
]

// IDENTITY PARAMETERS

@description('An array of Network Diagnostic Logs to enable for the Identity Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs for valid settings.')
param parIdentityVirtualNetworkDiagnosticsLogs array = []

@description('An array of Network Diagnostic Metrics to enable for the Identity Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings.')
param parIdentityVirtualNetworkDiagnosticsMetrics array = []

@description('An array of Network Security Group Rules to apply to the Identity Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat for valid settings.')
param parIdentityNetworkSecurityGroupRules array = [
  {
    name: 'Allow-Traffic-From-Spokes'
    properties: {
      access: 'Allow'
      description: 'Allow traffic from spokes'
      destinationAddressPrefix: parIdentityVirtualNetworkAddressPrefix
      destinationPortRanges: [
        '22'
        '80'
        '443'
        '3389'
      ]
      direction: 'Inbound'
      priority: 200
      protocol: '*'
      sourceAddressPrefixes: parIdentitySourceAddressPrefixes
      sourcePortRange: '*'
    }
    type: 'string'
  }
]

@description('An array of')
param parIdentitySourceAddressPrefixes array = [
  parOperationsVirtualNetworkAddressPrefix
  parSharedServicesVirtualNetworkAddressPrefix
]

@description('An array of Network Security Group diagnostic logs to apply to the Identity Virtual Network. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories for valid settings.')
param parIdentityNetworkSecurityGroupDiagnosticsLogs array = [
  'NetworkSecurityGroupEvent'
  'NetworkSecurityGroupRuleCounter'
]

@description('An array of Service Endpoints to enable for the Identity subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings.')
param parIdentitySubnetServiceEndpoints array = [
  'Microsoft.Storage'
]

// OPERATIONS NETWORK PARAMETERS

@description('An array of Network Diagnostic Logs to enable for the Operations Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs for valid settings.')
param parOperationsVirtualNetworkDiagnosticsLogs array = []

@description('An array of Network Diagnostic Metrics to enable for the Operations Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings.')
param parOperationsVirtualNetworkDiagnosticsMetrics array = []

@description('An array of Network Security Group rules to apply to the Operations Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat for valid settings.')
param parOperationsNetworkSecurityGroupRules array = [
  {
    name: 'Allow-Traffic-From-Spokes'
    properties: {
      access: 'Allow'
      description: 'Allow traffic from spokes'
      destinationAddressPrefix: parOperationsVirtualNetworkAddressPrefix
      destinationPortRanges: [
        '22'
        '80'
        '443'
        '3389'
      ]
      direction: 'Inbound'
      priority: 200
      protocol: '*'
      sourceAddressPrefixes: [
        parIdentityVirtualNetworkAddressPrefix
        parSharedServicesVirtualNetworkAddressPrefix
      ]
      sourcePortRange: '*'
    }
    type: 'string'
  }
]

@description('An array of Network Security Group diagnostic logs to apply to the Operations Virtual Network. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories for valid settings.')
param parOperationsNetworkSecurityGroupDiagnosticsLogs array = [
  {
    category: 'NetworkSecurityGroupEvent'
    enabled: true
  }
  {
    category: 'NetworkSecurityGroupRuleCounter'
    enabled: true
  }
]

@description('An array of Service Endpoints to enable for the Operations subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings.')
param parOperationsSubnetServiceEndpoints array = [
  {
    service: 'Microsoft.Storage'
  }
]

// SHARED SERVICES NETWORK PARAMETERS

@description('An array of Network Diagnostic Logs to enable for the SharedServices Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs for valid settings.')
param parSharedServicesVirtualNetworkDiagnosticsLogs array = []

@description('An array of Network Diagnostic Metrics to enable for the SharedServices Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings.')
param parSharedServicesVirtualNetworkDiagnosticsMetrics array = []

@description('An array of Network Security Group rules to apply to the SharedServices Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat for valid settings.')
param parSharedServicesNetworkSecurityGroupRules array = [
  {
    name: 'Allow-Traffic-From-Spokes'
    properties: {
      access: 'Allow'
      description: 'Allow traffic from spokes'
      destinationAddressPrefix: parSharedServicesVirtualNetworkAddressPrefix
      destinationPortRanges: [
        '22'
        '80'
        '443'
        '3389'
      ]
      direction: 'Inbound'
      priority: 200
      protocol: '*'
      sourceAddressPrefixes: [
        parOperationsVirtualNetworkAddressPrefix
        parIdentityVirtualNetworkAddressPrefix
      ]
      sourcePortRange: '*'
    }
    type: 'string'
  }
]

@description('An array of Network Security Group diagnostic logs to apply to the SharedServices Virtual Network. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories for valid settings.')
param parSharedServicesNetworkSecurityGroupDiagnosticsLogs array = [
  {
    category: 'NetworkSecurityGroupEvent'
    enabled: true
  }
  {
    category: 'NetworkSecurityGroupRuleCounter'
    enabled: true
  }
]

@description('An array of Service Endpoints to enable for the SharedServices subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings.')
param parSharedServicesSubnetServiceEndpoints array = [
  {
    service: 'Microsoft.Storage'
  }
]

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

// MANAGEMENT GROUPS PARAMETERS

// Management Groups
// Example (JSON)
// -----------------------------
@description('These are the landing zone management groups.')
param parManagementGroups object

// POLICY PARAMETERS

// Policy
// Example (JSON)
// -----------------------------
// "parPolicy": {
//   "value": {
//       "bulitInPolicy": {
//           "policies": [
//               {
//                   "enabled": false,
//                   "name": "Location",
//                   "policyAssignmentManagementGroupId": "anoa",
//                   "enforcementMode": "Default",
//                   "allowedLocations": [
//                       "EastUS"
//                   ]
//               },
//               {
//                   "enabled": false,
//                   "name": "NIST SP 800-53 R5",
//                   "policyAssignmentManagementGroupId": "anoa",
//                   "enforcementMode": "Default",
//                   "requiredRetentionDays": "30"
//               },
//               {
//                   "enabled": false,
//                   "name": "FedRAMP Moderate",
//                   "policyAssignmentManagementGroupId": "anoa",
//                   "enforcementMode": "Default",
//                   "requiredRetentionDays": "30"
//               }
//           ]
//       },
//       "customPolicy": {
//           "value": {
//               "policies": [
//                   {
//                       "enabled": true,
//                       "name": "Custom - Compute Governance Initiative",
//                       "policyDefinitionManagementGroupId": "anoa",
//                       "policyAssignmentManagementGroupId": "anoa",
//                       "policySource": "ANOA",
//                       "policyCategory": "Compute"
//                   },
//                   {
//                       "enabled": true,
//                       "name": "Custom - Data Protection Governance Initiative",
//                       "policyDefinitionManagementGroupId": "anoa",
//                       "policySource": "ANOA",
//                       "policyCategory": "Data Protection"
//                   },
//                   {
//                       "enabled": true,
//                       "name": "Custom - Identity Governance Initiative",
//                       "policyDefinitionManagementGroupId": "anoa",
//                       "policySource": "ANOA",
//                       "policyCategory": "IAM"
//                   },
//                   {
//                       "enabled": true,
//                       "name": "Custom - Key Vault Governance Initiative",
//                       "policyDefinitionManagementGroupId": "anoa",
//                       "policySource": "ANOA",
//                       "policyCategory": "Key Vault"
//                   },
//                   {
//                       "enabled": true,
//                       "name": "Custom - Network Governance Initiative",
//                       "policyDefinitionManagementGroupId": "anoa",
//                       "policySource": "ANOA",
//                       "policyCategory": "Network"
//                   },
//                   {
//                       "enabled": true,
//                       "name": "Custom - Security Governance Initiative",
//                       "policyDefinitionManagementGroupId": "anoa",
//                       "policySource": "ANOA",
//                       "policyCategory": "Security"
//                   },
//                   {
//                       "enabled": true,
//                       "name": "Custom - SQL Governance Initiative",
//                       "policyDefinitionManagementGroupId": "anoa",
//                       "policySource": "ANOA",
//                       "policyCategory": "SQL"
//                   },
//                   {
//                       "enabled": true,
//                       "name": "Custom - Storage Governance Initiative",
//                       "policyDefinitionManagementGroupId": "anoa",
//                       "policySource": "ANOA",
//                       "policyCategory": "Storage"
//                   },
//                   {
//                       "enabled": true,
//                       "name": "Custom - Tagging Governance Initiative",
//                       "policyDefinitionManagementGroupId": "anoa",
//                       "policySource": "ANOA",
//                       "policyCategory": "Tagging"
//                   }
//               ]
//           }
//       }
//   }
// }        
@description('These are BulitIn/Custom Policies for the landing zone management groups and resources.')
param parPolicy object

// ROLES PARAMETERS

// Bastion Host (Remote Access)
// Example (JSON)
// -----------------------------
// {
//   "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
//   "contentVersion": "1.0.0.0",
//   "parameters": { 
//     "parRoleDefinitionInfo": {
//       "value": {
//         "definitions": [
//           {
//             "roleID": "6f0b9662-992a-523e-a58d-6a91804f2f29",
//             "roleName": "Custom - VM Operator",
//             "roleDescription": "Start and Stop Virtual Machines and reader",
//             "actions": [
//               "Microsoft.Compute/virtualMachines/read",
//               "Microsoft.Compute/virtualMachines/start/action",
//               "Microsoft.Compute/virtualMachines/restart/action",
//               "Microsoft.Resources/subscriptions/resourceGroups/read",
//               "Microsoft.Compute/virtualMachines/deallocate/action",
//               "Microsoft.Compute/virtualMachineScaleSets/deallocate/action",
//               "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/deallocate/action",
//               "Microsoft.Compute/virtualMachines/powerOff/action"
//             ],
//             "notActions": [],
//             "dataActions": [],
//             "notDataActions": [],
//             "scopeType": "ManagementGroup",
//             "scopeName": "anoalz"
//           },
//           {
//             "roleID": "72dd118f-5398-5835-8432-ced9ab12a3de",
//             "roleName": "Custom - Network Operations (NetOps)",
//             "roleDescription": "Platform-wide global connectivity management: virtual networks, UDRs, NSGs, NVAs, VPN, Azure ExpressRoute, and others.",
//             "actions": [
//               "Microsoft.Network/virtualNetworks/read",
//               "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
//               "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write",
//               "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete",
//               "Microsoft.Network/virtualNetworks/peer/action",
//               "Microsoft.Resources/deployments/operationStatuses/read",
//               "Microsoft.Resources/deployments/write",
//               "Microsoft.Resources/deployments/read"
//             ],
//             "notActions": [],
//             "dataActions": [],
//             "notDataActions": [],
//             "scopeType": "ManagementGroup",
//             "scopeName": "anoalz"
//           },
//           {
//             "roleID": "72dd118f-5398-5835-8432-ced9ab12a3de",
//             "roleName": "Custom - Security Operations (SecOps)",
//             "roleDescription": "Security Administrator role with a horizontal view across the entire Azure estate and the Azure Key Vault purge policy.",
//             "actions": [
//               "*/read",
//               "*/register/action",
//               "Microsoft.KeyVault/locations/deletedVaults/purge/action",
//               "Microsoft.PolicyInsights/*",
//               "Microsoft.Authorization/policyAssignments/*",
//               "Microsoft.Authorization/policyDefinitions/*",
//               "Microsoft.Authorization/policyExemptions/*",
//               "Microsoft.Authorization/policySetDefinitions/*",
//               "Microsoft.Insights/alertRules/*",
//               "Microsoft.Resources/deployments/*",
//               "Microsoft.Security/*",
//               "Microsoft.Support/*"
//             ],
//             "notActions": [],
//             "dataActions": [],
//             "notDataActions": [],
//             "scopeType": "ManagementGroup",
//             "scopeName": "anoalz"
//           },
//           {
//             "roleID": "72dd118f-5398-5835-8432-ced9ab12a3de",
//             "roleName": "Custom - Landing Zone Application Owner",
//             "roleDescription": "Contributor role granted for application/operations team at resource group level.",
//             "actions": [
//               "*"
//             ],
//             "notActions": [
//               "Microsoft.Authorization/*/write",
//               "Microsoft.Network/publicIPAddresses/write",
//               "Microsoft.Network/virtualNetworks/write",
//               "Microsoft.KeyVault/locations/deletedVaults/purge/action"
//             ],
//             "dataActions": [],
//             "notDataActions": [],
//             "scopeType": "ManagementGroup",
//             "scopeName": "anoalz"
//           },
//           {
//             "roleID": "72dd118f-5398-5835-8432-ced9ab12a3de",
//             "roleName": "Custom - Landing Zone Subscription Owner",
//             "roleDescription": "Delegated role for subscription owner generated from subscription Owner role.",
//             "actions": [
//               "*"
//             ],
//             "notActions": [
//               "Microsoft.Authorization/*/write",
//               "Microsoft.Network/vpnGateways/*",
//               "Microsoft.Network/expressRouteCircuits/*",
//               "Microsoft.Network/routeTables/write",
//               "Microsoft.Network/vpnSites/*"
//             ],
//             "dataActions": [],
//             "notDataActions": [],
//             "scopeType": "ManagementGroup",
//             "scopeName": "anoalz"
//           },
//           {
//             "roleID": "bb465e79-5df0-597b-a848-85006554c065",
//             "roleName": "Custom - Storage Operator",
//             "roleDescription": "Custom Storage Operator role for deploying virtual machines.",
//             "actions": [
//               "Microsoft.Authorization/*/read",
//               "Microsoft.Insights/alertRules/*",
//               "Microsoft.Insights/diagnosticSettings/*",
//               "Microsoft.Network/virtualNetworks/subnets/joinViaServiceEndpoint/action",
//               "Microsoft.ResourceHealth/availabilityStatuses/read",
//               "Microsoft.Resources/deployments/*",
//               "Microsoft.Resources/subscriptions/resourceGroups/read",
//               "Microsoft.Storage/storageAccounts/*",
//               "Microsoft.Support/*",
//               "Microsoft.Storage/storageAccounts/listkeys/action"
//             ],
//             "notActions": [],
//             "scopeType": "ManagementGroup",
//             "scopeName": "anoalz"
//           }
//         ]
//       }
//     }
//   }
// }
@description('These are the custom roles for landing zone management groups and resources..')
param parRoleDefinitionInfo object


// Module - TAGS
// -----------------------------

var referential = {
  region: parLocation
  deploymentDate: dateUtcNow
}

@description('Resource group tags')
module modTags '../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
  name: 'deploy-hubspoke-tags--${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parHubSubscriptionId)
  params: {
    tags: union(parTags, referential)
  }
}

// Module - Customer Usage Attribution - Telemetry
// -----------------------------------------------

// Module - Management Groups
// -----------------------------
// The Enclave Management Groups module deploys a management group hierarchy in a tenant under the Tenant Root Group. 
// This is accomplished through a tenant-scoped Azure Resource Manager (ARM) deployment. 
// NOTE: For more information on Management Groups - go to the overlays/management-group/readme.md
// -------------------------------------------------------------------------------------------------------------------
module modManagementGroups '../../overlays/management-groups/deploy.bicep' = {
  name: 'deploy-MG-${parLocation}-${parDeploymentNameSuffix}'
  scope: managementGroup(parManagementGroups.tenantId)
  params: {
    parManagementGroups: parManagementGroups.groups
    parRequireAuthorizationForGroupCreation: parManagementGroups.requireAuthorizationForGroupCreation
    parRootMg: parManagementGroups.rootMg
    parSubscriptions: parManagementGroups.subscriptions
    parTenantId: parManagementGroups.tenantId
  }
}

// Module - Custom RBAC Role Definitions 
// --------------------------------------
// The Enclave Roles overlay module deploys a role definitions in a specific `Management Group`.  
// This is accomplished through a managmenent-group-scoped Azure Resource Manager (ARM) deployment.
// --------------------------------------
module modRoles '../../overlays/roles/deploy.bicep' = {
  name: 'deploy-Roles-${parLocation}-${parDeploymentNameSuffix}'
  scope: managementGroup(parManagementGroups.tenantId)
  params:  {
    parLocation: parLocation
    parDefaultManagementGroupIdForRoleDefinitions: ''
    parRoleDefinitionInfo: parRoleDefinitionInfo
  }
}

// Bulit-In/Custom Policy Definitions and Initiatives Into Management Group Hierarchy
// Module - Policy Definitions and Initiatives
// -----------------------------------------------------------------------------------
//
//
//
// -----------------------------------------------------------------------------------
module modPolicy '../../overlays/policy/hub-spoke/deploy.bicep' = {
  name: 'deploy-Policy-${parLocation}-${parDeploymentNameSuffix}'
  scope: managementGroup(parManagementGroups.tenantId)
  params: {
    parLocation: parLocation
    parPolicy: parPolicy
  }
}

// Module - Hub/ 3 Spoke Design - SCCA Compliant
// ----------------------------------------------
//
// ----------------------------------------------
module modHubSpoke '../../platforms/lz-platform-scca-hub-3spoke/deploy.bicep' = {
  name: 'deploy-HubSpoke-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parHubSubscriptionId)
  params: {
    // Required Parameters
    parRequired: parRequired
    parLocation: parLocation
    parTags: modTags.outputs.tags

    // Subscriptions
    parHubSubscriptionId: parHubSubscriptionId
    parIdentitySubscriptionId: parIdentitySubscriptionId
    parOperationsSubscriptionId: parOperationsSubscriptionId
    parSharedServicesSubscriptionId: parSharedServicesSubscriptionId

    // Artifact Key Vault Parameters
    parNetworkArtifacts: parNetworkArtifacts.artifactsKeyVault.keyVaultPolicies

    // Enable DDOS Protection Plan
    parDdosStandard: parDdosStandard

    // Hub Network Parameters
    parHubVirtualNetworkAddressPrefix: parHubVirtualNetworkAddressPrefix
    parHubSubnetAddressPrefix: parHubSubnetAddressPrefix
    parHubNetworkSecurityGroupDiagnosticsLogs: parHubNetworkSecurityGroupDiagnosticsLogs
    parHubNetworkSecurityGroupRules: parHubNetworkSecurityGroupRules
    parHubSubnetServiceEndpoints: parHubSubnetServiceEndpoints
    parHubVirtualNetworkDiagnosticsLogs: parHubVirtualNetworkDiagnosticsLogs
    parHubVirtualNetworkDiagnosticsMetrics: parHubVirtualNetworkDiagnosticsMetrics
    parPublicIPAddressDiagnosticsLogs: parPublicIPAddressDiagnosticsLogs
    parPublicIPAddressDiagnosticsMetrics: parPublicIPAddressDiagnosticsMetrics

    // Identity Network Parameters
    parIdentityNetworkSecurityGroupDiagnosticsLogs: parIdentityNetworkSecurityGroupDiagnosticsLogs
    parIdentitySubnetAddressPrefix: parIdentitySubnetAddressPrefix
    parIdentityNetworkSecurityGroupRules: parIdentityNetworkSecurityGroupRules
    parIdentitySubnetServiceEndpoints: parIdentitySubnetServiceEndpoints
    parIdentityVirtualNetworkAddressPrefix: parIdentityVirtualNetworkAddressPrefix
    parIdentityVirtualNetworkDiagnosticsLogs: parIdentityVirtualNetworkDiagnosticsLogs
    parIdentityVirtualNetworkDiagnosticsMetrics: parIdentityVirtualNetworkDiagnosticsMetrics

    // Operations Network Parameters
    parOperationsNetworkSecurityGroupDiagnosticsLogs: parOperationsNetworkSecurityGroupDiagnosticsLogs
    parOperationsSubnetAddressPrefix: parOperationsSubnetAddressPrefix
    parOperationsNetworkSecurityGroupRules: parOperationsNetworkSecurityGroupRules
    parOperationsSubnetServiceEndpoints: parOperationsSubnetServiceEndpoints
    parOperationsVirtualNetworkAddressPrefix: parOperationsVirtualNetworkAddressPrefix
    parOperationsVirtualNetworkDiagnosticsLogs: parOperationsVirtualNetworkDiagnosticsLogs
    parOperationsVirtualNetworkDiagnosticsMetrics: parOperationsVirtualNetworkDiagnosticsMetrics

    // Shared Services Network Parameters
    parSharedServicesNetworkSecurityGroupDiagnosticsLogs: parSharedServicesNetworkSecurityGroupDiagnosticsLogs
    parSharedServicesSubnetAddressPrefix: parSharedServicesSubnetAddressPrefix
    parSharedServicesNetworkSecurityGroupRules: parSharedServicesNetworkSecurityGroupRules
    parSharedServicesSubnetServiceEndpoints: parSharedServicesSubnetServiceEndpoints
    parSharedServicesVirtualNetworkAddressPrefix: parSharedServicesVirtualNetworkAddressPrefix
    parSharedServicesVirtualNetworkDiagnosticsLogs: parSharedServicesVirtualNetworkDiagnosticsLogs
    parSharedServicesVirtualNetworkDiagnosticsMetrics: parSharedServicesVirtualNetworkDiagnosticsMetrics

    // Logging/Sentinel
    parLogging: parLogging

    // Enable Azure FireWall
    parAzureFirewallEnabled: parAzureFirewallEnabled
    parFirewallClientSubnetAddressPrefix: parFirewallClientSubnetAddressPrefix
    parFirewallManagementSubnetAddressPrefix: parFirewallManagementSubnetAddressPrefix

    // Hub Firewall Parameters
    parFirewallSupernetIPAddress: parFirewallSupernetIPAddress
    parFirewallSkuTier: parFirewallSkuTier
    parFirewallThreatIntelMode: parFirewallThreatIntelMode
    parFirewallIntrusionDetectionMode: parFirewallIntrusionDetectionMode
    parFirewallClientPublicIPAddressAvailabilityZones: parFirewallClientPublicIPAddressAvailabilityZones
    parFirewallClientSubnetName: parFirewallClientSubnetName
    parFirewallClientSubnetServiceEndpoints: parFirewallClientSubnetServiceEndpoints
    parFirewallDiagnosticsLogs: parFirewallDiagnosticsLogs
    parFirewallDiagnosticsMetrics: parFirewallDiagnosticsMetrics
    parFirewallManagementPublicIPAddressAvailabilityZones: parFirewallManagementPublicIPAddressAvailabilityZones
    parFirewallManagementSubnetName: parFirewallManagementSubnetName
    parFirewallManagementSubnetServiceEndpoints: parFirewallManagementSubnetServiceEndpoints

    // RBAC for Storage Parameters
    parStorageAccountAccess: parStorageAccountAccess

    //
    parSecurityCenter: parSecurityCenter

    //
    parRemoteAccess: parRemoteAccess
  }
}

// Module - Front Door
