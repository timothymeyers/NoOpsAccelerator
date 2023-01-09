# Terraform Overlays (Hub/Spoke Core) Folders

## Overview

Azure NoOps Accelerator Landing Zone Core (Hub/Spoke) is based on the recommendations from the [Azure Mission Landing Zone Conceptual Architecture](https://github.com/Azure/missionlz).

> All spokes name can be changed.

These modules deploy the following resources:

* Hub Virtual Network (VNet)  
* Spoke
  * Identity (Tier 0)
  * Operations (Tier 1)
  * Shared Services (Tier 2)
* Logging
  * Azure Log Analytics Workspaces
    * Azure Log Analytics Solutions
* Operations Network Artifacts (Optional)
* Azure Firewall
* Network peerings
* Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> [https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration)

## Hub Spoke Core Folder

Hub/ Spoke Core is the basis on creating a modular Hub/Spoke network designs. This core is used in Platform Landing Zone creations. Each module in the core is designed to be deploy together or individually.

## Hub Spoke Core Folder Structure

The Hub Spoke Core folder structure is as follows:

```bash
├───📂hub-spoke-core
│   ├───📂peering
│   │   ├───main.tf
│   │   ├───outputs.tf
│   │   └───variables.tf
│   ├───📂vdms
|   |   ├───📂dataSharedServices
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
|   |   ├───📂logging
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
|   |   ├───📂operations
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
|   |   ├───📂sharedServices
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
│   ├───📂vdss
|   |   ├───📂firewall
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
|   |   ├───📂hub
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
|   |   ├───📂identity
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
|   |   ├───📂networkArtifacts
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
└───readme.md
```

## Hub Spoke Core Modules

The Hub Spoke Core modules are as follows:

### Peering

The peering module is used to create a peering between the hub and spoke virtual networks.

### VDMS/VDSS

The VDMS module is used to create a virtual network with the following resources:

* Virtual Network
* Subnets
* Network Security Groups
* Network Security Group Rules
* Route Tables
* Route Table Routes
* Virtual Network Peering