# Overlays:   NoOps Accelerator - Remote Access - Bastion

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

This overlay module adds a linux and windows virtual machines to the Hub resource group to serve as a jumpbox into the network using Azure Bastion Host as the remote desktop solution without exposing the virtual machine via a Public IP address.

## Deploy Azure Bastion Host

The docs on Azure Bastion: <https://docs.microsoft.com/en-us/azure/bastion/bastion-overview>

Some particulars about Bastion:

* Azure Bastion Host requires a subnet of /27 or larger
* The subnet must be titled AzureBastionSubnet
* Azure Bastion Hosts require a public IP address

## Deploy Virtual Machine

This overlay module also deploys two virtual machines into a new subnet in the existing Hub virtual network to serve as jumpboxes.

The docs on Virtual Machines: <https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?tabs=json>

## Pre-requisites

* A Platform LZ deployment (a deployment of Hub/Spoke)

The output from that deployment described below:

Deployment Output Name | Description
-----------------------| -----------
parHubResourceGroupName | The resource group that contains the Hub Virtual Network and deploy the virtual machines into
parHubVirtualNetworkName | The resource to deploy a subnet configured for Bastion Host
parHubSubnetResourceId | The resource ID of the subnet in the Hub Virtual Network for hosting virtual machines
parHubNetworkSecurityGroupResourceId | The resource ID of the Network Security Group in the Hub Virtual Network that hosts rules for Hub Subnet traffic

## Deploy the Service

Once you have the Mission LZ output values, you can pass those in as parameters to this deployment.

For example, deploying using the `az deployment group create` command in the Azure CLI:

### Azure CLI

```bash
# For Azure global regions
az deployment group create \
   --template-file overlays/management-groups/anoa.lz.mgmt.groups.bicep \
   --parameters @overlays/management-groups/anoa.lz.mgmt.groups.parameters.example.json \
   --subscription xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx \
   --resource-group anoa-eastus-platforms-hub-rg \
   --location 'eastus'
```

OR

```bash
# For Azure IL regions
az deployment group create \
  --template-file overlays/management-groups/anoa.lz.mgmt.groups.bicep \
  --parameters @overlays/management-groups/anoa.lz.mgmt.groups.parameters.example.json \
  --subscription xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx \
  --resource-group anoa-usgovvirginia-platforms-hub-rg \
  --location 'usgovvirginia'
```

### PowerShell

```powershell
# For Azure global regions
New-AzGroupDeployment `
  -ManagementGroupId xxxxxxx-xxxx-xxxxxx-xxxxx-xxxx
  -TemplateFile overlays/management-groups/anoa.lz.mgmt.groups.bicepp `
  -TemplateParameterFile overlays/management-groups/anoa.lz.mgmt.groups.parameters.example.json `
  -Subscription xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx `
  -ResourceGroup anoa-eastus-platforms-hub-rg `
  -Location 'eastus'
```

OR

```powershell
# For Azure IL regions
New-AzGroupDeployment `
  -ManagementGroupId xxxxxxx-xxxx-xxxxxx-xxxxx-xxxx
  -TemplateFile overlays/management-groups/anoa.lz.mgmt.groups.bicepp `
  -TemplateParameterFile overlays/management-groups/anoa.lz.mgmt.groups.parameters.example.json `
  -Subscription xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx `
  -ResourceGroup anoa-usgovvirginia-platforms-hub-rg `
  -Location  'usgovvirginia'
```

## Air-Gapped Clouds

For air-gapped clouds it may be convenient to transfer and deploy the compiled ARM template instead of the Bicep template if the Bicep CLI tools are not available or if it is desirable to transfer only one file into the air gap.

## Cleanup

The Bicep/ARM deployment of NoOps Accelerator - Remote Access - Bastion deployment can be deleted with these steps:

## Example Output in Azure

![Example Deployment Output](images/operationsNetworkExampleDeploymentOutput.png "Example Deployment Output in Azure global regions")
