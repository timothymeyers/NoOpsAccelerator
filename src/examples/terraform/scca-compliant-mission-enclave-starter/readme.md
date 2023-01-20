# SCCA compliant Mission Enclave with Development Team Azure Kubernetes Private Cluster and Shared Services Reference Implementation Guide for Terraform

## Table of Contents

- [Prerequisites](#prerequisites)
- [Planning](#planning)
- [Management Groups](#management-groups)
- [Policy As Code](#policy-as-code)
- [Custom Roles](#custom-roles)
- [Hub Virtual Network](#hub-virtual-network)
- [Spokes Virtual Network](#spokes-virtual-network)
- [User Defined Routes](#user-defined-routes)
- [Network Security Groups](#network-security-groups)
- [Required Routes](#required-routes)
- [Azure Firewall Rules](#azure-firewall-rules)
- [Log Analytics Integration](#log-analytics-integration)
- [Azure Deployment](#azure-deployment)  
  - [Delete Locks](#delete-locks)
  - [Service Health](#service-health)
  - [Subscription Budgets](#subscription-budgets)
  - Deployment Scenarios
    - [Deploying a single environment](#deploying-a-single-environment)
    - [Deploying multiple environments](#deploying-multiple-environments)  
- [Cleanup](#cleanup)
- [Development Setup](#development-setup)
- [See Also](#see-also)

This guide describes how to deploy an Mission Enclave using the [Terraform](https://www.terraform.io/) template at [src/examples/terraform/](../src/examples/terraform/).

To get started with Terraform on Azure check out their [tutorial](https://learn.hashicorp.com/collections/terraform/azure-get-started/).

## Prerequisites

- Current version of the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- The version of the [Terraform CLI](https://www.terraform.io/downloads.html) described in the [.devcontainer Dockerfile](../.devcontainer/Dockerfile)
- An Azure Subscription(s) where you or an identity you manage has `Owner` [RBAC permissions](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)

<!-- markdownlint-disable MD013 -->
> NOTE: Azure Cloud Shell is often our preferred place to deploy from because the AZ CLI and Terraform are already installed. However, sometimes Cloud Shell has different versions of the dependencies from what we have tested and verified, and sometimes there have been bugs in the Terraform Azure RM provider or the AZ CLI that only appear in Cloud Shell. If you are deploying from Azure Cloud Shell and see something unexpected, try the [development container](../.devcontainer) or deploy from your machine using locally installed AZ CLI and Terraform. We welcome all feedback and [contributions](../CONTRIBUTING.md), so if you see something that doesn't make sense, please [create an issue](https://github.com/Azure/missionlz/issues/new/choose) or open a [discussion thread](https://github.com/Azure/missionlz/discussions).
<!-- markdownlint-enable MD013 -->

## Planning

The recommended example implementation achieves the purpose of hosting an Misson Encalve with an Hub/Spoke Landing Zone. It also deploys an Development Team Azure Kubernetes Cluster with a Shared Services Cosmos DB into an Azure Commerical or Azure Government environment (cloud only).  

This is a good starting point for a small to medium sized organizations.  The network design is based on the [Azure Landing Zone](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/) and [Azure Reference Architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/).

The following diagram shows the network topology of the example implementation:

![Network Topology](./images/network-topology.png)

The following diagram shows the resource topology of the example implementation:

![Resource Topology](./images/resource-topology.png)

### One Subscription or Multiple

Mission Enclaves can deploy to a single subscription or multiple subscriptions. A test and evaluation deployment may deploy everything to a single subscription, and a production deployment may place each tier into its own subscription.

#### Single Subscription

If you are deploying to a single subscription, you can use the `single_subscription` variable to deploy all resources to a single subscription.

At `apply` time:

```hcl
terraform apply -var="single_subscription=true"
```

Or, by updating `src/terraform/mlz/variables.tf`:

```hcl
variable "single_subscription" {
  description = "Deploy all resources to a single subscription?"
  type        = bool
  default     = true
}
```

#### Multiple Subscriptions

If you are deploying to multiple subscriptions, you can use the `single_subscription` variable to deploy all resources to a single subscription.

At `apply` time:

```hcl
terraform apply -var="single_subscription=false"
```

Or, by updating `src/terraform/mlz/variables.tf`:

```hcl
variable "single_subscription" {
  description = "Deploy all resources to a single subscription?"
  type        = bool
  default     = false
}
```

### Subscription Naming Conventions

Naming conventions allow consist  The default naming convention for subscriptions is as follows:

- `<org>-<region>-<environment>-<resource>` (e.g. `anoa-eastus-dev-rg`)

#### Modifying the Naming Convention

You can modify this naming convention to suit your needs.

If you would like to modify the naming convention, you can do so by updating the `src/terraform/scca-compliant-mission-enclave-starter/locals.tf` file.

## Management Groups

Organizations can efficiently manage access, governance, and compliance across all subscriptions thanks to management groups. An additional level of scope is offered by Azure management groups over subscriptions. Management groups, which are containers made up of subscriptions, are used to implement Azure Policies and role-based access control to the management groups. The settings made to a management group are automatically applied to all subscriptions within that management group.

Regardless of the kind of subscriptions you may have, management groups allow you enterprise-level management on a broad scale. A management group's single Azure Active Directory tenant must be trusted by all subscriptions within that group.

The following Management Group organizational structure is advised by Azure NoOps Accelerator.Based on the needs of your organization, this can be modified.  

For example, you may want to create a management group for each region, or for each environment.  You may also want to create a management group for each team.  The following diagram shows the management group structure of the example implementation:

![Management Group Structure](./images/management-group-structure.png)

Specifically:

## Policy As Code

Target workloads on Azure that have Unclassified, Secret, and Top Secret categories. These categories are based on NIST SP 800-53 Revision 4, which was derived from ITSG-33.

Azure Policy is used to implement guardrails. Azure Policy supports organizational standards enforcement and at-scale compliance evaluation. With the ability to drill down to the per-resource and per-policy granularity, it offers an aggregated view to assess the overall condition of the environment through its compliance dashboard. Bulk remediation for existing resources and automated remediation for new resources both assist in bringing your resources into compliance.

Implementing governance for resource consistency, legal compliance, security, cost, and management are common use cases for Azure Policy. To assist you in getting started, your Azure environment already has built-in policy definitions for these typical use cases.

The built-in and custom policy definitions are explained in Azure Policy for Guardrails.

### Assigning Azure Policy

This template supports assigning NIST 800-53 policies. See the [policies documentation](./policies.md) for more information.

You can enable this by providing a `true` value to the `create_policy_assignment` variable.

At `apply` time:

```plaintext
terraform apply -var="create_policy_assignment=true"
```

Or, by updating `src/terraform/mlz/variables.tf`:

```terraform
variable "create_policy_assignment" {
  description = "Assign Policy to deployed resources?"
  type        = bool
  default     = true
}
```

## Custom Roles

Custom roles are used to define a set of permissions that can be assigned to users, groups, or service principals. 

Custom roles are scoped to a specific resource group, subscription, or management group.

### Creating Custom Roles

This template supports creating custom roles. See the [custom roles documentation](./custom-roles.md) for more information.

You can enable this by providing a `true` value to the `
create_custom_roles` variable.

At `apply` time:

```plaintext
terraform apply -var="create_custom_roles=true"
```

Or, by updating `src/terraform/mlz/variables.tf`:

```terraform
variable "create_custom_roles" {
  description = "Create custom roles?"
  type        = bool
  default     = true
}
```

## Hub Virtual Network

![Mission Enclave](../media/architecture/misson-enclave/menetwork-design.jpg)

- Cloud network topology based on proven **hub-and-spoke design**.
- Hub contains a single instance of Azure Firewall and Azure Firewall Policy.
- The hub contains a subnet acting as a public access zones (PAZ, using [RFC 6598][rfc6598] space) where service delivery occurs (i.e. web application delivery), either dedicated to line of business workload or as a shared system. When using Azure Application Gateway, this subnet(PAZ) will be reserved for it.
- Hub links to a spoke MRZ Virtual Network (Management Restricted Zone) for management, security, and shared infrastructure purposes (i.e. Domain Controllers, Secure Jumpbox, Software Management, Log Relays, etc.).
- Spokes contains RZ (Restricted Zone) for line of business workloads, including dedicated PAZ (Public Access Zone), App RZ (Restricted Zone), and Data RZ (Data Restricted Zone).
- All ingress traffic traverses the hub's firewall, and all egress to internet routed to the firewall for complete traffic inspection for virtual machines. PaaS and Managed IaaS services will have direct communication with the Azure control plane to avoid asymmetric routing.
- No public IPs allowed in the landing zone spokes for virtual machines. Public IPs for landing zones are only allowed in the external area network (EAN).  Azure Policy is in place to prevent Public IPs from being directly attached to Virtual Machines NICs.
- Spokes have network segmentation and security rules to filter East-West traffic and Spoke-to-Spoke traffic will be denied by default in the firewall.
- Most network operations in the spokes, as well as all operations in the hub, are centrally managed by networking team.
- In this initial design, the hub is in a single region, no BCDR plan yet.

## Spokes Virtual Network

## User Defined Routes

## Network Security Groups

## Required Routes

Required routing rules to enforce the security controls required to protect the workloads by centralizing all network flows through the Hub's firewall.

**Example: Example Route Table**
![ExampleUdr Route Table](../media/architecture/misson-enclave/menetwork-udr.jpg)

| UDR Name | Rules | Applied to | Comments |
| --- | --- | --- | --- |
| HubUdr | `0.0.0.0/0`, `10.18.0.0/16` and `100.60.0.0/16` via Azure Firewall VIP. | All production spoke virtual networks. | Via peering, spokes learn static routes to reach any IP in the Hub. Hence, we override the Hub virtual network's IPs (10.18/16 and 100.60/16) and force traffic via Firewall. |
| OpsUdr | Same as above. | All development spoke virtual networks. | Same as above. |
| SharedServicesUdr | Same as above. | Mrz spoke virtual network  | Same as above. |
| DevTeamSubnetUdr | Same as above. | Force traffic from Application Gateway to be sent via the Firewall VIP | Same as above.
The 0.0.0.0./0 "Next hop type" should be updated as "Internet" and not the Virtual Appliance IP if deploying Azure Application Gateway.. |

## Azure Firewall Rules

Azure Firewall Rules are configured via Azure Firewall Policy.  This allows for firewall rules to be updated without redeploying the Hub Networking elements including Azure Firewall instances.

> Firewall Rule definition is located at [landingzones/lz-platform-connectivity-hub-azfw/azfw-policy/azure-firewall-policy.bicep](../../landingzones/lz-platform-connectivity-hub-azfw/azfw-policy/azure-firewall-policy.bicep)

**Azure Firewall Policy - Rule Collections**
![Azure Firewall Policy - Rule Collections](../media/architecture/hubnetwork-azfw/azfw-policy-rulecollections.jpg)

**Azure Firewall Policy - Network Rules**
![Azure Firewall Policy - Network Rules](../media/architecture/hubnetwork-azfw/azfw-policy-network-rules.jpg)

**Azure Firewall Policy - Application Rules**
![Azure Firewall Policy - Application Rules](../media/architecture/hubnetwork-azfw/azfw-policy-app-rules.jpg)

## Log Analytics Integration

Azure Firewall forwards it's logs to Log Analytics Workspace.  This integration is automatically configured through Azure Policy for Diagnostic Settings.

![Diagnostic Settings](../media/architecture/hubnetwork-azfw/azfw-diagnostic-settings.jpg)

Once Log Analytics Workspace has collected logs, [Azure Monitor Workbook for Azure Firewall](https://docs.microsoft.com/azure/firewall/firewall-workbook) can be used to monitor traffic flows.  

Below are sample queries that can also be used to query Log Analytics Workspace directly.

![Sample DNS Logs](../media/architecture/hubnetwork-azfw/azfw-logs-dns.jpg)

**Sample Firewall Logs Query**

```none
AzureDiagnostics 
| where Category contains "AzureFirewall"
| where msg_s contains "Deny"
| project TimeGenerated, msg_s
| order by TimeGenerated desc
```

![Sample DNS Logs](../media/architecture/hubnetwork-azfw/azfw-logs-fw.jpg)

**Sample DNS Logs Query**

```none
AzureDiagnostics
| where Category == "AzureFirewallDnsProxy"
| where msg_s !contains "NOERROR"
| project TimeGenerated, msg_s
| order by TimeGenerated desc 
```

## Example Spoke: Development Team

### Planning for Workloads

Mission Enclaves allows for deploying one or many workloads that are peered to the hub network. Each workload can be in its own subscription or multiple workloads may be combined into a single subscription.

A separate Terraform template is provided for deploying an empty workload `src/terraform/tier3`. You can use this template as a starting point to create and customize specific workload deployments.

The following parameters affect tier3 networking. To override the defaults edit the variables file at [`src/terraform/tier3/variables.tf`](../src/terraform/tier3/variables.tf).

Parameter name | Default Value | Description
-------------- | ------------- | -----------
`tier3_vnet_address_space` | `["10.0.125.0/26"]` | Address space prefix for tier 3
`tier3_subnets.address_prefixes` | `["10.0.125.0/27"]` | Subnet prefix for tier 3

## Azure Deployment

Mission Enclave can be deployed using the Azure Portal or with command-line tools provided with the AZ CLI or PowerShell.

### Delete Locks

As an administrator, you can lock a subscription, resource group, or resource to prevent other users in your organization from accidentally deleting or modifying critical resources. The lock overrides any permissions the user might have.  You can set the lock level to `CanNotDelete` or `ReadOnly`.  Please see [Azure Docs](https://docs.microsoft.com/azure/azure-resource-manager/management/lock-resources) for more information.

By default, this archetype deploys `CanNotDelete` lock to prevent accidental deletion at:

* Hub Virtual Network resource group
* Management Restricted Zone resource group
* Public Access Zone resource group
* DDoS resource group (when enabled)

### Service Health

[Service health notifications](https://docs.microsoft.com/azure/service-health/service-health-notifications-properties) are published by Azure, and contain information about the resources under your subscription.  Service health notifications can be informational or actionable, depending on the category.

Our examples configure service health alerts for `Security` and `Incident`.  However, these categories can be customized based on your need.  Please review the possible options in [Azure Docs](https://docs.microsoft.com/azure/service-health/service-health-notifications-properties#details-on-service-health-level-information).

### Subscription Budgets

### Deployment Scenarios

#### Deploying a single environment

#### Deploying multiple environments

### Example Deployment Parameters

## Cleanup

## Development Setup

## See Also
