# Module:   NoOps Accelerator - Spoke Network Peering

## Authored & Tested With

* [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) version 2.38.0
* bicep cli version v0.9.1
* [bicep](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) v0.9.1 vscode extension

## Prerequisites

* For deployments in the Azure Portal you need access to the portal in the cloud you want to deploy to, such as [https://portal.azure.com](https://portal.azure.com) or [https://portal.azure.us](https://portal.azure.us).
* For deployments in BASH or a Windows shell, then a terminal instance with the AZ CLI installed is required.
* For PowerShell deployments you need a PowerShell terminal with the [Azure Az PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/what-is-azure-powershell) installed.

> NOTE: The AZ CLI will automatically install the Bicep tools when a command is run that needs them, or you can manually install them following the [instructions here.](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli)

## Overview

This module defines Spoke Network Peering based on the recommendations from the Azure Mission Landing Zone Conceptual Architecture.  

Module deploys the following resources:

* Spoke Virtual Network (VNet) Peering

## Required Parameters

The module requires the following inputs:

| Parameter                         | Type   | Default                                                                                              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Required                   | Example                                        |
 | --------------------------------- | ------ | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- | ---------------------------------------------- |
| parSpokeName                       | string | `None`                                                                           |Provide the Spoke Name | Yes                          | `operations` |
| parSpokeResourceGroupName                       | string | `None`                                                                           | Provide the Spoke Resource Group Name | Yes                          | `aona-eastus-platforms-operations-rg` |
| parSpokeVirtualNetworkName                       | string | `None`                                                                           | Provide the Spoke Virtual Network Name  | Yes                          | `aona-eastus-platforms-operations-vnet` |
| parHubVirtualNetworkName                       | string | `None`                                                                           | Provide the Hub Virtual Network Name    | Yes                          | `anoa-eastus-platforms-hub-vnet` |
| parHubVirtualNetworkResourceId                       | string | `None`                                                                           |  Provide the Hub Virtua lNetwor Resource Id   | Yes                          | `/subscriptions/xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/resourceGroups/anoa-eastus-platforms-hub-rg/providers/Microsoft.Network/virtualNetworks/anoa-eastus-platforms-hub-vnet` |

Parameters file located in the [Deployments](../../../../deployments/HubSpoke/networking/peering/spoke/) folder under hub/spoke.

## Deployment

### Manual Deployment - Azure CLI

```bash
# For Azure global regions

# Set Platform connectivity subscription ID as the the current subscription 

ConnectivitySubscriptionId="[your platform management subscription ID]"
az account set --subscription $ConnectivitySubscriptionId

az deployment group create \  
   --location EastUS
   --resource-group anoa-eastus-platforms-operations-rg \ 
   --template-file enclave/bicep/landingzone/network/peering/spoke/lz.spoke.network.peerings.bicep \
   --parameters @enclave/bicep/landingzone/network/peering/spoke/lz.spoke.network.peerings.parameters.json
```

OR

```bash

# For Azure IL regions

# Set Platform connectivity subscription ID as the the current subscription 

ConnectivitySubscriptionId="[your platform management subscription ID]"
az account set --subscription $ConnectivitySubscriptionId

az deployment group create \
   --location VirginiaUS
   --resource-group anoa-eastus-platforms-operations-rg \
   --template-file enclave/bicep/landingzone/networkpeering/spoke/lz.spoke.network.peerings.bicep \
   --parameters @enclave/bicep/landingzone/network/peering/spoke/lz.spoke.network.peerings.parameters.json
```

### Manual Deployment - PowerShell

```powershell
# For Azure global regions
# Set Platform connectivity subscription ID as the the current subscription 
$ConnectivitySubscriptionId = "[your platform management subscription ID]"

Select-AzSubscription -SubscriptionId $ConnectivitySubscriptionId
  
New-AzResourceGroupDeployment `
  -TemplateFile enclave/bicep/landingzone/network/peering/spoke/lz.spoke.network.peerings.bicep `
  -TemplateParameterFile enclave/bicep/landingzone/network/peering/spoke/lz.spoke.network.peerings.json `
  -Resource-Group 'anoa-eastus-platforms-operations-rg'
  -Location 'EastUS'
```

OR

```powershell

# For Azure IL regions
# Set Platform connectivity subscription ID as the the current subscription 
$ConnectivitySubscriptionId = "[your platform management subscription ID]"

Select-AzSubscription -SubscriptionId $ConnectivitySubscriptionId
  
New-AzResourceGroupDeployment `
  -TemplateFile enclave/bicep/landingzone/network/peering/hub/lz.spoke.network.peerings.bicep `
  -TemplateParameterFile enclave/bicep/landingzone/network/peering/spoke/lz.spoke.network.peerings.parameters.json `
  -Resource-Group 'anoa-eastus-platforms-operations-rg'
  -Location 'VirginiaUS'
```

## GitHub Actions Workflows/YAML Example

This workflows can be found in the [.github/workflows](.github/workflows) folder

## GitLab Workflows/YAML Example

```yaml

```

## Air-Gapped Clouds

For air-gapped clouds it may be convenient to transfer and deploy the compiled ARM template instead of the Bicep template if the Bicep CLI tools are not available or if it is desirable to transfer only one file into the air gap.

## Cleanup

The Bicep/ARM deployment of NoOps Accelerator Spoke Network Peering deployment can be deleted with this step:

> Note: Before deleting a peering, ensure your account has the necessary permissions. When a peering is deleted, traffic can no longer flow between two virtual networks. When deleting a virtual networking peering, the corresponding peering will also be removed.

```bash
# For Azure IL regions

# Set Platform connectivity subscription ID as the the current subscription 

ConnectivitySubscriptionId="[your platform management subscription ID]"
az account set --subscription $ConnectivitySubscriptionId

az network vnet peering delete \ 
--resource-group anoa-eastus-platforms-operations-rg \ 
--name to-anoa-eastus-platforms-hub-vnet \ 
--vnet-name aona-eastus-platforms-operations-vnet
```

## Example Output in Azure

![Example Deployment Output](images/operationsNetworkExampleDeploymentOutput.png "Example Deployment Output in Azure global regions")