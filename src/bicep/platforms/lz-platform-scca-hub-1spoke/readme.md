# NoOps Accelerator - Platforms - SCCA Compliant Hub - 1 Spoke

## Overview

This platform module deploys Hub 1 Spoke landing zone.

> NOTE: This is only the landing zone deployment. The workloads will be deployed with the enclave or can be deployed after the landing zone is created.

Read on to understand what this landing zone does, and when you're ready, collect all of the pre-requisites, then deploy the landing zone.

## Architecture

 ![Hub/Spoke landing zone Architecture](../../../bicep/)

## About Hub 1 Spoke Landing Zone

The docs on Hub/Spoke Landing Zone: <https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans>.

## Pre-requisites

* One or more Azure subscriptions where you or an identity you manage has Owner RBAC permissions
* For deployments in the Azure Portal you need access to the portal in the cloud you want to deploy to, such as <https://portal.azure.com> or <https://portal.azure.us>.
* For deployments in BASH or a Windows shell, then a terminal instance with the AZ CLI installed is required. For example, Azure Cloud Shell,   or a command shell on your local machine with the AZ CLI installed.
* For PowerShell deployments you need a PowerShell terminal with the Azure Az PowerShell module installed.

>NOTE: The AZ CLI will automatically install the Bicep tools when a command is run that needs them, or you can manually install them following the instructions here.

Required Parameters | Type | Allowed Values | Description
| :-- | :-- | :-- | :-- |
parRequired | object | {object} | Required values used with all resources.
parTags | object | {object} | Required tags values used with all resources.
parLocation | string | `[deployment().location]` | The region to deploy resources into. It defaults to the deployment location.

Optional Parameters | Type | Allowed Values | Description
| :-- | :-- | :-- | :-- |
None

## Deploy the Landing Zone

Connect to the appropriate Azure Environment and set appropriate context, see getting started with Azure PowerShell or Azure CLI for help if needed. The commands below assume you are deploying in Azure Commercial and show the entire process deploying Platform Hub/Spoke Design.

> NOTE: Since you can deploy this overlay post-deployment, you can also build this overlay within other deployment models such as Platforms & Workloads.

Once you have the hub/spoke output values, you can pass those in as parameters to this deployment.

For example, deploying using the `az deployment sub create` command in the Azure CLI:

### Azure CLI

```bash
# For Azure Commerical regions
az login
cd src/bicep
cd platforms/lz-platform-scca-hub-1spoke
az deployment sub create \ 
--name contoso \
--subscription xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx \
--template-file platforms/lz-platform-scca-hub-1spoke/deploy.bicep \
--location eastus \
--parameters @platforms/lz-platform-scca-hub-1spoke/parameters/deploy.parameters.json
```

OR

```bash
# For Azure Government regions
az deployment sub create \
  --template-file platforms/lz-platform-scca-hub-1spoke/deploy.bicep \
  --parameters @platforms/lz-platform-scca-hub-1spoke/parameters/deploy.parameters.json \
  --subscription xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx \
  --resource-group anoa-usgovvirginia-platforms-hub-rg \
  --location 'usgovvirginia'
```

### PowerShell

```powershell
# For Azure Commerical regions
New-AzSubscriptionDeployment `
  -TemplateFile platforms/lz-platform-scca-hub-1spoke/deploy.bicepp `
  -TemplateParameterFile platforms/lz-platform-scca-hub-1spoke/parameters/deploy.parameters.example.json `
  -Subscription xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx `
  -Location 'eastus'
```

OR

```powershell
# For Azure Government regions
New-AzSubscriptionDeployment `
  -TemplateFile platforms/lz-platform-scca-hub-1spoke/deploy.bicepp `
  -TemplateParameterFile platforms/lz-platform-scca-hub-1spoke/parameters/deploy.parameters.example.json `
  -Subscription xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx `
  -Location  'usgovvirginia'
```

## Extending the Landing Zone

By default, this overlay has the minium parmeters needed to deploy the service. If you like to add addtional parmeters to the service, please refer to the module description located in AzResources here: [`App Service Plans `[Microsoft.Web/serverfarms]`](D:\source\repos\NoOpsAccelerator\src\bicep\azresources\Modules\Microsoft.Web\serverfarms\readme.md)

## Air-Gapped Clouds

For air-gapped clouds it may be convenient to transfer and deploy the compiled ARM template instead of the Bicep template if the Bicep CLI tools are not available or if it is desirable to transfer only one file into the air gap.

## Validate the deployment

Use the Azure portal, Azure CLI, or Azure PowerShell to list the deployed resources in the resource group.

Configure the default group using:

```bash
az configure --defaults group=anoa-eastus-dev-appplan-rg.
```

```bash
az resource list --location eastus --subscription xxxxxx-xxxx-xxxx-xxxx-xxxxxxxx --resource-group anoa-eastus-dev-appplan-rg
```

```powershell
Get-AzResource -ResourceGroupName anoa-eastus-dev-appplan-rg
```

## Cleanup

The Bicep/ARM deployment of NoOps Accelerator - Azure App Service Plan deployment can be deleted with these steps:

### Delete Resource Groups

```bash
az group delete --name anoa-eastus-dev-appplan-rg
```

```powershell
Remove-AzResourceGroup -Name anoa-eastus-dev-appplan-rg
```

### Delete Deployments

```bash
az deployment delete --name deploy-AppServicePlan
```

```powershell
Remove-AzSubscriptionDeployment -Name deploy-AppServicePlan
```

## Example Output in Azure

![Example Deployment Output](media/aspExampleDeploymentOutput.png "Example Deployment Output in Azure global regions")

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/locks` | [2017-04-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2017-04-01/locks) |
| `Microsoft.Authorization/roleAssignments` | [2020-10-01-preview](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-10-01-preview/roleAssignments) |
| `Microsoft.Insights/diagnosticSettings` | [2021-05-01-preview](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings) |
| `Microsoft.Network/privateEndpoints` | [2021-08-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-08-01/privateEndpoints) |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | [2021-08-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-08-01/privateEndpoints/privateDnsZoneGroups) |
| `Microsoft.App/containerApps` | [2021-03-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.app/2022-03-01/containerapps) |
| `Microsoft.App/managedEnvironments` | [2021-03-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.app/2022-03-01/managedenvironments) |

### References

* [Azure App Service plan Documentation](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans/)
* [Azure App Service Overview](https://docs.microsoft.com/en-us/azure/app-service/overview)
* [Manage an App Service plan in Azure](https://docs.microsoft.com/en-us/azure/app-service/app-service-plan-manage)
