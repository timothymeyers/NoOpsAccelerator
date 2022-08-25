# Deploy NoOps Accelerator Reference implementation in your own environment

This section will guide you through the process of deploying an NoOps Accelerator reference implementation in your own environment.

## What is an NoOps Accelerator Reference Implementation?

No matter the size or history of their Azure estate, all customers can utilize the NoOps Accelerator reference implementations. The reference implementations below are designed to address the most typical customer adoption situations for NoOps Accelerator.

## Deploy a Reference Implementation

| Reference implementation | Description |
|:-------------------------|:-------------|
| Hub & Spoke with Azure Firewall (SCCA Compliant Landing Zone) | [Detailed description](./reference/Enclave-Hub-Spoke-WebApp/README.md) |

The idea that "Everything in Azure is a Resource" underpins the NoOps Accelerator reference implementation. To describe and manage their resources as a component of their intended state architecture at scale, all of the reference scenarios make use of the native **Azure Resource Manager (ARM)** & **Bicep**.

By enforcing policies, reference implementations enable security, monitoring, networking, and any other infrastructure required for landing zones (such as subscriptions) independently. Cusotmers will set up the Azure environment using Bicep templates to build the management and networking framework required to specify the intended target state. Using Azure Policy, all scenarios will implement the "Policy Driven Governance" idea for all landing zones. This policy-driven strategy has several advantages, but the following are the most important:

1. Platform can provide an orchestration capability to bring target resources (in this case a subscription) to a desired goal state.

2. Continuous conformance to ensure all platform-level resources are compliant. Because the platform is aware of the goal state, the platform can assist with the monitoring and remediation of resources throughout their life-cycle.

3. Platform enables autonomy regardless of the customer's scale point.

To know and learn more about Bicep templates used for above reference implementation, please follow [this](./Deploy/noops-schema.md) article.
