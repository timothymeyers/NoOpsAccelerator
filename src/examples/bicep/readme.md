# Mission Enclaves Examples with Bicep

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Folder structure](#folder-structure)
- [Planning](#planning)
  - [Requirements for Enclaves](#requirements-for-enclaves)
- [Create a new Enclaves](#create-a-new-enclaves)
- [Cleanup](#cleanup)
- [Development Setup](#development-setup)
- [See Also](#see-also)

## Introduction

This folder contains examples of how to use Azure NoOps Accelerator using the [Terraform](https://www.terraform.io/) template at [src/terraform/](../src/terraform/) to deploy Mission Enclaves. These examples are meant to be used as a starting point for your own Terraform deployments. They are not meant to be used as-is in production.

You should always review the code and make any necessary changes to suit your needs. You can also use these examples as a reference for how to use the Terraform modules in this repository.

To get started with Terraform on Azure check out their [tutorial](https://learn.hashicorp.com/collections/terraform/azure-get-started/).

## Prerequisites

- Current version of the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- The version of the [Terraform CLI](https://www.terraform.io/downloads.html) described in the [.devcontainer Dockerfile](../.devcontainer/Dockerfile)
- An Azure Subscription(s) where you or an identity you manage has `Owner` [RBAC permissions](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)

<!-- markdownlint-disable MD013 -->
> NOTE: Azure Cloud Shell is often our preferred place to deploy from because the AZ CLI and Terraform are already installed. However, sometimes Cloud Shell has different versions of the dependencies from what we have tested and verified, and sometimes there have been bugs in the Terraform Azure RM provider or the AZ CLI that only appear in Cloud Shell. If you are deploying from Azure Cloud Shell and see something unexpected, try the [development container](../.devcontainer) or deploy from your machine using locally installed AZ CLI and Terraform. We welcome all feedback and [contributions](../CONTRIBUTING.md), so if you see something that doesn't make sense, please [create an issue](https://github.com/Azure/NoOpsAccelerator/issues/new/choose) or open a [discussion thread](https://github.com/Azure/NoOpsAccelerator/discussions).
<!-- markdownlint-enable MD013 -->

## Folder structure

The folder structure for the Terraform examples is as follows:

```text
examples
```

## Planning

### Requirements for Enclaves

Enclaves must meet the following requirements:

- Enclaves must be self-contained Terraform deployment templates that allows the ability to build new azure resources within an use case specific architecture in a repeatable method.

- Enclaves must be able to be used in a modular fashion to build out a larger enclave architecture.
