# Overlays: NoOps Accelerator - Policy - NIST SP 800-53 R5

> **IMPORTANT: This is currenly work in progress.**

## Overview

Azure Policy Regulatory Compliance built-in initiative definition maps to compliance domains and controls in NIST SP 800-53 Rev. 5. For more information about this compliance standard, see [NIST SP 800-53 Rev. 5](https://csrc.nist.gov/Projects/risk-management/sp800-53-controls/release-search#/).

A collection of built-in Azure Policy Sets based on Regulatory Compliance are configured with Azure NoOps Accelerator. To boost compliance for logging, networking, and tagging requirements, custom policy sets have been developed. Through automation, these can be further expanded or eliminated as needed by the department.

## About Policy

The docs on Policy: <https://learn.microsoft.com/en-us/azure/governance/policy/overview>. By default, this overlay will deploy resources into Management Groups.

The Policy can be changed by providing the Tenant Id  & Management Group Id (Param: parPolicy.tenantId/parPolicy.rootManagementGroupId) and ensuring that the Azure context is set the proper subscription.

## Pre-requisites

* A organization tenant is available.
* Decide if the optional parameters is appropriate for your deployment. If it needs to change, override one of the optional parameters.

## Parameters

See below for information on how to use the appropriate deployment parameters for use with this overlay:

Required Parameters | Type | Allowed Values | Description
| :-- | :-- | :-- | :-- |
| parPolicy | object | {object} |  Prefix for the policy definition hierarchy.  This policy definition will be created as part of the deployment. |

Optional Parameters | Type | Allowed Values | Description
| :-- | :-- | :-- | :-- |
none

## Outputs

The module will generate the following outputs:

| Output | Type | Example |
| ------ | ---- | ------- |
None

## Built-In Policy Sets Assignments

Policy |  Description
| :-- | :-- |
[NIST SP 800-53 Rev. 5](https://learn.microsoft.com/en-us/azure/governance/policy/samples/nist-sp-800-53-r4) | NIST Risk Management Framework

## Deployment

In this overlay, the policy definitions hierarchy are created at a specific `Management Group` through a managmenent-group-scoped deployment. The custom policies will be deployed to the 'ANOA' management group (the intermediate root management group).

Input parameter file parameters/deploy.parameters.all.json defines the assignable scope for the policies. In this case, it will be the same management group (i.e. 'ANOA') as the one specified for the deployment operation. There is no change in the input parameter file for different Azure clouds because there is no change to the intermediate root management group.

<h3>Overlay Example: NIST SP 800-53 Rev. 5 Policy</h3>

<details>

<summary>via Bash</summary>

```bash
# For Azure Commerical regions
az login
cd src/bicep/overlays
cd policy/nist-r5
az deployment mg create \
   --name deploy-policy-nist-r5 \
   --management-group-id 'ANOA' \
   --template-file overlays/policy/nist-r5/deploy.bicep \
   --parameters @overlays/policy/nist-r5/deploy.parameters.all.json \
   --location 'eastus'
```

```bash
# For Azure Government regions

# change Azure Clouds
az cloud set --name AzureUSGovernment

#sign  into AZ CLI, this will redirect you to a web browser for authentication, if required
az login
az deployment mg create \
   --name deploy-policy-nist-r5 \
   --management-group-id 'ANOA' \
   --template-file overlays/policy/nist-r5/deploy.bicep \
   --parameters @overlays/policy/nist-r5/deploy.parameters.all.json \
  --location 'usgovvirginia'
```

</details>
<p>

<details>

<summary>via Powershell</summary>

```powershell
# For Azure Commerical regions

#sign in to Azure  from Powershell, this will redirect you to a web browser for authentication, if required
Connect-AzAccount

#Fetch the list of available Tenant Ids.
Get-AzTenant

#Grab the tenant Id Switch to another active directory tenant.
Set-AzContext -TenantId XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

New-AzManagementGroupDeployment `
  -Name deploy-policy-nist-r5 `
  -ManagementGroupId xxxxxxx-xxxx-xxxxxx-xxxxx-xxxx
  -TemplateFile overlays/policy/nist-r5/deploy.bicep `
  -TemplateParameterFile overlays/policy/nist-r5/deploy.parameters.all.json `
  -Location 'eastus'
```

OR

```powershell
# For Azure Government regions

#sign in to Azure  from Powershell, this will redirect you to a web browser for authentication, if required
Connect-AzAccount

#Fetch the list of available Tenant Ids.
Get-AzTenant

#Grab the tenant Id Switch to another active directory tenant.
Set-AzContext -TenantId XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

New-AzManagementGroupDeployment `
  -Name deploy-policy-nist-r5 `
  -ManagementGroupId xxxxxxx-xxxx-xxxxxx-xxxxx-xxxx
  -TemplateFile overlays/policy/nist-r5/deploy.bicep `
  -TemplateParameterFile overlays/policy/nist-r5/deploy.parameters.all.json `
  -Location  'usgovvirginia'
```
</details>
<p>

## Air-Gapped Clouds

For air-gapped clouds it may be convenient to transfer and deploy the compiled ARM template instead of the Bicep template if the Bicep CLI tools are not available or if it is desirable to transfer only one file into the air gap.

## Validate the deployment

Use the Azure portal, Azure CLI, or Azure PowerShell to verify that the custom role was created.

Configure the default group using:

```bash
az role definition list --name "Custom - Network Operations (NetOps)"
```

OR

```powershell
Get-AzRoleDefinition "Custom - Network Operations (NetOps)"
```

## Cleanup

The Bicep/ARM deployment of NoOps Accelerator Roles deployment can be deleted with these steps:

Removes the `Custom - Network Operations (NetOps)` role from the anoauser@contoso.com user at the management group scope.

```bash
az role assignment delete --assignee "anoauser@contoso.com" \
--role "Custom - Network Operations (NetOps)" \
--scope "/providers/Microsoft.Management/managementGroups/anoa"
```

```powershell
Remove-AzRoleAssignment -SignInName anoauser@contoso.com `
-RoleDefinitionName "Custom - Network Operations (NetOps)" `
-Scope "/providers/Microsoft.Management/managementGroups/anoa"
```

## Example Output in Azure

![Example Deployment Output](images/operationsNetworkExampleDeploymentOutput.png "Example Deployment Output in Azure global regions")

## References

* [Understand Azure role definitions](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-definitions)

## Authoring Guide

See [Azure Policy Authoring Guide](authoring-guide.md) for step-by-step instructions.

[nist80053r5Policyset]: https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5
