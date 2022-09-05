# NoOps Accelerator - Bicep Modules

This directory contains all of the modules required to deploy NoOps Accelerator components.

Checkout the [Getting Started](#getting-started) section below for details on where to start, pre-requisites and more.

## Getting Started

To get started with NoOps Accelerator Bicep modules, please refer to the [Architecture wiki page](../../docs/NoOpsAccelerator-Architecture.md) for:

1. Prerequisites and dependencies for the overall reference implementation.
2. High-level deployment flow.
3. Links to more detailed instructions on individual modules.

## Azresources Folder

AzResources folder is the backbone of the NoOps Accelerator.

This folder provides Bicep modules which can be leveraged in your NoOps infrastructure as code projects to accelerate solution development.

The primary aim of AzResources is to provide you with re-usable building blocks, so that you can focus what matter the most.

AzResources are broken into 3 folders:

- Hub/Spoke Core
- Modules
- Policy

## Enclave folder

The Enclave Archetype directory allows you to create core modules to depoyment of an enclave.

>Example deployments can be an AKS if used with Hub/ 1 Spoke.

## Overlays folder

The Overlays directory are to show how to add on functionality of Enclaves, Platform and Workload Archtypes.

| Overlay | Description |
| ------- | ----------- |
| [Management Groups](./overlays/management-groups/readme.md) | NoOps Accelerator management groups overlay are templates that may be installed to add custom management groups to an new or existing landing zone or enclave. |
| [Management Services](./overlays/management-services/readme.md) | An established landing zone or enclave can be expanded functionally by adding custom management services using the NoOps Accelerator management services overlay templates. |
| [Policy](./overlays/policy/readme.md) | Based on your Azure Service Catalog, NoOps Accelerator - Azure Policy Initiatives deploys Azure Policy Initiatives, Definitions, and Assignments to a specific Management Group in the Tenant Root. |
| [RBAC (Role Access)](./overlays/roles/readme.md) | NoOps Accelerator RBAC services are templates that can be deployed to extend an existing landing zone or enclave. |

You [must first deploy landing zone or enclave](../../docs/wiki/archetypes/Platform/authoring-guide.md), then you can deploy these overlays.

## Platform folder

The Platform Archetype directory allows you to create core modules that will depoyment of a custom landing zone. These modules are used with other modules.

>Example deployments can be an Mission Landing Zone if used with Hub/ 3 Spoke.

## Workloads folder

The Workloads Archetype directory allows you to create core modules that will depoyment of a custom workloads. These modules are used with other modules.

>Example deployments can be an Storage Account to a Shared Services Spoke if used with Hub/ 3 Spoke.

You [must first deploy landing zone or enclave](../../docs/wiki/archetypes/Platform/authoring-guide.md), then you can deploy these workloads.

## References

* [Hub and Spoke network topology](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
* [Secure Cloud Computing Architecture (SCCA) Functional Requirements Document (FRD)](https://rmf.org/wp-content/uploads/2018/05/SCCA_FRD_v2-9.pdf)

 [//]: # (************************)
 [//]: # (INSERT LINK LABELS BELOW)
 [//]: # (************************)

[mlz_architecture]:                            https://github.com/Azure/missionlz "MLZ Accelerator"
[wiki_deployment_flow]:                        https://github.com/https://github.com/Azure/NoOpsAccelerator/wiki/DeploymentFlow "Wiki - Deployment Flow"
