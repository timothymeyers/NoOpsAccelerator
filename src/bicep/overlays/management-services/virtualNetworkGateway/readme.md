# Overlays:   NoOps Accelerator - Virtual Network Gateway

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

This overlay module adds an VPN Gateway sends encrypted traffic between an Azure virtual network and an on-premises location over the public Internet. This Virtual Network Gateway is meant to be in the Hub Network.

## Deploy Virtual Network Gateway

The docs on Virtual Network Gateway: <https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways>

Some particulars about Virtual Network Gateway:

* A virtual network gateway is composed of two or more VMs that are automatically configured and deployed to a specific subnet you create called the gateway subnet.

## Pre-requisites

* A Hub/Spoke LZ deployment (a deployment of anoa.hubspoke.bicep)
* A AKS Hub/Spoke LZ deployment (a deployment of anoa.hubspoke.aks.bicep)

The output from that deployment described below:

Deployment Output Name | Description
-----------------------| -----------
hubResourceGroupName | The resource group that contains the Hub Virtual Network and deploy the virtual machines into
hubVirtualNetworkName | The resource to deploy a subnet configured for Bastion Host
hubSubnetResourceId | The resource ID of the subnet in the Hub Virtual Network for hosting virtual machines
hubNetworkSecurityGroupResourceId | The resource ID of the Network Security Group in the Hub Virtual Network that hosts rules for Hub Subnet traffic

## Deploy the Service

Once you have the Hub/Spoke LZ output values, you can pass those in as parameters to this deployment.

For example, deploying using the `az deployment group create` command in the Azure CLI:

```bash

```
