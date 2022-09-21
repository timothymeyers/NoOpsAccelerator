# Overlays:   NoOps Accelerator - Automation Account

## Overview

This overlay module deploys an Platform Landing Zone compatible Azure Automation account, with diagnostic logs pointed to the Platform Landing Zone Log Analytics Workspace (LAWS) instance.

## About Azure Automation Account

The docs on Azure Automation Account: <https://docs.microsoft.com/en-us/azure/automation/>. By default, this overlay will deploy resources into standard default hub/spoke subscriptions and resource groups.  

The subscription and resource group can be changed by providing the resource group name (Param: parTargetSubscriptionId/parTargetResourceGroup) and ensuring that the Azure context is set the proper subscription.  

Automation is needed in three broad areas of cloud operations:

* Deploy and manage - Deliver repeatable and consistent infrastructure as code.
* Response - Create event-based automation to diagnose and resolve issues.
* Orchestrate - Orchestrate and integrate your automation with other Azure or third party services and products.

One Automation account can manage resources across all regions and subscriptions for a given tenant.

## Pre-requisites

* A hub/spoke LZ deployment (a deployment of [deploy.bicep](../../../../bicep/platforms/lz-platform-scca-hub-3spoke/deploy.bicep))
* Decide if the optional parameters is appropriate for your deployment. If it needs to change, override one of the optional parameters.

See below for information on how to use the appropriate deployment parameters for use with this overlay:

Required Parameters | Type | Allowed Values | Description
| :-- | :-- | :-- | :-- |
parRequired | object | {object} | Required values used with all resources.
parTags | object | {object} | Required tags values used with all resources.
parLocation | string | `[deployment().location]` | The region to deploy resources into. It defaults to the deployment location.
parLockLevel | string | `[deployment().location]` | The region to deploy resources into. It defaults to the deployment location.
parDiagnosticStorageAccountName | The resource group that contains the Hub Virtual Network and deploy the virtual machines into
parLogAnalyticsWorkspaceName | The resource to deploy a subnet configured for Bastion Host
parTargetSubscriptionId | string | `xxxxxx-xxxx-xxxx-xxxxx-xxxxxx` | The target subscription ID for the target Network and resources. It defaults to the deployment subscription.
parTargetResourceGroup | string | `anoa-eastus-platforms-hub-rg` | The name of the resource group in which the automation account will be deployed. If unchanged or not specified, the NoOps Accelerator will create an resource group.


## Deploy the Service

Once you have the Mission LZ output values, you can pass those in as parameters to this deployment.

For example, deploying using the `az deployment group create` command in the Azure CLI:

```bash

```
