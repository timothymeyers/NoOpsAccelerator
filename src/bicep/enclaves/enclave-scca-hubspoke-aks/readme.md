# NoOps Accelerator - Enclave - SCCA Compliant Hub - 1 Spoke landing zone with a Azure Kubernetes Service

> **IMPORTANT: This is currenly work in progress.**

## Overview

This enclave module deploys Platform Hub - 1 Spoke landing zone with a Azure Kubernetes Service workload.

> NOTE: When deploying enclaves; Management Groups, Policy and Roles need to be deployed first. Please review the Pre-requisites for more information.

Read on to understand what this enclave does, and when you're ready, collect all of the pre-requisites, then deploy the enclave.

## Architecture

 ![Enclave Hub/Spoke landing zone with a Azure Kubernetes Service Architecture](../../../bicep/)

## About Hub 1 Spoke Landing Zone

The docs on Hub/Spoke Landing Zone: <https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli>

## About Azure Kubernetes Service - Private Cluster

The docs on Azure Kubernetes Service: <https://docs.microsoft.com/en-us/azure/aks/>. This workload uses the Azure Kubernetes Service - Cluster workload to deploy resources into [Platform Hub 1 Spoke Network](../../../bicep/platforms/lz-platform-scca-hub-1spoke/readme.md).  

### Subscriptions

Most customers will deploy each tier to a separate Azure subscription, but multiple subscriptions are not required. A single subscription deployment is good for a testing and evaluation, or possibly a small IT Admin team.

### Management Groups

The Enclave Management Groups module deploys a management group hierarchy in a tenant under the `Tenant Root Group`.  This is accomplished through a tenant-scoped Azure Resource Manager (ARM) deployment.  The heirarchy can be modifed by editing `deploy.parameters.json`.

Azure NoOps Accelerator recommends the following Management Group structure. This structure can be customized based on your organization's requirements.

>Management Group structure can be deployed or modified through [Azure Bicep template located in "management-groups" folder](../../overlays/management-groups)

The hierarchy created by the deployment (`deploy.parameters.json`) is:

![Enclave Hub/Spoke landing zone with a Azure Kubernetes Service Architecture](./media/MgmtGroups_Policies_v0.1.jpg)

```bash
# For Azure Commerical regions
az deployment mg create \
   --template-file overlays/management-groups/deploy.bicep \
   --parameters @overlays/management-groups/deploy.parameters.json \
   --location 'eastus'
```

```bash
# For Azure Government regions
az deployment mg create \
  --template-file overlays/management-groups/deploy.bicep \
  --parameters @overlays/management-groups/deploy.parameters.json \
  --location 'usgovvirginia'
```

### Policy - Security Controls

[Azure Policy](https://docs.microsoft.com/azure/governance/policy/overview) is used to deploy guardrails for your environment. Azure Policy supports organizational standards enforcement and at-scale compliance evaluation.

Implementing governance for resource consistency, legal compliance, security, cost, and management are common use cases for Azure Policy. To assist you in getting started, your Azure environment already has built-in policy definitions for these typical use cases.

A collection of built-in Azure Policy Sets based on Regulatory Compliance are configured with Azure NoOps Accelerator. To boost compliance for logging, networking, and tagging requirements, custom policy sets have been developed. Through automation, these can be further expanded or eliminated as needed by the department.

> Policy structure can be deployed or modified through [Azure Bicep template located in "policy" folder](../../overlays/policy)

```bash
# For Azure Commerical regions
az deployment mg create \
   --template-file overlays/policy/deploy.bicep \
   --parameters @overlays/policy/deploy.parameters.json \
   --location 'eastus'
```

```bash
# For Azure Government regions
az deployment mg create \
  --template-file overlays/management-groups/deploy.bicep \
  --parameters @overlays/management-groups/deploy.parameters.json \
  --location 'usgovvirginia'
```

### RBAC - Roles


See below for information on how to use the appropriate deployment parameters for use with this landing zone:

Required Parameters | Type | Allowed Values | Description
| :-- | :-- | :-- | :-- |
parRequired | object | {object} | Required values used with all resources.
parTags | object | {object} | Required tags values used with all resources.
parLocation | string | `[deployment().location]` | The region to deploy resources into. It defaults to the deployment location.
parHub | object | {object} | Hub Virtual network configuration. See [azresources/hub-spoke-core/vdss/hub/readme.md](../../azresources/hub-spoke-core/vdss/hub/readme.md)
parOperationsSpoke | object | {object} | Operations Spoke Virtual network configuration. See [See azresources/hub-spoke-core/vdms/operations/readme.md](../../azresources/hub-spoke-core/vdms/operations/readme.md)
parAzureFirewall | object | {object} | Azure Firewall configuration. Azure Firewall is deployed in Forced Tunneling mode where a route table must be added as the next hop.
parLogging | object | {object} | Enables logging parmeters and Microsoft Sentinel within the Log Analytics Workspace created in this deployment.
parRemoteAccess | object | {object} | When set to "true", provisions Azure Bastion Host. It defaults to "false".

Optional Parameters | Type | Allowed Values | Description
| :-- | :-- | :-- | :-- |
parNetworkArtifacts | object | {object} | Optional. Enables Operations Network Artifacts Resource Group with KV and Storage account for the ops subscriptions used in the deployment.
parSecurityCenter | object | {object} | Microsoft Defender for Cloud.  It includes email and phone.
parDdosStandard | bool | `false` | DDOS Standard configuration.