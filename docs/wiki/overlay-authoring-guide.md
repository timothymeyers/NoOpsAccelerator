# Overlay Authoring Guide

Azure NoOps Accelerator Overlays are self-contained Bicep deployment templates that allows to extend AzResources services with specific configurations or combine them to create more useful objects. Therefore, deploying an overlay will result in an enahancing a Azure landing zone that can be scaled and refined based on business or deployment need.

The goal of this authoring guide is to provide step-by-step instructions to create new and update existing overlays.

## Table of Contents

- [Overlay Authoring Guide](#overlay-authoring-guide)
  - [Table of Contents](#table-of-contents)
  - [Folder structure](#folder-structure)
  - [Create a new overlays](#create-a-new-overlays)
    - [Build new or reuse existing overlays?](#build-new-or-reuse-existing-overlays)
    - [Requirements for overlays](#requirements-for-overlays)
    - [Approach](#approach)
  - [Update a overlay](#update-a-overlay)
  - [Common features](#common-features)
  
---

## Folder structure

Overlays are located in [`overlays`](../../overlays) folder and organized as folder per overlay.  Here are the current overlays with links to documentation:

- Management Group overlay
  - [`management-groups`](readme.md) - Deploys a management group hierarchy in a tenant under the `Tenant Root Group`.  
- Management Service overlays
  - [`app-service-plan`](readme.md) - configures a subscription for general purpose use.
  - [`applicationGateway`](readme.md) - configures a subscription for healthcare scenarios.
  - [`lz-machinelearning`](readme.md) - configures a subscription for machine learning scenarios.
- Policy overlay
  - [`policy`](readme.md) - Deploys a policy definitions/assignments in a specific `Management Group`.  
- Roles overlay
  - [`roles`](readme.md) - Deploys a role definitions in a specific `Management Group`.  
  
---

## Create a new overlays

Overlays are are self-contained Bicep deployment templates that allows to extend AzResources with specific configurations or combine them to create more useful objects.  Overlays provide the ability to build new azure resources with an use case specific architecture in a repeatable method. One Overlay can be used to configure many different deployment sceniros.

### Build new or reuse existing overlays?

You should develop new overlays when a common deployment need or azure service need emerges within your organization. The return on investment increases when the overlays is used in workloads and deployed to 10s or 100s of subscriptions.

You should start by evaluating the [existing overlays for enhancement opportunities](#update-a-overlay).  New features can be placed behind feature flags to provide customization/choices of Azure services to configure at deployment time.  For example, we use feature flags to control Bastion and VM Instance deployment in the Remote Access - Bastion Overlay.

The `parRemoteAccess.enable` feature flag for Bastion deployment:

```json
 "parRemoteAccess": {
      "value": {
         "enable": true,
          "bastion": {
            // excluded
          }
      }
 }
```

The `parRemoteAccess.linux.enable` feature flag for VM Instance deployment:

```json
"linux": {
   "enable": true,
   "vmName": "bastion-linux",
  }

"windows": {
   "enable": true,
   "vmName": "bastion-windows",
  }
```

### Requirements for overlays

Each overlay is intended to be self-contained and provides all deployment templates required to configure a subscription.  Key requirements for each overlay are:

- overlay folder must contain the overlay name.  For example `app-service-plan`.
- Entrypoint for an overlay is `deploy.bicep`. Every overlay must provide `deploy.bicep` in its respective folder.
- Every overlay must provide `deploy.paramters.json` in its respective parameters folder.
- Deployment must be scoped to `subscription`.  Scope is set in `deploy.bicep` using `targetScope` declaration.

    ```bicep
    targetScope = 'subscription'
    ```

- Implements [common features](#common-features).
- Implements [JSON Schema for deployment JSON parameters](#json-schema-for-deployment-parameters).
- Implements spoke virtual network with support for virtual network peering to Hub Virtual Network.
- Implements Private DNS Zones for private endpoints with support for spoke-managed and hub-managed Private DNS Zones.
- Validated with Azure Firewall for routing & traffic filtering.  Additional Firewall rules may need to be implemented to support control plane & data plane integration.

### Approach

1. Identify at least 5 use cases that can benefit from an archetype and label all common features.  This is the MVP for the archetype.  An application team would receive the implementation of the MVP features deployed in their subscription. Use case specific features can be added to a deployment by the application team as they adapt their environment.

2. Design the spoke virtual network to support the archetype.  You must consider Hub & Spoke network topology, Private Endpoints, Private DNS Zones, Network egress from the spoke virtual network (i.e. to Azure, to on-premises, to Internet)

3. Scaffold the archetype:

      - Create a new folder under `landingzones` prefixed with `lz-`.  For example, `lz-cloudnative`.
      - Create `main.bicep`, set the `targetScope` as `subscription`
      - Create required parameters for [common features](#common-features)
      - Create a test parameters.json and run a subscription scoped deployment through Azure CLI.  You may place the test parameters.json in `/tests/schemas/` based on the archetype.

        ```bash
        az deployment sub create --template-file <path to archetype main.bicep> --parameters @<path to archetype test parameters file> --subscription-id <subscription id> --location canadacentral
        ```

          This is a validation that the archetype scaffolding is in-place.

4. Add [telemetry tracking](#telemetry).

5. Add archetype specific deployment instructions and incrementally verify through test deployment.

6. Create a JSON Schema definition for the archetype.  Consider using a tool such as [JSON to Jsonschema](https://jsonformatter.org/json-to-jsonschema) to generate the initial schema definition that you customize.  For all common features, you must reference the existing definitions for the types. See example: [schemas/latest/landingzones/lz-generic-subscription.json](../../schemas/latest/landingzones/lz-generic-subscription.json)

7. Verify archetype deployment through `subscriptions-ci` Azure DevOps Pipeline.  More information on the pipeline can be found in [Azure DevOps Onboarding Guide](../onboarding/ado.md#step-8--configure-subscription-archetypes).

      - Create a subscription JSON Parameters file per [deployment instructions](#deployment-instructions).
      - Run the pipeline by providing the subscription guid

    `subscriptions-ci` pipeline will automatically identify the archetype, the subscription and region based on the file name.  The JSON Schema is located by the archetype name and used for pre-deployment verification.  

    Once verifications are complete, the pipeline will move the subscription to the target management group (based on the folder structure) and execute `main.bicep`.

8. Debug deployment failures.

    - Navigate to the subscription in Azure Portal
    - Navigate to **Deployments** under **Settings**
    - Identify the failed deployment step & troubleshoot

9. Update documentation.

---

## Update a overlay

It is common to update existing archetypes to evolve and adapt the implementation based on your organization's requirements.

Following changes are required when updating:

- Update archetype deployment template(s) through `main.bicep` or one of its dependent Bicep template(s).
- Update Visio diagrams in `docs\visio` (if required).
- Update documentation in `docs\archetypes` and revise Visio diagram images.
- When parameters are added, updated or removed:
  - Modify JSON Schema
    - Update definitions in `schemas\latest\landingzones`
    - Update changelog in `schemas\latest\readme.md`
    - Update existing unit tests in `tests\schemas`
    - Update existing deployment JSON parameter files to match new schema definition in `config\subscriptions\*.json`.  This is required for compatibility for subscriptions that have already been configured.
  - Unit test
    - Unit tests are based on the scenarios.  Provide only valid scenarios.  These should be added to the appropriate landingzone folder in `tests\schemas`
    - Verify JSON parameter files conform to the updated schema

      ```bash
        cd tests/schemas
        ./run-tests.sh
      ```

  - Documentation
    - Unit tests are treated as deployment scenarios.  Therefore, reference these in the appropriate archetype document in `docs\archetypes` under the **Deployment Scenarios** section.

---

## Common features

An overlay can deploy & configure any number of Azure services.  For consistency across all overlays, We recommend the following common features:

- **Required** - all required fields for the deployment module.
- **Resource Tags** - configures tags on resource groups
- **Target Subscription Id** - configures the overlay target subscription.
- **Target Resource Group** - configures the overlay target resource group for the subscription
- **Subscription Role Assignments to Security Groups** - configures role-based access control at subscription scope
- **Hub Subscription Resource Group** - configures Hub subscription resource group
- **Hub VNet Name** - configures Hub subscription Virtual Netwrok Name.
- **Subscription Tags** - configures subscription tags

> **Log Analytics Workspace integration**: `deploy.bicep` must accept an input parameter named `parLogAnalyticsWorkspaceResourceId`. This parameter is used to link Microsoft Defender for Cloud to Log Analytics Workspace.

> **NOTE:** Some overlays will have some or all common features. This is depending on how the overlay is being used.

Input parameters for common features are:

```bicep
// Log Analytics
@description('Log Analytics Resource Id to integrate Microsoft Defender for Cloud.')
param logAnalyticsWorkspaceResourceId string

// Target Resource Group Name
@description('The name of the resource group in which the overlay will be deployed. If unchanged or not specified, the NoOps Accelerator will create an resource group to be used.')
param parTargetResourceGroup string
  
// Hub Subnet Resource Id
@description('The name of the The Hub Subnet Resource Id')
param parHubSubnetResourceId string

// Hub Virtual Network Name
@description('The Hub Virtual Network Name for the Hub Network.')
param parHubVirtualNetworkName string

// Hub Network Security Group Resource Id
@description('The Hub Network Security Group Resource Id')
param parHubNetworkSecurityGroupResourceId string

@description('Required tags values used with all resources.')
param parTags object

@description('Required values used with all resources.')
param parRequired object
```

These features are packaged into a Bicep module and can be invoked by the overlay (i.e. by `deploy.bicep`).

Example module parameters from `deploy.parameters.json`:

```bicep
// REQUIRED PARAMETERS
"parRequired": {
  "value": {
    "orgPrefix": "anoa",
    "templateVersion": "v1.0",
    "deployEnvironment": "mlz"
  }
}

// REQUIRED TAGS
"parTags": {
  "value": {
    "organization": "anoa",
    "region": "eastus",
    "templateVersion": "v1.0",
    "deployEnvironment": "platforms",
    "deploymentType": "NoOpsBicep"
  }
}
```

---
