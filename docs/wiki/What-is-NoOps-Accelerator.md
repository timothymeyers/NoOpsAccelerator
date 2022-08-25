# In this Section

- [In this Section](#in-this-section)
- [Understanding Archetypes](#understanding-archetypes)
- [Policy Governance as Code](#policy-governance-as-code)
- [What is NoOps Accelerator reference implementation?](#what-is-noops-accelerator-reference-implementation)

---

For enterprises to establish their target state for their Azure architecture, NoOps Accelerator offers prescriptive assistance along with Azure best practices. NoOps Accelerator is ultimately determined by the numerous design choices that enterprises must make to define their Azure journey. It will continue to evolve along with the Azure platform roadmap.

The NoOps Accelerator architecture is modular by design and enables organizations of any size to start small and scale in accordance with their business requirements, regardless of scale point. Organizations of any size can start with the foundational hub/spoke landing zone that support their application portfolios.

## Understanding Archetypes

The archetypes in the NoOps Accelerator represent the kinds of architectures that can be created and deployed with this toolset.

Archetypes are self-contained Bicep deployment templates that are used to configure multiple subscriptions. With the use of archetypes, you can easily configure new subscriptions with architecture tailored to a particular use case. The configuration of several subscriptions can be accomplished using a single archetype.

NoOps Accelerator archetypes fall into three categories:

### Enclave Archetype

A enclave archetype describes what needs to be true to ensure a Platform (landing zone) (Azure subscription) and the specificed workload meets the expected environment and compliance requirements at a specific scope.

Examples include:

- Azure Policy assignments.
- Role-based access control (RBAC) assignments.
- Centrally managed resources such as networking.
- Workloads

### Platform Archetype

A Platform (landing zone) archetype describes what needs to be true to ensure a landing zone (Azure subscription) meets the expected environment and compliance requirements at a specific scope.

Examples include:

- Centrally managed resources such as networking, & firewall.

### Workload Archetype

A Workload archetype describes what needs to be true to ensure a Workload (PaaS/IaaS) meets the expected environment and compliance requirements at a specific scope.

Examples include:

- Web Application
- Storage
- Key Vault
- AKS

> Read more on [Archetypes](../wiki/archetypes)

## Policy Governance as Code

The NoOps Accelerator uses Azure Policy to provide guardrails and ensure continued compliance with your organization's platform and the applications deployed onto it. Azure Policy also provides application owners with independence and a secure, unhindered path to the cloud.

A collection of built-in Azure Policy Sets based on Regulatory Compliance are configured with the Azure NoOps Accelerator. To boost compliance for logging, networking, and tagging requirements, custom policy sets have been developed. Depending on what the organization needs, these can be automatedly extended or eliminated.

> Read more on [Policy](../NoOpsAccelerator-Policies.md)

## What is NoOps Accelerator reference implementation?

The NoOps Accelerator reference implementation encourages the adoption of the Azure platform and offer direction and architecture based on the platform's design.

On order to ensure that organizations can design and deploy their landing zones in Azure at scale, NoOps Accelerator reference implementation connect all the Azure platform primitives and produce a tested, well-defined Azure architecture based on a multi-subscription design.
