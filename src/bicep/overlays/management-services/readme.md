# Module: NoOps Accelerator - Management Services

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

NoOps Accelerator management services are templates that can be deployed to extend an existing MLZ or Enclave. These services are broken down into each tier it cooridates to.

## Management Services Explanations

Service | Description
------- | -----------
Azure Automation Account | test
Bastion Host | Module to deploy a Bastion Host with Windows/Linux Jump Boxes to the Hub Network
Microsoft Defender for Cloud | Module to deploy the Microsoft Defender for Cloud to the Hub Network
Microsoft Front Door Service | Module to deploy the Microsoft Front Door Service to the Hub Network
Network Security Groups | Module to deploy the Microsoft Front Door Service to the Hub Network

