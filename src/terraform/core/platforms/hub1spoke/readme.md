# Hub 1 Spoke Mission Platform Landing Zone Deployment Guide for Terraform

## Table of Contents

- [Prerequisites](#prerequisites)
- [Planning](#planning)
- [Deployment](#deployment)
- [Cleanup](#cleanup)
- [Development Setup](#development-setup)
- [See Also](#see-also)

This guide describes how to deploy Hub 3 Spoke Mission Enclave using the [Terraform](https://www.terraform.io/) template at [src/terraform](../src/terraform).

To get started with Terraform on Azure check out their [tutorial](https://learn.hashicorp.com/collections/terraform/azure-get-started/).

## Prerequisites

- Current version of the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- The version of the [Terraform CLI](https://www.terraform.io/downloads.html) described in the [.devcontainer Dockerfile](../.devcontainer/Dockerfile)
- An Azure Subscription(s) where you or an identity you manage has `Owner` [RBAC permissions](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)

<!-- markdownlint-disable MD013 -->
> NOTE: Azure Cloud Shell is often our preferred place to deploy from because the AZ CLI and Terraform are already installed. However, sometimes Cloud Shell has different versions of the dependencies from what we have tested and verified, and sometimes there have been bugs in the Terraform Azure RM provider or the AZ CLI that only appear in Cloud Shell. If you are deploying from Azure Cloud Shell and see something unexpected, try the [development container](../.devcontainer) or deploy from your machine using locally installed AZ CLI and Terraform. We welcome all feedback and [contributions](../CONTRIBUTING.md), so if you see something that doesn't make sense, please [create an issue](https://github.com/Azure/missionlz/issues/new/choose) or open a [discussion thread](https://github.com/Azure/missionlz/discussions).
<!-- markdownlint-enable MD013 -->

## Planning

### Decide on a Resource Prefix

Resource Groups and resource names are derived from the `resourcePrefix` parameter, which defaults to 'mlz'. Pick a unqiue resource prefix that is 3-10 alphanumeric characters in length without whitespaces.

### One Subscription or Multiple

Mission Envlaves can deploy to a single subscription or multiple subscriptions. A test and evaluation deployment may deploy everything to a single subscription, and a production deployment may place each tier into its own subscription.

The optional parameters related to subscriptions are below. At least one subscription is required.

Parameter name | Default Value | Description
-------------- | ------------- | -----------
`hub_subid` | '' | Subscription ID for the Hub deployment
`tier0_subid` | value of hub_subid | Subscription ID for tier 0
`tier1_subid` | value of hub_subid | Subscription ID for tier 1
`tier2_subid` | value of hub_subid | Subscription ID for tier 2

### Networking

Parameter name | Default Value | Description
-------------- | ------------- | -----------
`hub_vnet_address_space` | `["10.0.100.0/24"]` | The address space to be used for the virtual network
`hub_client_address_space` | `"10.0.100.0/26"` | The address space to be used for the Firewall virtual network
`hub_management_address_space` | `"10.0.100.64/26"` | The address space to be used for the Firewall virtual network subnet used for management traffic
`tier0_vnet_address_space` | `["10.0.110.0/26"]` | VNet prefix for tier 0
`tier0_subnets.address_prefixes` | `["10.0.110.0/27"]` | Subnet prefix for tier 0
`tier1_vnet_address_space` | `["10.0.115.0/26"]` | VNet prefix for tier 1
`tier1_subnets.address_prefixes` | `["10.0.115.0/27"]` | Subnet prefix for tier 1
`tier2_vnet_address_space` | `["10.0.120.0/26"]` | VNet prefix for tier 2
`tier2_subnets.address_prefixes` | `["10.0.120.0/27"]` | Subnet prefix for tier 2

### Optional Features

### Planning for Workloads

## Deployment

### Login to Azure CLI

### Terraform init

### Terraform plan

### Terraform apply

### Deploy with a Service Principal

If you are using a Service Principal to deploy Azure resources with Terraform, [some additional configuration is required](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret/).

Using a Service Principal will require [updating the resource providers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform/) for `mlz/main.tf`.

```terraform
variable "client_secret" {
}

terraform {
  required_providers {
    azurerm = {
      ...
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = var.client_secret
  tenant_id       = "00000000-0000-0000-0000-000000000000"
}
```

### Deploy to Other Clouds

The `azurerm` Terraform provider provides a mechanism for changing the Azure cloud in which to deploy Terraform modules.

If you want to deploy to another cloud, pass in the correct value for `environment`,  `metadata_host`, and `location` for the cloud you're targeting to the relevant module's variables file [mlz/variables.tf](../src/terraform/mlz/variables.tf) or [tier3/variables.tf](../src/terraform/tier3/variables.tf):

```terraform
variable "environment" {
  description = "The Terraform backend environment e.g. public or usgovernment"
  type        = string
  default     = "usgovernment"
}

variable "metadata_host" {
  description = "The metadata host for the Azure Cloud e.g. management.azure.com"
  type        = string
  default     = "management.usgovcloudapi.net"
}

variable "location" {
  description = "The Azure region for most Mission LZ resources"
  type        = string
  default     = "usgovvirginia"
}
```

```terraform
provider "azurerm" {
  features {}

  environment     = var.environment # e.g. 'public' or 'usgovernment'
  metadata_host   = var.metadata_host # e.g. 'management.azure.com' or 'management.usgovcloudapi.net'
}
```

For the supported `environment` values, see this doc: <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#environment/>

For the supported `metadata_host` values, see this doc: <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#metadata_host/>

For more endpoint mappings between AzureCloud and AzureUsGovernment: <https://docs.microsoft.com/en-us/azure/azure-government/compare-azure-government-global-azure#guidance-for-developers/>

### Terraform Providers

The [development container definition](../.devcontainer/Dockerfile) downloads the required Terraform plugin providers during the container build so that the container can be transported to an air-gapped network.

The container sets the `TF_PLUGIN_CACHE_DIR` environment variable, which Terraform uses as the search location for locally installed providers.

If you are not using the [development container](../.devcontainer) to deploy or if the `TF_PLUGIN_CACHE_DIR` environment variable is not set, Terraform will automatically attempt to download the provider from the internet when you execute the `terraform init` command.

See the development container [README](/.devcontainer/README.md) for more details on building and running the container.

### Terraform Backends

The default templates write a state file directly to disk locally to where you are executing terraform from. If you wish to change the output directory you can set the path directly in the terraform backend block located in the main.tf file via the path variable in the backend configuration block.

```terraform
terraform {
  backend "local" {
    path = "relative/path/to/terraform.tfstate"
  }

  required_version = ">= 1.0.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.71.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.7.2"
    }
  }
}
```

To find more information about setting the backend see [Local Backend](https://www.terraform.io/docs/language/settings/backends/local.html),  if you wish to AzureRM backend please see [AzureRM Backend](https://www.terraform.io/docs/language/settings/backends/azurerm.html)

## Cleanup

## Development Setup

For development of the Azure NoOps Accelerator Terraform templates we recommend using the development container because it has the necessary dependencies already installed. To get started follow the [guidance for using the development container](../.devcontainer/README.md).

## See Also

[Terraform](https://www.terraform.io/)

[Terraform Tutorial](https://learn.hashicorp.com/collections/terraform/azure-get-started/)

[Developing in a container](https://code.visualstudio.com/docs/remote/containers) using Visual Studio Code
