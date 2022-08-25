# In this Section

- [In this Section](#in-this-section)
- [Requirements for Successful NoOps](#requirements-for-successful-noops)
  - [DevOps Mindset](#devops-mindset)
  - [Roles & Skillsets](#roles--skillsets)
  - [Shared Responsibility Model](#shared-responsibility-model)
  - [Leadership Support](#leadership-support)
- [Separating platform and enclaves](#separating-platform-and-landing-zones)
- [Landing zone owners responsibilities](#landing-zone-owners-responsibilities)
- [NoOps Accelerator Architecture](#noops-accelerator-architecture)
- [What happens when you deploy NoOps Accelerator reference implementation?](#what-happens-when-you-deploy-noops-accelerator-reference-implementation)

------
This section describes how to be successful with the NoOps Accelerator and at a high level how the reference implementation works.

## Requirements for Successful NoOps

NoOps is “not about the elimination of ops; it is about the elimination of manual handoffs and low-value, rote administration.” Think of NoOps is the next evolution of DevOps. We want NoOps Accelerator to drive mission success with an outcome-based approach to deliver continuous value to enable the warfighter.

### DevOps Mindset

Driving the DevOps mindset will prepare your team to handle collaboration, change control and the continuous deployment. Much of this is common to your developers but maybe new to cyber & operations.

### Roles & Skillsets

Roles & Skillsets are critical to success with NoOps. These teams work in close collaboration with the SME functions across the organization:

- Development: capable with modern DevOps practices & tools such as source control (Git), & Continuous Integration/Delivery (CI/CD)

    > In some cases, Development and Platform Teams can share duties

- PlatformOps: Responsible for management and deployment of control plane resource types such as subscriptions, management groups via IaC and the respective CI/CD pipelines. Management of the platform related identify identity resources on Azure AD and cost management for the platform.

     > Operationalization of the Platform for an organization is under the responsibility of the platform function.

- CyberOps: Responsible for definition and management of Azure Policy and RBAC permissions on the platform for landing zones and platform management groups and subscriptions. Security operations including monitoring and the definition and the operation of reporting and auditing dashboard.

- NetOps: Definition and management of the common networking components in Azure including the hybrid connectivity and firewall resource to control internet facing networking traffic. NetOps team is responsible to handout virtual networks to landing zone owners or team.

### Shared Responsibility Model

Even though development, platform, cyber & operations team members have specific roles and responsibilities, it is the collaboration between these four groups that will make NoOps successful.

### Leadership Support

Policy-driven governance is a core tenet of NoOps that requires direct leadership input. Many operations organizations do not have development staff which is necessary for NoOps success therefore leadership should be aware of the potential staffing gap.

## Separating platform and enclaves

One of the key functions of NoOps Accelerator is to have a clear separation of the Enclave and the Platform(landing zones). This allows organizations to scale their Azure architecture alongside with their business requirements, while providing autonomy to their application teams for deploying, migrating and doing net-new development of their workloads into their landing zones. This model fully supports workload autonomy and distinguish between central and federated functions.

## Landing zone owners responsibilities

NoOps Accelerator landing zones supporting a both centralized and federated application DevOps models. Most common model are dedicated **DevOps** team aligned with a single workload. In case of smaller workloads or COTS or 3rd party application a single **AppDevOps** team is responsible for workload operation. Independent of the model every DevOps team manages several workload staging environments (DEV, UAT, PROD) deployed to individual landing zones/subscriptions. Each landing zone has a set of RBAC permissions managed with Azure AD PIM provided by the Platform SecOps team.

When the landing zones/subscriptions are handed over to the DevOps team, the team is end-to-end responsible for the workload. They can independently operate within the security guardrails provided by the platform team. If dependency on central teams or functions are discovered, it is highly recommended to review the process and eliminated as soon as possible to unblock DevOps teams.

## NoOps Accelerator Architecture

The Management Group structure implemented with NoOps Accelerator is as follows:

## What happens when you deploy NoOps Accelerator reference implementation?

By default, all recommended settings and resources recommendations are enabled and deployed, and you must explicitly disable them if you don't want them to be deployed and configured. These resources and configurations include:

- A scalable Management Group hierarchy aligned to core platform capabilities, allowing you to operationalize at scale using centrally managed Azure RBAC and Azure Policy where platform and workloads have clear separation.

- Azure Policies that will enable autonomy for the platform and the landing zones. The full list of policies leveraged by NoOps Accelerator, their intent, assignment scope, and life-cycle can be [viewed here](https://github.com/Azure/NoOpsAccelerator/blob/main/docs/NoOps-Policies.md).
- An Azure subscription dedicated for **Management**, which enables core platform capabilities at scale using Azure Policy such as:

  - A Log Analytics workspace and an Automation account
  - Azure Security Center monitoring
  - Azure Security Center (Standard or Free tier)

  - Azure Sentinel
  - Diagnostics settings for Activity Logs, VMs, and PaaS resources sent to Log Analytics

- When deploying **Misson Landing Zone**: An Azure subscription dedicated for **Transport**, which deploys core Azure networking resources such as:

  - A hub virtual network
  - Azure Firewall
  - Azure Private DNS Zones for Private Link

- (Optionally) An Azure subscription dedicated for **Identity** in case your organization requires to have Active Directory Domain Controllers to provide authorization and authentication for workloads deployed into the landing zones.
- (Optionally) Integrate your Azure environment with GitHub, where you provide the PA Token to create a new repository and automatically discover and merge your deployment into Git.

- Landing Zone Management Group for **Internal** connected applications that require connectivity to on-premises, to other landing zones or to the internet via shared services provided in the hub virtual network.
  - This is where you will create your subscriptions that will host your internal-connected workloads.

  - Landing zone subscriptions for **Internal** connected applications and resources, including a virtual network that will be connected to the hub via VNet peering.
- Azure Policies for internal-connected landing zones, which include:
  - Enforce VM monitoring (Windows & Linux)
  - Enforce VMSS monitoring (Windows & Linux)
  - Enforce Azure Arc VM monitoring (Windows & Linux)
  - Enforce DDoS on Virtual Networks
  - Enforce VM backup (Windows & Linux)
  - Enforce secure access (HTTPS) to storage accounts
  - Enforce auditing for Azure SQL
  - Enforce encryption for Azure SQL
  - Prevent IP forwarding
  - Prevent inbound RDP from internet
  - Ensure subnets are associated with Network Security Groups
  - Ensure subnets are associated with User-Defined routes
