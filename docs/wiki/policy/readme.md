# Azure Policy - Building Policy for Guardrails

## Table of Contents

* [Overview](#overview)
* [Built-In Policy Sets Assignments](#built-in-policy-sets-assignments)
* [Custom Policies and Policy Sets](#custom-policies-and-policy-sets)
  * [Custom Policy Definitions](#custom-policy-definitions)
  * [Custom Policy Set Definitions](#custom-policy-set-definitions)
  * [Custom Policy Set Assignments](#custom-policy-set-assignments)
* [Templated Parameters](#templated-parameters)
* [Authoring Guide](#authoring-guide)

## Overview

Azure's [Azure Policy](https://docs.microsoft.com/azure/governance/policy/overview) is used to deploy guardrails. Azure Policy supports organizational standards enforcement and at-scale compliance evaluation. With the ability to drill down to the per-resource and per-policy granularity, it offers an aggregated view to assess the overall condition of the environment through its compliance dashboard. Bulk remediation for existing resources and automated remediation for new resources both assist in bringing your resources into compliance.

Implementing governance for resource consistency, legal compliance, security, cost, and management are common use cases for Azure Policy. To assist you in getting started, your Azure environment already has built-in policy definitions for these typical use cases.

![Azure Policy Compliance](../media/architecture/policy-compliance.jpg)

A set of Custom & Built-in Azure Policy Sets based on Regulatory Compliance are setup with NoOps Accelerator. To boost compliance for compute, data, IAM, storage, logging, networking, and tagging requirements, custom policy sets have been developed. Through automation, these can be further expanded or eliminated as needed by use case.

---

## Built-In Policy Sets Assignments

> **Note**: To ensure that any future advancements made by the Azure Engineering teams are automatically incorporated into the Azure environment, the built-in policy settings are used as-is.

All built-in policy set assignments are located in [policy/builtin/assignments](../../policy/builtin/assignments) folder.

* For the purpose of remediating policies, deployment templates can be adjusted with new policy elements and role assignments.
* When assigning a policy set, runtime parameters are defined in configuration files.

All policy set assignments are at the `root` top level management group.  This top level management group is retrieved from configuration parameter `var-topLevelManagementGroupName`.  See the [GitHub Actions](../onboarding/github-actions.md) onboarding guide for instructions to setting up management groups & policy pipeline.

| Policy Set | Description | Deployment Template | Configuration |
| --- | --- | --- | --- |

## Custom Policies and Policy Sets

> **Note**: When a built-in alternative is unavailable, custom policies and policy sets are applied. As new options become available, automation is continually updated to utilize built-in policies and policy sets.

All policies and policy set definitions & assignments are at the `root` top level management group.  This top level management group is retrieved from configuration parameter `var-topLevelManagementGroupName`.  See the [GitHub Actions](../onboarding/github-actions.md) onboarding guide for instructions to setting up management groups & policy pipeline.

### Custom Policy Definitions

All custom policy definitions are located in [policy/custom/definitions/policy](../../policy/custom/definitions/policy) folder.

Each policy is organized into it's own folder.  The folder name must not have any spaces nor special characters.  Each folder contains 3 files:

1. azurepolicy.config.json - metadata used by GitHub Actions Pipeline to configure the policy.
2. azurepolicy.parameters.json - contains parameters used in the policy.
3. azurepolicy.rules.json - the policy rule definition.

See [step-by-step instructions on Azure Policy Authoring Guide](authoring-guide.md) for more information.

GitHub Actions ([.github/worflows/policy.yml](../../../.github/workflows/3-policy-deploy.yml)) is used for policy definition automation.  The automation enumerates the policy definition directory (`policy/custom/definitions/policy`) and creates/updates policies that it identifies.

**Pipeline Step**

```yml
    - template: templates/steps/define-policy.yml
      parameters:
        description: 'Define Policies'
        workingDir: $(System.DefaultWorkingDirectory)/policy/custom/definitions/policy
```

### Custom Policy Set Definitions

All custom policy set definitions are located in [policy/custom/definitions/policyset](../../policy/custom/definitions/policyset) folder.  Custom policy sets contain built-in and custom policies.

GitHub Actions Pipeline ([.pipelines/policy.yml](../../.pipelines/policy.yml)) is used for policy set definition automation.  Defined policy sets can be customized through pipeline configuration.

**Pipeline Step**

```yml
    - template: templates/steps/define-policyset.yml
      parameters:
        description: 'Define Policy Set'
        deployTemplates: [AKS, DefenderForCloud, LogAnalytics, Network, DNSPrivateEndpoints, Tags]
        deployOperation: ${{ variables['deployOperation'] }}
        policyAssignmentManagementGroupScope: $(var-topLevelManagementGroupName)
        workingDir: $(System.DefaultWorkingDirectory)/policy/custom/definitions/policyset
```

| Policy Set | Description | Deployment Template | Configuration |
| --- | --- | --- | --- |

### Custom Policy Set Assignments

All custom policy set assignments are located in [policy/custom/assignments](../../policy/custom/assignments) folder.

* Deployment templates can be customized for additional policy parameters & role assignments for policy remediation.
* Configuration files are used to define runtime parameters during policy set assignment.  

GitHub Actions Pipeline ([.pipelines/policy.yml](../../.pipelines/policy.yml)) is used for policy set assignment automation.  Assigned policy sets can be customized through pipeline configuration.

**Pipeline Step**
```yml
    - template: templates/steps/assign-policy.yml
      parameters:
        description: 'Assign Policy Set'
        deployTemplates: [AKS, DefenderForCloud, LogAnalytics, Network, Tags]
        deployOperation: ${{ variables['deployOperation'] }}
        policyAssignmentManagementGroupScope: $(var-topLevelManagementGroupName)
        workingDir: $(System.DefaultWorkingDirectory)/policy/custom/assignments
```

| Policy Set | Description | Deployment Template | Configuration |
| --- | --- | --- | --- |

---

## Templated Parameters

Parameters can be templated using the syntax `{{PARAMETER_NAME}}`.  Following parameters are supported:

| Templated Parameter | Source Value | Example |
| --- | --- | --- |
| {{var-topLevelManagementGroupName}} | Environment configuration file such as [config/variables/MLZ-main.yml](../../config/variables/MLZ-main.yml)  | `pubsec`
| {{var-logging-logAnalyticsWorkspaceResourceId}} | Resource ID is inferred using Log Analytics settings in environment configuration file such as [config/variables/MLZ-main.yml](../../config/variables/MLZ-main.yml)  | `/subscriptions/bc0a4f9f-07fa-4284-b1bd-fbad38578d3a/resourcegroups/pubsec-central-logging/providers/microsoft.operationalinsights/workspaces/log-analytics-workspace`
| {{var-logging-logAnalyticsWorkspaceId}} |  Workspace ID is inferred using Log Analytics settings in environment configuration file such as [config/variables/MLZ-main.yml](../../config/variables/MLZ-main.yml) | `fcce3f30-158a-4561-a714-361623f42168`
| {{var-logging-logAnalyticsResourceGroupName}} | Environment configuration file such as [config/variables/MLZ-main.yml](../../config/variables/MLZ-main.yml)  | `pubsec-central-logging`
| {{var-logging-logAnalyticsRetentionInDays}} | Environment configuration file such as [config/variables/MLZ-main.yml](../../config/variables/MLZ-main.yml) | `730`
| {{var-logging-diagnosticSettingsforNetworkSecurityGroupsStoragePrefix}} | Environment configuration file such as [config/variables/MLZ-main.yml](../../config/variables/MLZ-main.yml)  | `pubsecnsg`
| {{var-policyAssignmentManagementGroupId}} | The management group scope for policy assignment. | `pubsec`

---

## Authoring Guide

See [Azure Policy Authoring Guide](authoring-guide.md) for step-by-step instructions.



[nist80053r4Policyset]: https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r4
[nist80053r5Policyset]: https://docs.microsoft.com/azure/governance/policy/samples/nist-sp-800-53-r5
[pbmmPolicyset]: https://docs.microsoft.com/azure/governance/policy/samples/canada-federal-pbmm
[asbPolicySet]: https://docs.microsoft.com/security/benchmark/azure/overview
[cisMicrosoftAzureFoundationPolicySet]: https://docs.microsoft.com/azure/governance/policy/samples/cis-azure-1-3-0
[fedrampmPolicySet]: https://docs.microsoft.com/azure/governance/policy/samples/fedramp-moderate
[hipaaHitrustPolicySet]: https://docs.microsoft.com/azure/governance/policy/samples/hipaa-hitrust-9-2