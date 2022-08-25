# Azure NoOps Accelerator

## Navigation Menu

* [What's New?](https://github.com/Azure/NoOpsAccelerator/wiki/Whats-new)
* [Community Calls](https://github.com/Azure/NoOpsAccelerator/wiki/Community-Calls)
* [Azure NoOps Accelerator - User Guide](https://github.com/Azure/NoOpsAccelerator/wiki#noops-accelerator-user-guide)
* [NoOps Accelerator - Architecture](./docs/NoOpsAccelerator-Architecture.md)
* [Telemetry Tracking Using Customer Usage Attribution (PID)](https://github.com/Azure/NoOpsAccelerator/wiki/Deploying-NoOps-Accelerator-CustomerUsage)
* [Configure Azure permission for ARM Template deployments](./docs/NoOpsAccelerator-Setup-azure.md)
* [Deploy Reference Implementation](./docs/NoOpsAccelerator-Deploy-reference-implentations.md)
  * [Hub/Spoke with Web App Reference - Scope and Design](./docs/reference/Enclave-Hub-Spoke-WebApp/README.md)  
* [Known Issues](./docs/NoOpsAccelerator-Known-Issues.md)
* [How Do I Contribute?](./docs/NoOpsAccelerator-Contribution.md)
* [Frequently Asked Questions (FAQ)](https://github.com/Azure/NoOpsAccelerator/wiki/FAQ)
* [Roadmap](./docs/NoOpsAccelerator-Roadmap.md)
* [Microsoft Support Policy](./SUPPORT.md)

NoOps Accelerator is an reference implementation to guide DOD/Public Sector customers on building self-service infrastucture in their Azure environment. The reference implementation is a flexible foundation that enables users to develop/maintain an opinionated self-service infrastructure. These templates are created to help organizations move to a continious deployment of self-healing infrastructure.

NoOps Accelerator Architecture supported up to IL6 (Top Secret) - Cloud Only Applications. This reference implementation is applicable to Infrastructure as a Service (IaaS) and Platform as a Service (PaaS) with characteristics:

* Cloud-based services hosting sensitive (up to IL6 (Top Secret)) information
* No direct system to system network interconnections required with data centers

This implementation is specific to DOD/Public Sector organizations.

## Goals

* Designed for US Government mission customers
* Implements SCCA controls following Microsoft's SACA implementation guidance
* Deployable in Azure commercial, Azure Government, Azure Government Secret, and Azure Government Top Secret clouds
* Accelerate the use of Azure in DOD/Public Sector through onboarding multiple types of workloads including App Dev and Data & AI.
* Simplify compliance management through a single source of compliance, audit reporting and auto remediation.
* Deployment of DevOps frameworks & business processes to improve agility
* Written as Bicep and Terraform templates

## Non-Goals

* Automatic approval for Authority to Operate (ATO). Customers must collect evidence, customize to meet their departmental requirements and submit for Authority to Operate based on their risk profile, requirements and process.

* Compliant on all Azure Policies when the reference implementation is deployed. This is due to the shared responsibility of cloud and customers can choose the Azure Policies to exclude. For example, using Azure Firewall is an Azure Policy that will be non-compliant since majority of the DOD/Public Sector customers use Network Virtual Appliances. Customers must review Microsoft Defender for Cloud Regulatory Compliance dashboard and apply appropriate exemptions.

## How We Define `NoOps` for this Project

NoOps is “not about the elimination of ops; it is about the elimination of manual handoffs and low-value, rote administration.” Think of NoOps is the next evolution of DevOps. We want NoOps Accelerator to drive mission success with an outcome-based approach to deliver continuous value to enable the warfighter.

## Requirements for Successful NoOps

### Tenets of NoOps

1. Streamline End-to-End Platform/Workload Automation.
2. Automate Security & Governance at Scale
3. Continuous Real Time Observability, Telemetry, and Monitoring.
4. Process and Automation is Top Priority.

### DevOps Mindset

Driving the DevOps mindset will prepare your team to handle collaboration, change control and the continuous deployment. Much of this is common to your developers but maybe new to cyber & operations.

### Roles & Skillsets

To have success with NoOps, you will need:

* Development staff that is capable with modern DevOps practices & tools such as source control (Git), & Continuous Integration/Delivery (CI/CD).

* Cyber Security Staff would take ownership of policy-oriented development in coordination with the Development staff.

* Operations staff to define architecture that meets the policy needs which is coded by the Development staff.

### Shared Responsibility Model

Even though development, cyber & operations team members have specific roles and responsibilities, it is the collaboration between these three groups that will make NoOps successful.

### Leadership Support

Policy-driven governance is a core tenet of NoOps that requires direct leadership input. Many operations organizations do not have development staff which is necessary for NoOps success therefore leadership should be aware of the potential staffing gap.

## What are we solving for with the NoOps Accelerator?

### Mission Outcome Success

All in one solution that takes the best practices from Mission Landing Zone architecture and creates a full ATO compliant enclave.

### Security & Governance at Scale

Policy-Driven guardrails using in-band and out-of-band polices ensure that deployed workloads and applications are compliant with your command’s cyber-security and compliance requirements, and therefore a securing a path on driving mission outcomes. Policy-driven governance is one of the key design principles of this accelerator.

### Streamlined End-to-End Platform/Workload Automation

Using pre-configured templates and policy-driven resources where core systems administration tasks are fully automated allows developers to focus on driving mission outcomes.

## Architecture

See [architecture documentation](docs/NoOpsAccelerator-Architecture.md) for detailed walkthrough of design.

Deployment to Azure is supported using GitHub Actions and can be adopted for other automated deployment systems like Gitlab, Jenkins, etc.

The automation is built with Azure Bicep and Azure Resource Manager template.

## Onboarding to GitHub Actions

See the following onboarding guides for setup instructions:

* GitHub Actions Setup provides guidance on considerations and recommended practices when creating and configuring your GitHub environment.
* GitHub Actions Scripts provides guidance on the scripts available to help simplify the onboarding process to Azure Landing Zones design using GitHub Actions.
* GitHub Actions provides guidance on the manual steps for onboarding to the Azure Landing Zones design using GitHub Actions.

## SCCA Compliant Hub/Spoke Design(Referred as Mission Landing Zone)

NoOps Accelerator can be used to create a SCCA Compliant Hub/Spoke Design(Referred as Mission Landing Zone) based on the [Azure Mission Landing Zone Conceptual Architecture][mlz_architecture].

The [NoOps Accelerator - SCCA Compliant Hub/Spoke Design(Referred as Mission Landing Zone)](src/bicep/platforms/lz-platform-scca-hub-3spoke/) is set up in a hub and spoke design with Logging, separated by tiers: T0 (Identity and Authorization), T1 (Infrastructure Operations), T2 (DevSecOps and Shared Services), and multiple T3s (Workloads).

Access control can be configured to allow separation of duties between all tiers.

## Bicep Modules

In the [src\bicep](src/bicep) directory contains all of the modules required to deploy NoOps Accelerator components.

## Terraform Modules

> NOTE: Currently Terraform modules are not complete. We are working on the Bicep modules first, as this is native to Azure ARM.

In the [src\terraform](src/terraform) directory contains all of the modules required to deploy NoOps Accelerator components.

This is still a work in progress. We wanted to concentrate on the bicep modules first as there is native support in Azure.

## Self-Service Website

>NOTE: This is still a work in progress.

## Telemetry

>NOTE: The NoOps Accelerator does not collect any telemetry at this time. We are looking to use this feature in the future. Project Bicep [collects telemetry in some scenarios](https://github.com/Azure/bicep/blob/main/README.md#telemetry) as part of improving the product.

## Product Roadmap

See the Projects page for the release timeline and feature areas.

Here's a summary of what NoOps Accelerator deploys of as of December 2021:

image

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit <https://cla.opensource.microsoft.com>.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Feedback, Support, and How to Contact Us

Please see the [Support and Feedback Guide](https://github.com/Azure/NoOpsAccelerator/blob/update-repo/SUPPORT.md). To report a security issue please see our [security guidance](https://github.com/Azure/NoOpsAccelerator/blob/update-repo/SECURITY.md).

## This project is influenced by

* [Common Azure Resource Modules Library](aka.ms/carml)
* [Azure Landing Zones for Canadian Public Sector](https://github.com/azure/canadapubsecalz)
* [Mission Landing Zone](https://github.com/Azure/missionlz)
* [Enterprise Scale](https://github.com/Azure/Enterprise-Scale)

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.

[//]: # (************************)
 [//]: # (INSERT LINK LABELS BELOW)
 [//]: # (************************)

[mlz_architecture]:                            https://github.com/Azure/missionlz "MLZ Accelerator"
[wiki_deployment_flow]:                        https://github.com/Azure/NoOpsStarter/wiki/DeploymentFlow "Wiki - Deployment Flow"
