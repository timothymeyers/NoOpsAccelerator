# Overlays: NoOps Accelerator - Roles

## Overview

The Enclave Roles overlay module deploys a role definitions in a specific `Management Group`.  This is accomplished through a managmenent-group-scoped Azure Resource Manager (ARM) deployment.  The role definitions heirarchy can be modifed by editing `deploy.parameters.json`.  

Module deploys the following resources:

* Enclave Roles Definitions

The definitions created by the deployment is:

* Custom - VM Operator
* Custom - Network Operations (NetOps)
* Custom - Security Operations (SecOps)
* Custom - Landing Zone Application Owner
* Custom - Landing Zone Subscription Owner
* Custom - Storage Operator

## Deploy Enclave Roles

The docs on Roles: <https://docs.microsoft.com/en-us/azure/bastion/bastion-overview>

## Pre-requisites

Currently there are no Pre-requisites

## Parameters

The module requires the following inputs:

| Parameter                             | Type   | Description                                                                                                                                                     | Requirements                      | Example               |
| ------------------------------------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- | --------------------- |
| parAssignableScopeManagementGroupId       | object | The management group scope to which the role can be assigned.  This management group ID will be used for the assignableScopes property in the role definition.
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
# For Azure Commerical regions
az deployment mg create \
   --name deploy-roles \
   --management-group-id 'ANOA' \
   --template-file overlays/management-groups/anoa.enclave.roles.bicep \
   --parameters @overlays/management-groups/anoa.enclave.roles.parameters.example.json \
   --location 'eastus'
```

OR

```bash
# For Azure Government regions
az deployment mg create \
  --name deploy-roles \
  --management-group-id 'ANOA' \
  --template-file overlays/management-groups/anoa.enclave.roles.bicep \
  --parameters @overlays/management-groups/anoa.enclave.roles.parameters.example.json \
  --location 'usgovvirginia'
```

### PowerShell

```powershell
# For Azure Commerical regions
New-AzManagementGroupDeployment `
  -ManagementGroupId xxxxxxx-xxxx-xxxxxx-xxxxx-xxxx
  -TemplateFile overlays/management-groups/anoa.enclave.roles.bicepp `
  -TemplateParameterFile overlays/management-groups/anoa.enclave.roles.parameters.example.json `
  -Location 'eastus'
```

OR

```powershell
# For Azure Government regions
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
