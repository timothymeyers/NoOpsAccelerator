# SCCA compliant Hub Spoke with Azure Kubernetes Private Cluster Deployment Guide for Terraform

## Table of Contents

- [Prerequisites](#prerequisites)
- [Planning](#planning)
- [Management Groups](#management-groups)
- [Policy As Code](#policy-as-code)
- [Custom Roles](#custom-roles)
- [Hub Virtual Network](#hub-virtual-network)
- [Spokes Virtual Network](#management-restricted-zone-virtual-network)
- [User Defined Routes](#user-defined-routes)
- [Network Security Groups](#network-security-groups)
- [Required Routes](#required-routes)
- [Azure Firewall Rules](#azure-firewall-rules)
- [Log Analytics Integration](#log-analytics-integration)
- [Azure Deployment](#azure-deployment)  
  - [Delete Locks](#delete-locks)
  - [Service Health](#service-health)
  - Deployment Scenarios
    - [Deploying a single environment](#deploying-a-single-environment)
    - [Deploying multiple environments](#deploying-multiple-environments)    
  - Example Deployment Parameters
    - [Deploying a single environment](#deploying-a-single-environment-1)
    - [Deploying multiple environments](#deploying-multiple-environments-1)
- [Cleanup](#cleanup)
- [Development Setup](#development-setup)
- [See Also](#see-also)

This guide describes how to deploy Mission Landing Zone using the [Terraform](https://www.terraform.io/) template at [src/terraform/mlz](../src/terraform/mlz).

To get started with Terraform on Azure check out their [tutorial](https://learn.hashicorp.com/collections/terraform/azure-get-started/).

## Prerequisites

- Current version of the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- The version of the [Terraform CLI](https://www.terraform.io/downloads.html) described in the [.devcontainer Dockerfile](../.devcontainer/Dockerfile)
- An Azure Subscription(s) where you or an identity you manage has `Owner` [RBAC permissions](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)

<!-- markdownlint-disable MD013 -->
> NOTE: Azure Cloud Shell is often our preferred place to deploy from because the AZ CLI and Terraform are already installed. However, sometimes Cloud Shell has different versions of the dependencies from what we have tested and verified, and sometimes there have been bugs in the Terraform Azure RM provider or the AZ CLI that only appear in Cloud Shell. If you are deploying from Azure Cloud Shell and see something unexpected, try the [development container](../.devcontainer) or deploy from your machine using locally installed AZ CLI and Terraform. We welcome all feedback and [contributions](../CONTRIBUTING.md), so if you see something that doesn't make sense, please [create an issue](https://github.com/Azure/missionlz/issues/new/choose) or open a [discussion thread](https://github.com/Azure/missionlz/discussions).
<!-- markdownlint-enable MD013 -->

## Planning

The recommended network design achieves the purpose of hosting (cloud only).  This is a simplified network design given all ingress and egress traffic will traverse through the same VIP.

![Hub Spoke Networking with Azure Firewall](../media/architecture/hubnetwork-azfw/hubnetwork-azfw-design.jpg)

* Cloud network topology based on proven **hub-and-spoke design**.

## Management Groups

## Policy As Code

## Custom Roles

## Hub Virtual Network

## Spokes Virtual Network

## User Defined Routes

## Network Security Groups

## Required Routes

## Azure Firewall Rules

## Log Analytics Integration

## Azure Deployment

### Delete Locks

### Service Health

### Deployment Scenarios

#### Deploying a single environment

#### Deploying multiple environments

### Example Deployment Parameters

## Cleanup

## Development Setup

## See Also


