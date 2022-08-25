# Self-service infrastucture using NoOps Accelerator

The purpose of the reference implementation is to guide DOD/Public Sector customers on building self-service infrastucture in their Azure environment. The reference implementation is a flexible foundation that enables users to develop/maintain an opinionated self-service infrastructure.

NoOps Accelerator Architecture supported up to IL6 (Top Secret) - Cloud Only Applications. This profile is applicable to Infrastructure as a Service (IaaS) and Platform as a Service (PaaS) with characteristics:

* Cloud-based services hosting sensitive (up to IL6 (Top Secret)) information
* No direct system to system network interconnections required with data centers

This implementation is specific to DOD/Public Sector organizations and is based off the [Azure Mission Landing Zone Conceptual Architecure](https://github.com/Azure/missionlz).

---

## Table of Contents

1. [Key Decisions](\#1-key-decisions)
2. [Security Controls](\#2-security-controls)
3. [Management Groups](\#3-management-groups)
4. [Identity (RBAC)](\#4-identity)
5. [Landing Zones](\#5-landing-zones)
6. [Logging](\#6-logging)
7. [Tagging](\#7-tagging)
8. [Archetypes (Enclave/Platform/Workload)](\#8-archetypes)
9. [Automation](\#9-automation)

---

## 1. Key Decisions

The table below outlines the key decisions each organization must consider as part of adopting Azure.  This list is provided to help guide and is not meant to be exhaustive.

| Topic |  Scenario | Ownership | Complexity to change | Decision |
| --- | --- | --- | --- | --- |
| Private IP range for Cloud | Based on [RFC 1918][rfc1918] and [RFC 6598][rfc6598], to allow seamless routing for hybrid connectivity. | | | |
| Ground to Cloud Network Connectivity | Use either: Express Route; or SCED for hybrid connectivity. | | | |
| Firewalls | Central firewalls for all egress and non-HTTP/S ingress traffic to VMs. | | | |
| Spoke Network Segmentation | Subnet Addressing & Network Security Groups. | | | |
| Application Gateway + WAF | Application Gateway per spoke subscription to allow direct delivery for HTTP/S traffic.  WAF and routing rules are managed by CloudOps.  | | | |
| Security Incident & Monitoring | Centralized security monitoring. | | | |
| Logging (IaaS & PaaS) | Centralized Log Analytics Workspace with RBAC permissions to allow resource owners to access resource logs & Security Monitor to access all logs. | | | |
| RBAC / IAM | Roles, security groups and access control for management groups, subscriptions & resource groups. | | | |
| Service Principals (App Registration) | Service Principals are required for automation and will require elevated permissions for role assignments. | | | |
| VM Patching | Centralized Patch Management with either Azure native tools or non-Azure solutions. | | | |
| Tag Governance | Tags that are required on all subscriptions, resource groups and resources to provide resource aggregation for reporting and cost management. | | | |

---

## 2. Security Controls

NoOps Accelerator allows organizations to target workloads with **Unclassified**, **Secret** and **Top Secret** data classifications in Azure.  These classifications are based on [DCMA Manual 3301-08][DCMA Manual 3301-08] which is derived from [NIST SP 800-53 Revision 4][nist80053R4].

### 2.1 Scope - Building a Culture of Continuous Governance

Organizations that foster a culture of continuous governance that allows varied teams to self-serve "-aaS" (SaaS, PaaS, and IaaS) products. Continuous governance strikes a balance between the requirement to swiftly deploy new workloads to the cloud and the need to keep the organization secure.

As a organizations matures in its cloud adoption, Organizations should implement in-band and out-of-band guidelines and guardrails in a progressive fashion that builds on established best practices and constant learning.

Azure's [Azure Policy](https://docs.microsoft.com/azure/governance/policy/overview) is used to deploy guidelines and guardrails. Azure Policy supports organizational standards enforcement and at-scale compliance evaluation. With the ability to drill down to the per-resource and per-policy granularity, it offers an aggregated view to assess the overall condition of the environment through its compliance dashboard. Bulk remediation for existing resources and automated remediation for new resources both assist in bringing your resources into compliance.

Implementing continuous governance for resource consistency, legal compliance, security, cost, and management are common use cases for Azure Policy. To assist you in getting started, your Azure environment already has built-in policy definitions for these typical use cases.

### 2.2 Guidelines and Guardrails for efficient Cloud Operations

In addition to in-band vs out-of-band detection, there are two primary ways that companies take action on governance policies:

#### 2.2.1 Guidelines

Guideline policies will communicate a risk boundary that informs the user of the best practice but will not take action to prevent or correct the action.

#### 2.2.2 Guardrails

Guardrail policies will both communicate and take action to correct a violated best practice

#### Example Use Case

Here is an example of what happens in each scenario when a user violates, or attempts to violate, a best practice:

| In-Band        | | Out-Of-Band  |
|----------------|---------------|--------------|
| Guideline  | Before Deploying, an user is notified that they are voliating a best practice, with instructions on how to propoerly deploy the resource. User can ignore the notification and proceed with deployment. | After Deploying, an user is notified that their recent deployment violated a best practice. Notification include instructions on how to fix their mistake and conform to best practice.|
| Guardrail  | Before Deploying, an user is notified that they will not be able to deploy until they fix the voliation or, the voliation will automatically correct before deployment. | After Deploying, an user is notified that their recent deployement voliated a best practice and that it has been automatically fixed.|

See [Add-on: Azure Policy for Guardrails for explanation of the built-in and custom policy definitions](../../src/bicep/overlays/policy/readme.md).

### Compliance View

A current compliance view of the whole Azure environment is provided via the Azure Policy Compliance dashboard. The organization's appropriate teams or automated remediations can then be used to handle non-compliant resources.

![Azure Policy Compliance](./media/architecture/AzurePolicyCompliancedashboard.png)

Custom policy sets have been designed to increase compliance for logging, networking & tagging requirements.

### 2.3 Policy Remediation

Through [Policy Remediation][policyRemediation], non-compliant resources can be made compliant. The fix is carried out by telling Azure Policy to deploy the given policy's instructions on your current resources and subscriptions, regardless of whether it was assigned to a management group, a subscription, a resource group, or a single resource. This article outlines the procedures needed to comprehend and carry out Azure Policy remediation.

When a resource is non-compliant, the compliance details for that resource are available from the Policy compliance page. The compliance details pane includes the following information:

* Resource details such as name, type, location, and resource ID
* Compliance state and timestamp of the last evaluation for the current policy assignment
* A list of reasons for the resource non-compliance

**Non-compliant resources**
![Azure Policy Remediation](media/architecture/remediation-non-compliant.png)

**Remediation history**
![Azure Policy Remediation](media/architecture/remediation-tasks.png)

## 3. Management Groups

Organizations using [Management Groups](https://docs.microsoft.com/azure/governance/management-groups/overview) can efficiently manage access, governance, and compliance across all subscriptions. An additional level of scope is offered by Azure management groups over subscriptions. Management groups, which are containers made up of subscriptions, are used to implement Azure Policies and role-based access control to the management groups. The settings made to a management group are automatically applied to all subscriptions within that management group.

Regardless of the kind of subscriptions you may have, management groups allow you enterprise-level management on a broad scale. A management group's single Azure Active Directory tenant must be trusted by all subscriptions within that group.

NoOps Accelerator recommends the following Management Group structure. This structure can be customized based on your organization's requirements. Specifically:

* **Top-level Management Group** (directly under the tenant root group) is created with a prefix provided by the organization, which purposely will avoid the usage of the root group to allow organizations to move existing Azure subscriptions into the hierarchy, and also enables future scenarios. This Management Group is parent to all the other Management Groups created by NoOps Accelerator

* **Platform:** This Management Group contains all the *platform* child Management Groups, such as Management, Transport, and Identity. Common Azure Policies for the entire platform is assigned at this level

  * **Management:** This Management Group contains the dedicated subscription for management, monitoring, and security, which will host Azure Log Analytics, Azure Automation, and Azure Sentinel. Specific Azure policies are assigned to harden and manage the resources in the management subscription.

  * **Transport:** This Management Group contains the dedicated subscription for transport, which will host the Azure networking resources required for the platform, such as Azure Virtual WAN/Virtual Network for the hub, Azure Firewall, DNS Private Zones, Express Route circuits, ExpressRoute/VPN Gateways etc among others. Specific Azure policies are assigned to harden and manage the resources in the transport subscription.
  
  * **Identity:** This Management Group contains the dedicated subscription for identity, which is a placeholder for Windows Server Active Directory Domain Services (AD DS) VMs, or Azure Active Directory Domain Services to enable AuthN/AuthZ for workloads within the landing zones. Specific Azure policies are assigned to harden and manage the resources in the identity subscription.

* **Landing Zones:** This is the parent Management Group for all the landing zone subscriptions and will have workload agnostic Azure Policies assigned to ensure workloads are secure and compliant.

  * **Internal:** This is the dedicated Management Group for Internal landing zones, meaning workloads that may require direct internet inbound/outbound transport or also for workloads that may not require a VNet..

* **Sandboxes:** This is the dedicated Management Group for subscriptions that will solely be used for testing and exploration by an organization’s application teams. These subscriptions will be securely disconnected from the Internal landing zones.

> This is just one example of a management group hierarchy structure. Other hierarchy structures can be defined.

![Management Groups](./media/architecture/management-group-structure.jpg)

Other variations on possible child management groups of the LandingZones management group that have arisen in discussions with customers include:

* Prod and NonProd
* Classified and Unclassified
* Partners

When choosing a management group hierarchy, consider the following:

* Authoritative guidance from subject matter experts
* Your organizational requirements
* Recommended best practices
* [Important facts about management groups](https://docs.microsoft.com/azure/governance/management-groups/overview#important-facts-about-management-groups)

Customers with existing management group structure can consider merging the recommended structure to continue to use the existing structure.

The new structure deployed side-by-side will enable the ability to:

* Configure all controls in the new management group without impacting existing subscriptions.

* Migrate existing subscriptions one-by-one (or small batches) to the new management group to reduce the impact of breaking changes.

Learn from each migration, apply policy exemptions, and reconfigure Policy assignment scope from NoOps to another scope that's appropriate.

> Management Group structure can be modified through Azure Bicep template located in ["management-groups"](../../src/bicep/overlays/management-groups/) folder

## 4. Identity

NoOps Accelerator assumes that Azure Active Directory has been provisioned and configured based on organiztion's requirements. It is important to check the following configuration for Azure Active Directory:

* License - Consider Azure PD Premium P2
* Multi-Factor Authentication - Enabled for all users
* Conditional Access Policies - Configured based on location & devices
* Privileged Identity Management (PIM) - Enabled for elevated access control.
* App Registration - Consider disabling for all users and created on-demand by CloudOps teams.
* Sign-In Logs - Logs are exported to Log Analytics workspace & Microsoft Sentinel used for threat hunting (Security Monitoring Team).
* Break-glass procedure - Process documented and implemented including 2 break glass accounts with different MFA devices & split up passwords.
* Azure Directory to Azure Active Directory synchronization - Are the identities synchronized or using cloud only account?

### 4.1 Service Principal Accounts

One service primary account will be employed for administration in order to support self-service infrastructure deployment. Since this service principal account has Owner authority across all management group scopes, it should only be used for Platform Automation. As soon as management groups are created, the owner role is automatically assigned.

The service principal requires Owner role to configure role assignments for:

* Policy Assignments that provide remediation (i.e. deployIfNotExists policies)

* Archetype deployments (i.e. workload deployments) with role assignments between Azure Services for integration and to Security Groups for user access

> Recommendation: Consider setting up approval flow through GitHub to ensure better control over actions execution. See Release gates and approvals overview in Azure Docs.

Additional service principal accounts must be created and scoped to child management groups, subscriptions or resource groups based on tasks that are expected of the service principal accounts.

### 4.2 User Accounts

User accounts with persistent permissions frequently have access to an Azure environment. Limiting permanent permissions and elevating roles with time-limited, MFA confirmed access through Privilege Identity Management is what we advise (Azure AD PIM).

Access should be allowed to user accounts based on membership in Security Groups, which should be assigned to all user accounts.

### 4.3 Recommendations for Management Groups

Scalable management and monitoring are made possible by access control at the Management Group scope. All child resources, including child management groups, subscriptions, resource groups, and resources, will automatically inherit any permissions given at Management Group scopes.

As a result, the following six scenarios all fit within its optimal scope.

| Scenario | Permanent Assignment | On-Demand Assignment (through Azure AD PIM) |
| --- | --- | --- |
| Global Reader | [Reader](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#reader) | - |
| Governance | - | [Resource Policy Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#resource-policy-contributor) |
| Log Management | [Log Analytics Reader](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#log-analytics-reader) | [Log Analytics Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#log-analytics-contributor) |
| Security Management | [Security Reader](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#security-reader) | [Security Admin](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#security-admin) |
| User Management | - | [User Access Administrator](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#user-access-administrator) |
| Cost Management | [Billing Reader](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#billing-reader) | - |

### 4.4 Recommendations for Subscriptions

The three generic roles that are frequently used in the Azure environment are listed in the table. Based on the use case, granular built-in roles can be used to further restrict access control. Our advice is to provide a person or service principal the least privileged role necessary to carry out the tasks.

Review the [Azure Built-In roles](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles) to evaluate applicability.

| Environment | Scenario | Considerations | Permanent Assignment | On-Demand Assignment (through Azure AD PIM)
| --- | --- | --- | --- | --- |
| All | Read Access | Permanent role assigned to all users who need access to the Azure resources. | [Reader](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#reader) | - |
| Dev/Test, QA | Manage Azure resources |  Contributor role can deploy all Azure resources, however any RBAC assignments will require the permissions to be elevated to Owner.<br /><br />Alternative is to leverage GitHub Actions and the Service Principal Account with elevated permissions. | [Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor) | [Owner](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#owner) |
| Production | Manage Azure resources | No standing management permissions in Production.<br /><br />Owner role is only required for RBAC changes, otherwise, use Contributor role or another built-in role for all other operations. | - | [Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor) or [Owner](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#owner)

### 4.5 Recommendations for Resource Groups

Follow the same guidance as Subscriptions.

### 4.6 Recommendations for Resources

Due to overhead of access control and assignments, avoid assigning permissions per resource.  Consider using Resource Group or Subscription scope permissions.

---

## 5. Platform Landing Zones

The recommended landing zone for NoOps Accelerator is the Misson Landing Zone. Mission LZ is intended to comply with the controls listed in the [Secure Cloud Computing Architecture (SCCA) Functional Requirements Document (FRD)](https://rmf.org/wp-content/uploads/2018/05/SCCA_FRD_v2-9.pdf).

> Misson Landing Zone can be modified through Azure Bicep template located in ["platforms/lz-platform-mlz"](../../src/bicep/platforms/lz-platform-mlz/) folder

### Network

The recommended network design achieves the purpose of hosting [IL2-IL6](cloud only). Currently, our default recommended network design is based off the Azure Mission Landing Zone Conceptual Architecture.

![Azure Mission Landing Zone Conceptual Architecture](./media/architecture/networking.png)

> NOTE: This is one recommended network design, but you can use other network design that suit your needs.

### IP Addresses

Both network designs will require 3 IP blocks:

* [RFC 1918][rfc1918] for Azure native-traffic (including IaaS and PaaS).  Example:  `10.18.0.0/16`
* [RFC 1918][rfc1918] for Azure Bastion.  Example:  `192.168.0.0/16`
* [RFC 6598][rfc1918] for department to department traffic through Secure Traffic. Example:  `10.0.100.0/24`

> This document will reference the example IP addresses above to illustrate network flow and configuration.

### Topology

Reference implementation provides exisitng topologies for Hub/Spoke Network design:

1. [Mission Landing Zone](archetypes//platforms/mlz-azfw.md) (pre-configured with Premium Firewall with rules, Azure Bastion, Azure Sentinel, Microsoft Defender for Cloud and forced tunneling mode)

### Azure Firewall Premium

All network traffic is directed through the firewall residing in the Network Hub resource group. The firewall is configured as the default route for all the T0 (Identity and Authorization) through T3 (workload/team environments) resource groups as follows:

|Name         |Address prefix| Next hop type| Next hop IP address|
|-------------|--------------|-----------------|-----------------|
|default_route| 0.0.0.0/0    |Virtual Appliance|10.0.100.4       |

The default firewall configured for Mission Landing Zone is [Azure Firewall Premium](https://docs.microsoft.com/en-us/azure/firewall/premium-features).

Presently, there are two firewall rules configured to ensure access to the Azure Portal and to facilitate interactive logon via PowerShell and Azure CLI, all other traffic is restricted by default. Below are the collection of rules configured for Azure Commercial and Azure Government clouds:

|Rule Collection Priority | Rule Collection Name | Rule name | Source | Port     | Protocol                               |
|-------------------------|----------------------|-----------|--------|----------|----------------------------------------|
|100                      | AllowAzureCloud      | AzureCloud|*       |   *      |Any                                     |
|110                      | AzureAuth            | msftauth  |  *     | Https:443| aadcdn.msftauth.net, aadcdn.msauth.net |

To deploy Mission Landing Zone using Azure Stack Hub and an F5 BIG-IP Virtual Edition instead of Azure Firewall Premium, there is an alternate repository with instructions [found here](https://github.com/Azure/missionlz-edge).

### Remote access with a Azure Bastion Host

Azure Bastion [does not support User Defined Route](https://docs.microsoft.com/azure/bastion/bastion-faq#udr) but can work with Virtual Machines on peered virtual networks as long as the [Network Security Groups allow][nsgAzureBastion] it and the user has the [required role based access control](https://docs.microsoft.com/azure/bastion/bastion-faq#i-have-access-to-the-peered-vnet-but-i-cant-see-the-vm-deployed-there)

### Microsoft Defender for Cloud

[Microsoft Defender](https://docs.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction) for Cloud offers a free set of monitoring capabilities that are enabled via an Azure policy when you first set up a subscription and view the Microsoft Defender for Cloud portal blade.

Microsoft Defender for Cloud offers a standard/defender sku which enables a greater depth of awareness including more recomendations and threat analytics. You can enable this higher depth level of security in MLZ by setting the parameter deployDefender during deployment. In addition you can include the emailSecurityContact parameter to set a contact email for alerts.

The Defender plan by resource type for Microsoft Defender for Cloud is enabled by default in the following [Azure Environments](https://docs.microsoft.com/en-us/powershell/module/servicemanagement/azure.service/get-azureenvironment?view=azuresmps-4.0.0): AzureCloud and AzureUSGovernment. To enable this for other Azure Cloud environments, this will need to executed manually. Documentation on how to do this can be found [here](https://docs.microsoft.com/en-us/azure/defender-for-cloud/enable-enhanced-security)

### Azure Sentinel

[Azure Sentinel](https://docs.microsoft.com/en-us/azure/sentinel/overview) is a scalable, cloud-native, security information and event management (SIEM) and security orchestration, automation, and response (SOAR) solution.

### Private DNS Zones

Azure PaaS services use Private DNS Zones to map their fully qualified domain names (FQDNs) when Private Endpoints are used. Managing Private DNS Zones at scale requires additional configuration to ensure:

* All Private DNS Zones for private endpoints are created in the Hub Virtual Network.
* Private DNS Zones from being created in the spoke subscriptions. These can only be created in the designated resource group in the Hub Subscription.
* Ensure private endpoints can be automatically mapped to the centrally managed Private DNS Zones.

The following diagram shows a typical high-level architecture for enterprise environments with central DNS resolution and name resolution for Private Link resources via Azure Private DNS. This topology provides:

* Name resolution from hub to spoke
* Name resolution from spoke to spoke
* Name resolution from on-premises to Azure (Hub & Spoke resources).  Additional configuration is required to deploy DNS resolvers in the Hub Network & provide DNS forwarding from on-premises to Azure.

![Hub Managed DNS](media/architecture/hubnetwork-private-link-central-dns.png)

**Reference:** [Private Link and DNS integration at scale](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/private-link-and-dns-integration-at-scale)

Reference implementation provides the following capabilities:

* Deploy Private DNS Zones to the Hub Networking subscription. Enable/disable via configuration.
* Azure Policy to block private zones from being created outside of the designated resource group in the Hub networking subscription.
* Azure Policy to automatically detect new private endpoints and add their A records to their respective Private DNS Zone.
* Support to ensure Hub managed Private DNS Zones are used when deploying archetypes.

The reference implementation does not deploy DNS Servers (as Virtual Machines) in the Hub nor Spoke for DNS resolution. It can:

* Leverage Azure Firewall's DNS Proxy where the Private DNS Zones are linked only to the Hub Virtual Network.  DNS resolution for all spokes will be through the VIP provided by Azure Firewall.

* Link Private DNS Zones directly to the spoke virtual networks and use the [built-in DNS resolver in each virtual network](https://docs.microsoft.com/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances). Virtual network(s) in spoke subscriptions be configured through Virtual Network Link for name resolution. DNS resolution is automatic once the Private DNS Zone is linked to the virtual network.

* Leverage DNS Servers on virtual machines that are managed by organization's IT.

### Spoke Landing Zone Networks

Following the nomenclature of [ITSG-22][itsg22], these would be the default subnets created in the spokes as part of new subscriptions.

* Tier 0 - for identity solutions
* Tier 1 - for network operations and security tools
* Tier 2 - for shared services
* Tier 3 - an optional network for app management servers in the spoke.

> Automation code deploys generic network security groups (NSGs) without the above traffic flow restrictions as they are dependent on the application architecture.  The NSG rules can be customized to control subnet-to-subnet traffic within a virtual network by customizing the automation code. Each subnet in the spoke virtual network has its own User Defined Route (UDR).  This allows for scenarios in which subnets can have different routing rules. It is possible for a single User Defined Route to be associated with many spoke subnets by customizing the automation code.

---

## 6. Logging

### 6.1 Scope

Microsoft's recommendation is [one central Log Analytics workspace](https://docs.microsoft.com/azure/azure-monitor/logs/design-logs-deployment#important-considerations-for-an-access-control-strategy) that will be shared by IT, Security Analysts and Application Teams.

The design and recommendation are based on the following requirements:

* Collect all logs from VMs and PaaS services.
* Logging for security monitoring.
* Limit data access based on resource permissions granted to individuals and teams.
* Tune alerting based on environments (i.e., less alerts from non-production environments).

![Log Analytics Workspace](./media/architecture/log-analytics-workspace.jpg)

This approach offers:

* Streamlined log correlation across multiple environments (Dev, QA, Prod) & line of businesses.
* Avoids log analytics workspace sprawl and streamlines tenant-wide governance through Azure Policy.
* Integration with compliance standards such as NIST 800-53 R4 and Protected B built-in Policy Sets to verify log collection compliance.
* Integration with Microsoft Defender for Cloud.
* Data access to logs are controlled through RBAC where Security Monitoring teams will access all data, while line of business teams access logs of the resources they manage.
* Cost optimization and better pricing at larger volume through capacity reservations.
* Tunable based on the types of logs and data retention as data ingestion grows.
* Modifiable as CloudOps and Cloud Security Monitoring evolves.

The workspace will be configured as:

* Workspace will be centrally managed and deployed in the **anoa-PlatformManagement** management group.  Workspace is managed by CloudOps team.
* Workspace will have the access mode set as use resource or workspace permissions.
* Data Retention set to **2 years** for all data types (i.e., Security Events, syslog).
* Log Analytics Workspace will be stored in **EastUS**.

As the logging strategy evolves, Microsoft recommends considering the following improvements:

* To optimize cost, configure [data retention periods by data type](https://docs.microsoft.com/azure/azure-monitor/logs/manage-cost-storage#retention-by-data-type).
* To optimize cost, collect only the logs that are required for operations and security monitoring.  Current requirement is to collect all logs.
* For data retention greater than 2 years, export logs to Azure Storage and [leverage immutable storage](https://docs.microsoft.com/azure/storage/blobs/storage-blob-immutable-storage) with WORM policy (Write Once, Read Many) to make data non-erasable and non-modifiable.
* Use Security Groups to control access to all or per-resource logs.

### 6.2 Design considerations for multiple Log Analytics workspaces

| Rationale | Applicability |
| --- | --- |
| Require log data stored in specific regions for data sovereignty or compliance reasons. | Not applicable to current environment since all Azure deployments will be in Canada. |
| Avoid outbound data transfer charges by having a workspace in the same region as the Azure resources it manages. | Not applicable to current environment since all Azure deployments will be in Canada Central. |
| Manage multiple organizations or business groups, and need each to see their own data, but not data from others. Also, there is no business requirement for a consolidated cross organization or business group view. | Not applicable since security analysts require cross organization querying capabilities, but each organization or Application Team can only see their data.  Data access control is achieved through role-based access control. |

**Reference**: [Designing your Azure Monitor Logs deployment](https://docs.microsoft.com/en-ca/azure/azure-monitor/logs/design-logs-deployment#important-considerations-for-an-access-control-strategy)

### 6.3 Access Control - Use resource or workspace permissions

With Azure role-based access control (Azure RBAC), you can grant users and groups appropriate access they need to work with monitoring data in a workspace. This allows you to align with your IT organization operating model using a single workspace to store collected data enabled on all your resources.

For example, when you grant access to your team responsible for infrastructure services hosted on Azure virtual machines (VMs), and as a result they'll have access to only the logs generated by those VMs. This is following **resource-context** log model. The basis for this model is for every log record emitted by an Azure resource, it is automatically associated with this resource. Logs are forwarded to a central workspace that respects scoping and Azure RBAC based on the resources.

**Reference**:  [Designing your Azure Monitor Logs deployment - Access Control](https://docs.microsoft.com/en-ca/azure/azure-monitor/logs/design-logs-deployment?WT.mc_id=modinfra-11671-pierrer#access-control-overview)

| Scenario | Log Access Mode | Log Data Visibility |
| --- | --- | --- |
| Security Analyst with [Log Analytics Reader or Log Analytics Contributor](https://docs.microsoft.com/en-ca/azure/azure-monitor/logs/manage-access#manage-access-using-azure-permissions) RBAC role assignment. | Access the Log Analytics workspace directly through Azure Portal or through Microsoft Sentinel. | All data in the Log Analytics Workspace. |
| IT Teams responsible for one or more line of business with permissions to one or more subscriptions, resource groups or resources with at least Reader role. | Access the logs through the resource's Logs menu for the Azure resource (i.e., VM or Storage Account or Database). | Only to Azure resources based on RBAC.  User can query logs for specific resources, resource groups, or subscription they have access to from any workspace but can't query logs for other resources. |
| Application Team with permissions to one or more subscriptions, resource groups or resources with at least Reader role. | Access the logs through the resource's Logs menu for the Azure resource (i.e., VM or Storage Account or Database). | Only to Azure resources based on RBAC.  User can query logs for specific resources, resource groups, or subscription they have access to from any workspace but can't query logs for other resources. |

---

## 7. Tagging

Organize cloud resources to meet the needs of governance, operational management, and accounting. Resources can be managed and found more quickly with the aid of well-defined metadata tagging protocols. By using charge back and show back accounting procedures, these conventions also assist in tying cloud usage charges to specific business teams.

A tagging strategy include business and operational details:

* The business aspect of this method makes certain that tags have the organizational data required to identify the teams. Utilize a resource in addition to the owners who are in charge of resource charges.

* The operational aspect makes sure that tags have the data that IT teams need to identify the workload, application, environment, criticality, and other details important for resource management.

Tags can be assigned to resource groups using 2 approaches:

| Approach | Mechanism |
| --- | --- |
| Automatically assigned from the Subscription tags | Azure Policy:  Inherit a tag from the subscription to resource group if missing |
| Explicitly set on a Resource Group | Azure Portal, ARM templates, CLI, PowerShell, etc. All tags can be inherited by default from subscription and can be changed as needed per resource group. |

Tags can be assigned to resources using 2 approaches:

| Approach | Mechanism |
| --- | --- |
| Automatically assigned from the Resource Group tags | Azure Policy:  Inherit a tag from the resource group if missing |
| Explicitly set on a Resource | Azure Portal, ARM templates, CLI, PowerShell, etc.

> **Note:**  It's recommended to inherit tags that are required by the organization through Subscription & Resource Group.  Per resource tags are typically added by Application Teams for their own purposes. |

Azure NoOps Accelerator recommends the following tagging structure.  

> The tags can be modified through Azure Policy.  Modify [Tag Azure Policy definition configuration](../policy/custom/definitions/policyset/Tags.parameters.json) to set the required Resource Group & Resource tags.

![Tags](media/architecture/tags.jpg)

In order to implement this tagging architecture, custom Azure Policies are utilized to back-fill resource groups and resources with missing tags, validate mandatory tags at resource groups, and automatically propagate tags from subscriptions and resource groups. Azure Policies used to achieve this design are:

* [Custom] Inherit a tag from the subscription to resource group if missing (1 policy per tag)
* [Custom] Inherit a tag from the resource group if missing (1 policy per tag)
* [Custom] Require a tag on resource groups (1 policy per tag)
* [Custom] Audit missing tag on resource (1 policy per tag)

This approach ensures that:

* All resource groups contain the expected tags; and
* All resource groups can inherit common tags from subscription when missing; and
* All resources in that resource groups will automatically inherit those tags.

This helps remove deployment friction by eliminating the explicit tagging requirement per resource.  The tags can be overridden per resource group & resource if required.

**Example scenarios for inheriting from subscription to resource group**

These example scenarios outline the behaviour when using Azure Policy for inheriting tag values.

To simplify, let's assume a single `CostCenter` tag is required for every resource group.

| Subscription Tags | Resource Group Tags | Outcome |
| --- | --- | --- |
| `CostCenter=123` | `CostCenter` tag not defined when creating a resource group. | `CostCenter=123` is inherited from subscription.  Resource group is created. |
| `CostCenter=123` | `CostCenter=ABC` defined when creating the resource group. | `CostCenter=ABC` takes precedence since it's explicitly defined on the resource group.  Resource group is created. |
| `CostCenter` tag is not defined. | `CostCenter` tag not defined when creating a resource group. | Policy violation since tag can't be inherited from subscription nor it hasn't been defined on resource group. Resource group is not created. |

**Example scenarios for inheriting from resource group to resources**

These example scenarios outline the behaviour when using Azure Policy for inheriting tag values.

To simplify, let's assume a single `CostCenter` tag is required for every resource.

| Resource Group Tags | Resource Tags | Outcome |
| --- | --- | --- |
| `CostCenter=123` | `CostCenter` tag not defined when creating a resource. | `CostCenter=123` is inherited from resource group.  Resource is created. |
| `CostCenter=123` | `CostCenter=ABC` defined when creating the resource. | `CostCenter=ABC` takes precedence since it's explicitly defined on the resource.  Resource is created. |

*We chose custom policies so that they can be grouped in a policy set (initiative) and have unique names to describe their purpose.*

**Design Considerations**

* Only one policy can update a tag per deployment.  Therefore, to setup automatic assignments, the Azure Policy must be created at either Subscription or Resource Group scope, not both scopes.  This rule is applied per tag.  **This reference implementation has chosen to use Resource group tags only.**

* Do not enter names or values that could make your resources less secure or that contain personal/sensitive information because tag data will be replicated globally.

* There is a maximum of 50 tags that is assignable per subscription, resource group or resource.  

---

## 8. Archetypes (Enclave/Platform/Workload)

>TODO: Archetype def 

## 8.1 Enclave

A enclave describes what needs to be true to meet an expected environment and compliance requirements at a specific scope level.

This includes:

* Platform Archetype (landing zone)
* Workload Archetype
* Management Group hierary
* Azure Policy assignments.
* Role-based access control (RBAC) assignments.

| Enclave | Design | Documentation |
| --- | --- | --- |
| **Mission Landing Zone** | ![Enclave: Mission Landing Zone](media/archetypes/archetype-en-mlz.svg) | [Enclave definition](archetypes/enclave/enclave-mission-landing-zone.md) |

## 8.2 Platform Archetypes

Platform Archetypes represent key services that often benefit from being consolidated for efficiency and ease of operations. Examples include networking, identity, and management services.

| Archetype | Design | Documentation |
| --- | --- | --- |
| **Mission Landing Zone** | ![Archetype: Mission Landing Zone](media/archetypes/archetype-mlz.svg) | [Archetype definition](archetypes/platforms/mission-landing-zone.md) |

## 8.3 Workload Archetypes

| Archetype | Design | Documentation |
| --- | --- | --- |
| **Tier 3** | ![Archetype: t3](media/archetypes/archetype-logging.jpg) | [Archetype definition](archetypes/logging.md) |
| **DMZ** | ![Archetype: dmz](media/archetypes/archetype-dmz.jpg) | [Archetype definition](archetypes/dmz.md) |

---
