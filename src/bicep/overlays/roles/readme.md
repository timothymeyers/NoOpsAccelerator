# Overlays: NoOps Accelerator - Roles

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

The Enclave Roles overlay module deploys a role definitions in a specific `Management Group`.  This is accomplished through a managmenent-group-scoped Azure Resource Manager (ARM) deployment.  The role definitions heirarchy can be modifed by editing `anoa.enclave.roles.parameters.example.json`.  

Module deploys the following resources:

* Enclave Roles Definitions

The definitions created by the deployment is:

* Custom - VM Operator
* Custom - Network Operations (NetOps)
* Custom - Security Operations (SecOps)
* Custom - Landing Zone Application Owner
* Custom - Landing Zone Subscription Owner
* Custom - Storage Operator

## Deploy Enclave Management Groups

The docs on Management Groups: <https://docs.microsoft.com/en-us/azure/bastion/bastion-overview>

## Pre-requisites

Currently there are no Pre-requisites

## Parameters

The module requires the following inputs:

| Parameter                             | Type   | Description                                                                                                                                                     | Requirements                      | Example               |
| ------------------------------------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- | --------------------- |
| parRoleDefinitionInfo      | object | Prefix for the role definition hierarchy.  This role definition will be created as part of the deployment.                                                    | role definition                   | `none`                 |
| parDefaultManagementGroupIdForRoleDefinitions | string | Name for default Management Group Id For role definitions. | Minimum two characters            | `ANOA` |
| parUserAssignedIdentities | array   | Set of User Assigned Identities to apply role definitions hierarchy of deployment | `none`  | `none` |

## Outputs

The module will generate the following outputs:

| Output | Type | Example |
| ------ | ---- | ------- |
None

## Deployment

In this overlay, the role definitions hierarchy are created at a specific `Management Group` through a managmenent-group-scoped deployment.

### Azure CLI

```bash
# For Azure global regions
az deployment mg create \
   --name deploy-roles \
   --management-group-id 'ANOA' \
   --template-file overlays/management-groups/anoa.enclave.roles.bicep \
   --parameters @overlays/management-groups/anoa.enclave.roles.parameters.example.json \
   --location 'eastus'
```

OR

```bash
# For Azure IL regions
az deployment mg create \
  --name deploy-roles \
  --management-group-id 'ANOA' \
  --template-file overlays/management-groups/anoa.enclave.roles.bicep \
  --parameters @overlays/management-groups/anoa.enclave.roles.parameters.example.json \
  --location 'usgovvirginia'
```

### PowerShell

```powershell
# For Azure global regions
New-AzManagementGroupDeployment `
  -ManagementGroupId xxxxxxx-xxxx-xxxxxx-xxxxx-xxxx
  -TemplateFile overlays/management-groups/anoa.enclave.roles.bicepp `
  -TemplateParameterFile overlays/management-groups/anoa.enclave.roles.parameters.example.json `
  -Location 'eastus'
```

OR

```powershell
# For Azure IL regions
New-AzManagementGroupDeployment `
  -ManagementGroupId xxxxxxx-xxxx-xxxxxx-xxxxx-xxxx
  -TemplateFile overlays/management-groups/anoa.enclave.roles.bicepp `
  -TemplateParameterFile overlays/management-groups/anoa.enclave.roles.parameters.example.json `
  -Location  'usgovvirginia'
```

## Air-Gapped Clouds

For air-gapped clouds it may be convenient to transfer and deploy the compiled ARM template instead of the Bicep template if the Bicep CLI tools are not available or if it is desirable to transfer only one file into the air gap.

## Cleanup

The Bicep/ARM deployment of NoOps Accelerator Logging deployment can be deleted with these steps:

## Example Output in Azure

![Example Deployment Output](images/operationsNetworkExampleDeploymentOutput.png "Example Deployment Output in Azure global regions")
