# Overlays:   NoOps Accelerator - Auotmation Account

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

This add-on module adds a linux and windows virtual machines to the Hub resource group to serve as a jumpbox into the network using Azure Bastion Host as the remote desktop solution without exposing the virtual machine via a Public IP address.

## Deploy Azure Bastion Host

The docs on Azure Bastion: <https://docs.microsoft.com/en-us/azure/bastion/bastion-overview>

Some particulars about Bastion:

* Azure Bastion Host requires a subnet of /27 or larger
* The subnet must be titled AzureBastionSubnet
* Azure Bastion Hosts require a public IP address

## Deploy Virtual Machine

This add-on module also deploys two virtual machines into a new subnet in the existing Hub virtual network to serve as jumpboxes.

The docs on Virtual Machines: <https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?tabs=json>

## Pre-requisites

* A Mission LZ deployment (a deployment of anoa.mlz.bicep)

See below for information on how to use the appropriate deployment parameters for use with this overlay:

Deployment Output Name | Description
-----------------------| -----------
parHubResourceGroupName | The resource group that contains the Hub Virtual Network and deploy the virtual machines into
parHubVirtualNetworkName | The resource to deploy a subnet configured for Bastion Host
parHubSubnetResourceId | The resource ID of the subnet in the Hub Virtual Network for hosting virtual machines
parHubNetworkSecurityGroupResourceId | The resource ID of the Network Security Group in the Hub Virtual Network that hosts rules for Hub Subnet traffic

## Deploy the Service

Once you have the Mission LZ output values, you can pass those in as parameters to this deployment.

For example, deploying using the `az deployment group create` command in the Azure CLI:

```bash

```
