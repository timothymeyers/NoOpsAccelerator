# Overlays:   NoOps Accelerator - Application Gateway

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

This overlay module adds an web traffic load balancer that enables you to manage traffic to your web applications. This application gateway is meant to be in the Hub Network.

## Deploy Application Gateway

The docs on Application Gateway : <https://docs.microsoft.com/en-us/azure/application-gateway/overview>

Some particulars about Application Gateway:

* Supports Secure Sockets Layer (SSL/TLS) termination
* Supports Autoscaling
* Zone redundancy
* Can be a Web Application Firewall
* Ingress Controller for AKS

## Pre-requisites

* A Hub/Spoke LZ deployment (a deployment of anoa.hubspoke.bicep)
* A AKS Hub/Spoke LZ deployment (a deployment of anoa.hubspoke.aks.bicep)

See below for information on how to use the appropriate deployment parameters for use with this overlay:

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
