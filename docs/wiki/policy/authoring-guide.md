# Azure Policy Authoring Guide

NoOps Accelerator uses Built-In and Custom Policies to provide guardrails in the Azure environment.  The goal of this authoring guide is to provide step-by-step instructions to manage and customize policy definitions and assignments that align with your organization's compliance requirements.

## Table of Contents

* [Existing configuration](#existing-configuration)
* [Built-in policy sets](#built-in-policy-sets)
  * [New built-in policy set assignment](#new-built-in-policy-set-assignment)
    * [Step 1: Collect information](#step-1-collect-information)
    * [Step 2: Create Bicep template & parameters JSON file](#step-2-create-bicep-template--parameters-json-file)
    * [Step 3: Update Azure DevOps Pipeline](#step-3-update-azure-devops-pipeline)
    * [Step 4: Deploy built-in policy set assignment](#step-4-deploy-built-in-policy-set-assignment)
    * [Step 5: Verify policy set assignment](#step-5-verify-policy-set-assignment)
  * [Remove built-in policy set assignment](#remove-built-in-policy-set-assignment)
    * [Step 1: Remove built-in policy set assignment from Azure DevOps Pipeline](#step-1-remove-built-in-policy-set-assignment-from-azure-devops-pipeline)
    * [Step 2: Remove built-in policy set assignment's IAM assignments](#step-2-remove-built-in-policy-set-assignments-iam-assignments)
  * [Enable or disable built-in policy set enforcement](#enable-or-disable-built-in-policy-set-enforcement)
* [Custom policies](#custom-policies)
  * [New custom policy definition](#new-custom-policy-definition)
    * [Step 1: Create policy definition template](#step-1-create-policy-definition-template)
    * [Step 2: Deploy policy definition template](#step-2-deploy-policy-definition-template)
    * [Step 3: Verify policy definition deployment](#step-3-verify-policy-definition-deployment)
    * Step 4: Add policy definition to a [new custom policy set](#new-custom-policy-set-definition--assignment) or [update an existing policy set](#update-custom-policy-set-definition--assignment)
  * [New custom policy set definition & assignment](#new-custom-policy-set-definition--assignment)
    * [Step 1: Create policy set definition template](#step-1-create-policy-set-definition-template)
    * [Step 2: Create policy set assignment template](#step-2-create-policy-set-assignment-template)
    * [Step 3: Configure Azure DevOps Pipeline](#step-3-configure-azure-devops-pipeline)
    * [Step 4: Deploy definition & assignment](#step-4-deploy-definition--assignment)
    * [Step 5: Verify policy set definition and assignment deployment](#step-5-verify-policy-set-definition-and-assignment-deployment)
  * [Update custom policy definition](#update-custom-policy-definition)
    * [Step 1: Update policy definition](#step-1-update-policy-definition)
    * [Step 2: Verify policy definition deployment after update](#step-2-verify-policy-definition-deployment-after-update)
  * [Update custom policy set definition & assignment](#update-custom-policy-set-definition--assignment)
    * [Step 1: Update policy set definition & assignment](#step-1-update-policy-set-definition--assignment)
    * [Step 2: Verify policy set definition & assignment after update](#step-2-verify-policy-set-definition--assignment-after-update)
  * [Remove custom policy definition](#remove-custom-policy-definition)
    * [Step 1: Remove policy definition](#step-1-remove-policy-definition)
  * [Remove custom policy set definition and assignment](#remove-custom-policy-set-definition-and-assignment)
    * [Step 1: Remove custom policy set definition](#step-1-remove-custom-policy-set-definition)
    * [Step 2: Remove custom policy set assignment](#step-2-remove-custom-policy-set-assignment)
    * [Step 3: Remove custom policy set from Azure DevOps Pipeline](#step-3-remove-custom-policy-set-from-azure-devops-pipeline)
    * [Step 4: Remove custom policy set assignment's IAM assignments](#step-4-remove-custom-policy-set-assignments-iam-assignments)
  * [Enable or disable custom policy set enforcement](#enable-or-disable-custom-policy-set-enforcement)
  * [Auto generate custom Diagnostic Settings policies for PaaS services](#auto-generate-custom-diagnostic-settings-policies-for-paas-services)

## Authored & Tested With

* [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) version 2.38.0
* bicep cli version 0.6.18
* [bicep](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) v0.8.9 vscode extension

Module Tested on:

* Azure Commercial ✔️
* Azure Government ✔️
* Azure Government Secret ✔️
* Azure Government Top Secret ❔

> ✔️ = tested,  ❔= currently testing

## Prerequisites

* For deployments in the Azure Portal you need access to the portal in the cloud you want to deploy to, such as [https://portal.azure.com](https://portal.azure.com) or [https://portal.azure.us](https://portal.azure.us).
* For deployments in BASH or a Windows shell, then a terminal instance with the AZ CLI installed is required.
* For PowerShell deployments you need a PowerShell terminal with the [Azure Az PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/what-is-azure-powershell) installed.

> NOTE: The AZ CLI will automatically install the Bicep tools when a command is run that needs them, or you can manually install them following the [instructions here.](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli)

## Existing configuration

### Built-in policy assignments

Built-in policy set assignment templates are located in [`/policy/builtin/assignments`](../../policy/builtin/assignments) directory.

| Policy Set | Description | Deployment Template | Configuration |
| --- | --- | --- | --- |
| [NIST SP 800-53 Revision 4][nist80053R4policySet] | This initiative includes policies that address a subset of NIST SP 800-53 Rev. 4 controls. | [nist80053r4.bicep](../../policy/builtin/assignments/nist80053r4.bicep) | [nist80053r4.parameters.json](../../policy/builtin/assignments/nist80053r4.parameters.json) |
| [NIST SP 800-53 Revision 5][nist80053R5policySet] | This initiative includes policies that address a subset of NIST SP 800-53 Rev. 5 controls. | [nist80053r5.bicep](../../policy/builtin/assignments/nist80053r5.bicep) | [nist80053r5.parameters.json](../../policy/builtin/assignments/nist80053r5.parameters.json) |
| [Azure Security Benchmark][asbPolicySet] | The Azure Security Benchmark initiative represents the policies and controls implementing security recommendations defined in Azure Security Benchmark, see https://aka.ms/azsecbm. This also serves as the Microsoft Defender for Cloud default policy initiative. | [asb.bicep](../../policy/builtin/assignments/asb.bicep) | [asb.parameters.json](../../policy/builtin/assignments/asb.parameters.json) |
|	[FedRAMP Moderate][fedrampmPolicySet] | This initiative includes policies that address a subset of FedRAMP Moderate controls. | [fedramp-moderate.bicep](../../policy/builtin/assignments/fedramp-moderate.bicep) | [fedramp-moderate.parameters.json](../../policy/builtin/assignments/fedramp-moderate.parameters.json) |
|	[FedRAMP High][fedrampmPolicySet] | This initiative includes policies that address a subset of FedRAMP High controls. | [fedramp-high.bicep](../../policy/builtin/assignments/fedramp-high.bicep) | [fedramp-high.parameters.json](../../policy/builtin/assignments/fedramp-high.parameters.json) |

### Custom policy set definitions and assignments

NoOps Accelerator recommeds using the Custom policy sets. These policy-sets allow to implement a service catalog for services that you support. 

Custom policy set definition templates are located in [`/policy/custom/definitions/policyset`](../../policy/custom/definitions/policyset) directory.

Custom policy set assignment templates are located in [`/policy/custom/assignments`](../../policy/custom/assignments) directory.

| Policy Set | Description | Policy set definition deployment template | Configuration |
| --- | --- | --- | --- |
| Compute Governance | Azure Policy Add-on to Compute Services. | [Compute.bicep](../../policy/custom/definitions/policyset/compute.bicep) | [Compute.parameters.json](../../policy/custom/definitions/policyset/compute.parameters.json)
| Data Protection Governance | Configures Microsoft Defender for Cloud, including Azure Defender for subscription and resources. | [DefenderForCloud.bicep](../../policy/custom/definitions/policyset/DefenderForCloud.bicep) | [DefenderForCloud.parameters.json](../../policy/custom/definitions/policyset/DefenderForCloud.parameters.json)
| Identity & Access Management Governance | Policies to configure DNS zone records for private endpoints.  Policy set is assigned through deployment pipeline when private endpoint DNS zones are managed in the Hub Network. | [DNSPrivateEndpoints.bicep](../../policy/custom/definitions/policyset/DNSPrivateEndpoints.bicep) | [DNSPrivateEndpoints.parameters.json](../../policy/custom/definitions/policyset/DNSPrivateEndpoints.parameters.json)
| Key Vault Governance | Configures monitoring agents for IaaS and diagnostic settings for PaaS to send logs to a central Log Analytics Workspace. | [LogAnalytics.bicep](../../policy/custom/definitions/policyset/LogAnalytics.bicep) | [LogAnalytics.parameters.json](../../policy/custom/definitions/policyset/LogAnalytics.parameters.json)
| Networking Governance | Configures policies for network resources. | [Network.bicep](../../policy/custom/definitions/policyset/Network.bicep) | [Network.parameters.json](../../policy/custom/definitions/policyset/Network.parameters.json)
| Security Governance | Configures required tags and tag propagation from resource groups to resources. | [Tags.bicep](../../policy/custom/definitions/policyset/Tags.bicep) | [Tags.parameters.json](../../policy/custom/definitions/policyset/Tags.parameters.json) |
| SQL Governance | Configures required tags and tag propagation from resource groups to resources. | [Tags.bicep](../../policy/custom/definitions/policyset/Tags.bicep) | [Tags.parameters.json](../../policy/custom/definitions/policyset/Tags.parameters.json) |
| Storage Governance | Configures required tags and tag propagation from resource groups to resources. | [Tags.bicep](../../policy/custom/definitions/policyset/Tags.bicep) | [Tags.parameters.json](../../policy/custom/definitions/policyset/Tags.parameters.json) |
| Tag Governance | Configures required tags and tag propagation from resource groups to resources. | [Tags.bicep](../../policy/custom/definitions/policyset/Tags.bicep) | [Tags.parameters.json](../../policy/custom/definitions/policyset/Tags.parameters.json)

---

## Built-in policy sets

The built-in policy sets are used as-is to ensure future improvements from Azure Engineering teams are automatically incorporated into the Azure environment.

### **New built-in policy set assignment**

**Steps**

* [Step 1: Collect information](#step-1-collect-information)
* [Step 2: Create Bicep template & parameters JSON file](#step-2-create-bicep-template--parameters-json-file)
* [Step 3: Update Azure DevOps Pipeline](#step-3-update-azure-devops-pipeline)
* [Step 4: Deploy built-in policy set assignment](#step-4-deploy-built-in-policy-set-assignment)
* [Step 5: Verify policy set assignment](#step-5-verify-policy-set-assignment)

> We will not be assigning the policy through Azure Portal, but use these steps to identify the necessary info, such as name, definition ID, permissions, and parameters, which are required for the Policy Assignment.

#### **Step 1: Collect information**

1. Navigate to [Azure Portal -> Azure Policy -> Definitions][portalAzurePolicyDefinition]
2. Open the Built-In Policy Set (it is also called an Initiative) that will be assigned through automation.  For example: `DOD Compute Governance`

    *Collect the following information:*

      * **Name** (e.g. `DOD Compute Governance`)
      * **Definition ID** (e.g. `/providers/Microsoft.Authorization/policySetDefinitions/4c4a5f27-de81-430b-b4e5-9cbd50595a87`)

3. Click the **Assign** button and **select a scope** for the assignment.  We will not be assigning the policy through Azure Portal, but use this step to identify the permissions required for the Policy Assignment.

    *Collect the following information from the **Remediation** tab:*

    * **Permissions** - required when there are auto remediation policies.  You may see zero, one (e.g. `Contributor`) or many comma-separated (e.g. `Log Analytics Contributor, Virtual Machine Contributor, Monitoring Contributor`) roles listed.  Permissions will not be listed when none are required for the policy assignment to function.

    Once the permissions are identified, click the **Cancel** button to discard the changes.

    Use [Azure Built-In Roles table](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles) to map the permission name to it's Resource ID.  Resource ID will be used when defining the role assignments. 

4. Click on the **Duplicate initiative** button.  We will not be duplicating the policy set definition, but use this step to identify the parameter names that will need to be populated during policy assignment.

    *Collect the following information from the **Initiative parameters** tab:*

    * **Parameters** (e.g. `logAnalytics`, `logAnalyticsWorkspaceId`, `listOfResourceTypesToAuditDiagnosticSettings`).  You may see zero, one or many parameters listed.  It is possible that a policy set doesn't have any parameters.

#### **Step 2: Create Bicep template & parameters JSON file**

1. Navigate to `policy/builtin/assignments` directory and create two files.  Replace `POLICY_ASSIGNMENT` with the name of your assignment such as `pbmm`.

   * POLICY_ASSIGNMENT.bicep (i.e. `pbmm.bicep`) - this file defines the policy assignment deployment
   * POLICY_ASSIGNMENT.parameters.json (i.e. `pbmm.parameters.json`) - this file defines the parameters used to deploy the policy assignment.

2. Edit the Bicep file to include the following template.  This template can be customized as required.  Pre-requisites are:

    * targetScope must be `managementGroup`
    * parameter `policyAssignmentManagementGroupId` must be defined.  It is used to set the policy assignment through automation.

    **Sample Template**

    ```bicep
      targetScope = 'managementGroup'

      @description('Management Group scope for the policy assignment.')
      param parPolicyAssignmentManagementGroupId string

      @allowed([
        'Default'
        'DoNotEnforce'
      ])
      @description('Policy set assignment enforcement mode.  Possible values are { Default, DoNotEnforce }.  Default value:  Default')
      param parEnforcementMode string = 'Default'

      // Start - Any custom parameters required for your policy assignment
      param ...
      // End - Any custom parameters required for your policy assignment

      // Add the GUID from the Definition ID that was gathered above
      var varPolicyId = '<< GUID >>'

      // Add the policy set assignment name (i.e. the name of the Policy Set Name)
      var varAssignmentName = '<< POLICY ASSIGNMENT NAME >>'

      var varScope = tenantResourceId('Microsoft.Management/managementGroups', parPolicyAssignmentManagementGroupId)
      var varPolicyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', varPolicyId)

      resource resPolicySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {

        // Set the name of the policy assignment
        // Example: name: 'pbmm-${uniqueString('pbmm-',policyAssignmentManagementGroupId)}'

        name: '<< NAME >>'

        properties: {
          displayName: varAssignmentName
          policyDefinitionId: varPolicyScopedId
          scope: varScope
          notScopes: [
          ]
          parameters: {
            // Add any parameters identified earlier into this section
          }

          // The policy assignment enforcement mode. Possible values are Default and DoNotEnforce.
          enforcementMode: parEnforcementMode
        }
        identity: {
          type: 'SystemAssigned'
        }
        location: deployment().location
      }

      // These role assignments are required to allow Policy Assignment to remediate.
      // Add this section only when there are permissions to assign to the policy set.
      // Ensure that the name is a GUID and generated with a deterministic formula such as the example below.
      // Set the role definition id based on the information gathered earlier.
      resource resPolicySetRoleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
        name: guid(parPolicyAssignmentManagementGroupId, 'pbmm-Contributor')
        scope: managementGroup()
        properties: {
          roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          principalId: resPolicySetAssignment.identity.principalId
          principalType: 'ServicePrincipal'
        }
      }
    ```

    **Example: PBMM Policy Set Assignment**

    ```bicep
      targetScope = 'managementGroup'

      @description('Management Group scope for the policy assignment.')
      param parPolicyAssignmentManagementGroupId string

      @allowed([
        'Default'
        'DoNotEnforce'
      ])
      @description('Policy set assignment enforcement mode.  Possible values are { Default, DoNotEnforce }.  Default value:  Default')
      param parEnforcementMode string = 'Default'

      @description('Log Analytics Resource Id to integrate Microsoft Defender for Cloud.')
      param parLogAnalyticsWorkspaceId string

      @description('List of members that should be excluded from Windows VM Administrator Group.')
      param parListOfMembersToExcludeFromWindowsVMAdministratorsGroup string

      @description('List of members that should be included in Windows VM Administrator Group.')
      param parListOfMembersToIncludeInWindowsVMAdministratorsGroup string

      var varPolicyId = '4c4a5f27-de81-430b-b4e5-9cbd50595a87' // DOD Compute Governance
      var varAssignmentName = 'DOD Compute Governance'

      var varScope = tenantResourceId('Microsoft.Management/managementGroups', policyAssignmentManagementGroupId)
      var varPolicyScopedId = resourceId('Microsoft.Authorization/policySetDefinitions', policyId)

      resource resPolicySetAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
        name: 'pbmm-${uniqueString('pbmm-',policyAssignmentManagementGroupId)}'
        properties: {
          displayName: varAssignmentName
          policyDefinitionId: varPolicyScopedId
          scope: varScope
          notScopes: [
          ]
          parameters: {
            logAnalyticsWorkspaceIdforVMReporting: {
              value: parLogAnalyticsWorkspaceId
            }
            listOfMembersToExcludeFromWindowsVMAdministratorsGroup: {
              value: parListOfMembersToExcludeFromWindowsVMAdministratorsGroup
            }
            listOfMembersToIncludeInWindowsVMAdministratorsGroup: {
              value: parListOfMembersToIncludeInWindowsVMAdministratorsGroup
            }
          }
          enforcementMode: parEnforcementMode
        }
        identity: {
          type: 'SystemAssigned'
        }
        location: deployment().location
      }

      // These role assignments are required to allow Policy Assignment to remediate.
      resource policySetRoleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
        name: guid(parPolicyAssignmentManagementGroupId, 'pbmm-Contributor')
        scope: managementGroup()
        properties: {
          roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          principalId: resPolicySetAssignment.identity.principalId
          principalType: 'ServicePrincipal'
        }
      }
    ```

3. Edit the JSON parameters file to define the input parameters for the Bicep template.  This parameters JSON file is used by Azure Resource Manager (ARM) for runtime inputs.

    You can use any of the [templated parameters](readme.md#templated-parameters) to set values based on environment configuration or hard code them as needed.

    **Sample Template**

    ```json
    {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "policyAssignmentManagementGroupId": {
                "value": "{{var-policyAssignmentManagementGroupId}}"
            },
            "enforcementMode": {
                "value": "Default"
            },
            "EXTRA_POLICY_ASSIGNMENT_PARAMETER_NAME_1": {
                "value": "EXTRA_POLICY_ASSIGNMENT_PARAMETER_VALUE_1"
            },
            "EXTRA_POLICY_ASSIGNMENT_PARAMETER_NAME_2": {
                "value": "EXTRA_POLICY_ASSIGNMENT_PARAMETER_VALUE_2"
            }
        }
    }
    ```

    **Example:  PBMM Policy Set Parameters**

    ```json
    {
        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
        "contentVersion": "1.0.0.0",
        "parameters": {
            "policyAssignmentManagementGroupId": {
                "value": "{{var-policyAssignmentManagementGroupId}}"
            },
            "enforcementMode": {
                "value": "Default"
            },
            "logAnalyticsWorkspaceId": {
                "value": "{{var-logging-logAnalyticsWorkspaceId}}"
            },
            "listOfMembersToExcludeFromWindowsVMAdministratorsGroup": {
                "value": "__tbd__implementation_specific__"
            },
            "listOfMembersToIncludeInWindowsVMAdministratorsGroup": {
                "value": "__tbd__implementation_specific__"
            }
        }
    }
    ```