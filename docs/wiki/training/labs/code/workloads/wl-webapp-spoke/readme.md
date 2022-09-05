# NoOps Accelerator - Workloads - Tier 3 - Azure Web App Workload

## Authored & Tested With

* [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) version 2.38.0
* bicep cli version v0.9.1
* [bicep](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) v0.9.1 vscode extension

## Overview

This add-on module creates a shared services deployment that deploys a premium Azure Key Vault with RBAC enabled to support secret, key, and certificate management. A premium key vault utilizes hardware security modules to protect key material. Roles for use must be assigned post-deployment, review reference list below for detailed information.

Read on to understand what this add-on does, and when you're ready, collect all of the pre-requisites, then deploy the add-on.

## Deploy Azure Key Vault

The docs on Azure Key Vault: <https://docs.microsoft.com/en-us/azure/key-vault/>. This add-on shows how to deploy using Bicep to support the deployment. By default, this template will deploy resources into standard default MLZ subscriptions and resource groups.

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
keyVaultName | string | none | The name of key vault.  If not specified, the name will default to the MLZ default naming pattern. | Yes |  |
targetResourceGroup | string | none | The name of the resource group where the key vault will be deployed.   If not specified, the resource group name will default to the shared services MLZ resource group name and subscription. | Yes |  |

## Outputs

The module does not generate any outputs

| Output | Type
| ------ | ----
azureKeyVaultName | string |
resourceGroupName | string |
tags | object |

## Deployment

Connect to the appropriate Azure Environment and set appropriate context, see getting started with Azure PowerShell for help if needed. The commands below assume you are deploying in Azure Commercial and show the entire process from deploying MLZ and then adding a key vault post-deployment.

```Azure CLI

```

## References

* [Azure Key Vault Documentation](https://docs.microsoft.com/en-us/azure/key-vault/)
* [Azure Key Vault Overview](https://docs.microsoft.com/en-us/azure/key-vault/general/overview)
* [Provide access to Key Vault via RBAC](https://docs.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli)
