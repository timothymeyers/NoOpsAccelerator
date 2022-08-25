# NoOps Accelerator - Bicep Modules

This directory contains all of the modules required to deploy NoOps Accelerator components.

Checkout the [Getting Started](#getting-started) section below for details on where to start, pre-requisites and more.

## Getting Started

To get started with NoOps Accelerator Bicep modules, please refer to the [Architecture wiki page](../../docs/NoOpsAccelerator-Architecture.md) for:

1. Prerequisites and dependencies for the overall implementation.
2. High-level deployment flow.
3. Links to more detailed instructions on individual modules.

## Azresources Folder

This folder houses the standard resource module deployments to be consumed by the '.bicep' files within the landing zone or enclave folders.

## Enclave folder

The Enclave Archetype directory has base core modules that will allow the depoyment an enclave. These modules are used on other modules.

## Overlays folder

The Overlays directory are to show how to add on functionality of Enclaves, Platform and Workload Archtypes.

| Overlay | Description |
| ------- | ----------- |
| [Management Groups](./overlays/management-groups/readme.md) | NoOps Accelerator management groups are templates that can be deployed to extend an existing landing zone or enclave. |
| [Management Services](./overlays/management-services/readme.md) | NoOps Accelerator management services are templates that can be deployed to extend an existing landing zone or enclave. |
| [Policy](./overlays/policy/readme.md) | NoOps Accelerator - Azure Policy Initiatives deploys Azure Policy Initiatives, Definitions & Assignments to a specified Management Groups in the Tenant Root based on your Azure Service Catalog. |
| [RBAC (Role Access)](./overlays/roles/readme.md) | NoOps Accelerator RBAC services are templates that can be deployed to extend an existing landing zone or enclave. |

You [must first deploy landing zone or enclave](../../docs/wiki/archetypes/Platform/authoring-guide.md), then you can deploy these overlays.

## Platform folder

The Platform Archetype directory has base core modules that will allow the depoyment of a landing zone. These modules are used on other modules.

>Example deployments are Mission Landing Zone.

## Workloads folder

The Examples directory are to show how to extend functionality of NoOps Accelerator.

You [must first deploy landing zone or enclave](../../docs/wiki/archetypes/Platform/authoring-guide.md), then you can deploy these workloads.

## Tests folder

## References

* [Hub and Spoke network topology](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
* [Secure Cloud Computing Architecture (SCCA) Functional Requirements Document (FRD)](https://rmf.org/wp-content/uploads/2018/05/SCCA_FRD_v2-9.pdf)

 [//]: # (************************)
 [//]: # (INSERT LINK LABELS BELOW)
 [//]: # (************************)

[mlz_architecture]:                            https://github.com/Azure/missionlz "MLZ Accelerator"
[wiki_deployment_flow]:                        https://github.com/https://github.com/Azure/NoOpsAccelerator/wiki/DeploymentFlow "Wiki - Deployment Flow"
