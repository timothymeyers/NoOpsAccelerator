# Workload Archetype Authoring Guide

[Azure landing zones](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/) are the output of a multi-subscription Azure environment that accounts for scale, security governance, networking, and identity. Therefore, deploying an archetype will result in an Azure landing zone that can be enhanced, scaled and refined based on business need.

This reference implementation provides a number of archetypes that can be used as-is or customized further to suit business needs.  Archetypes are self-contained Bicep deployment templates that are used to configure multiple subscriptions.  Archetypes provide the ability to configure new subscriptions with use case specific architecture in a repeatable method. One archetype can be used to configure many subscriptions.

This implementation provides two types of archetypes:  Workload archetypes & Platform archetypes.  Workload archetypes are used to configure subscriptions for line of business use cases such as Machine Learning & Healthcare.  Platform archetypes are used to configure shared infrastructure such as Logging, Hub Networking and Firewalls.  Intent of the archetypes is to **provide a repeatable method** for configuring subscriptions.  It offers a **consistent deployment experience and supports common scenarios** required by your organization.

When there are new capabilities or Azure services to add, consider evolving an existing archetypes through **feature flags**.  Once an archetype is deployed, the application teams can further modify the deployment for scale or new capabilities using their preferred deployment tools.

The goal of this authoring guide is to provide step-by-step instructions to create new and update existing archetypes.

## Table of Contents

- [Folder structure](#folder-structure)
- [Create a new Workload archetype](#create-a-workload-archetype)
  - [Build new or reuse existing archetypes?](#build-new-or-reuse-existing-archetypes)
  - [Requirements for archetypes](#requirements-for-archetypes)
  - [Approach](#approach)
- [Update a Workload archetype](#update-a-workload-archetype)
- [Common features](#common-features)
- [JSON Schema for deployment parameters](#json-schema-for-deployment-parameters)
- [Telemetry](#telemetry)
- [Deployment instructions](#deployment-instructions)

---

## Folder structure

Workload Archetypes are located in [`workloads`](../../workloads) folder and organized as folder per archetype.  Here are the current archetypes with links to documentation:

- Workload archetypes
  - [`lz-platform-mlz`](hubnetwork-azfw.md) - configures a Mission Landing Zone.
  - [`lz-platform-etmn`](hubnetwork-nva-fortigate.md) - configures a Enterprise Tactical Misson Network.

---

## Create a new Workload archetype

Archetypes are self-contained Bicep deployment templates that are used to configure multiple subscriptions.  Archetypes provide the ability to configure new subscriptions with use case specific architecture in a repeatable method. One archetype can be used to configure many subscriptions.