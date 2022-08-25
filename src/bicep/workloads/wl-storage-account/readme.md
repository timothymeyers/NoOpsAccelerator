# NoOps Accelerator - Management Services - Shared Services - Azure Storage Account Deployment

## Authored & Tested With

* [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) version 2.38.0
* bicep cli version v0.9.1
* [bicep](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) v0.9.1 vscode extension

## Navigation

- [Overview](#overview)
- [Deploy Virtual Machines](#deploy-virtual-machines)
- [Resource Types](#Resource-Types)
- [Pre-requisites](#pre-requisites)
- [Parameters](#add-on-parameters)
- [Outputs](#Outputs)
- [Deployment](#deployment)

## Overview

This add-on module creates a shared services deployment that deploys a premium Azure Storage Account with RBAC enabled to support secret, key, and certificate management.

Read on to understand what this add-on does, and when you're ready, collect all of the pre-requisites, then deploy the add-on.

## Deploy Azure Storage Account

The docs on Azure Storage: <https://docs.microsoft.com/en-us/azure/storage/>. This add-on shows how to deploy using Bicep to support the deployment. By default, this template will deploy resources into standard default MLZ subscriptions and resource groups.

The subscription and resource group can be changed by providing the resource group name (Param: targetResourceGroup) and ensuring that the Azure context is set the proper subscription.

## Pre-requisites

* A NoOps Accelerator - Mission LZ deployment a deployment of [anoa.mlz.bicep]('../../../../../../mission-landing-zone/anoa.mlz.bicep')
* For deployments in the Azure Portal you need access to the portal in the cloud you want to deploy to, such as [https://portal.azure.com](https://portal.azure.com) or [https://portal.azure.us](https://portal.azure.us).
* For deployments in BASH or a Windows shell, then a terminal instance with the AZ CLI installed is required.
* For PowerShell deployments you need a PowerShell terminal with the [Azure Az PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/what-is-azure-powershell) installed.

> NOTE: The AZ CLI will automatically install the Bicep tools when a command is run that needs them, or you can manually install them following the [instructions here.](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli)

## Add-On Parameters

| Parameter | Type | Default | Description | Requirement | Example |
| --------- | ---- | ------- | ----------- | ----------- | ------- |
storageAccountName | string | none | The name of Storage Account.  If not specified, the name will default to the MLZ default naming pattern. | Yes |  |
targetResourceGroup | string | none | The name of the resource group where the key vault will be deployed.   If not specified, the resource group name will default to the shared services MLZ resource group name and subscription. | Yes |  |

## Outputs

The module does not generate any outputs

| Output | Type
| ------ | ----
storageAccountName | string |
resourceGroupName | string |
tags | object |

## Deployment

Connect to the appropriate Azure Environment and set appropriate context, see getting started with Azure PowerShell for help if needed. The commands below assume you are deploying in Azure Commercial and show the entire process from deploying MLZ and then adding a key vault post-deployment.

```Azure CLI

```

## References

* [Azure Storage Account Documentation](https://docs.microsoft.com/en-us/azure/storage/)
* [AzureStorage Account Overview](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview)
