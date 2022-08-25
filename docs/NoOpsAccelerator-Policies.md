# Policies included in NoOps Accelerator reference implementations

As you increase your deployments and subscriptions in the NoOps Accelerator architecture, Azure Policy and deployIfNotExist provide platform autonomy and lessen operational burden. The main goal is to make sure that resources and subscriptions are compliant while allowing application teams to deploy using their own preferred tools and clients.

> Please refer to [Policy Driven Governance](https://docs.microsoft.com/en-gb/azure/cloud-adoption-framework/ready/landing-zone/design-principles#policy-driven-governance) for further information.

## Why are there custom policy definitions as part of NoOps Accelerator reference implementation?

To make sure that we develop and improve the reference implementations to suit customers requirements, we collaborate with and learn from our customers and partners. We are gradually migrating these rules to built-ins. The main strategies of the policies included in NoOps Accelerator are to be proactive (deployIfNotExist, and modify), and preventive (deny).

## What Azure Policies does NoOps Accelerator reference implementation provide additionally to those already built-in?

There are around 104 custom Azure Policy Definitions included and around 7 Custom Azure Policy Initiatives included as part of the Azure Landing Zones implementation that add on to those already built-in within each Azure customers tenant.

All custom Azure Policy Definitions and Initiatives are the same across all implementation options for NoOps Accelerator.

This is because the single source of truth is the [`NoOps Accelerator` repo](https://github.com/Azure/NoOpsAccelerator) that the Bicep implementation options pull from to build their `policy` folders respectively.

For a complete list of all custom and built-in policies deployed within an Azure Landing Zone deployment, please refer to the following [section](https://github.com/Azure/NoOpsAccelerator/blob/main/docs/NoOpsAccelerator-Policies.md#what-policy-definitions-are-assigned-within-the-azure-landing-zones-custom--built-in).

> Our goal is always to try and use built-in policies where available and also work with product teams to adopt our custom policies and make them built-in, which takes time. This means there will always be a requirement for custom policies.

## What policy definitions are assigned within the NoOps Accelerator reference implementation (Custom & Built-in)?

As part of a default deployment configuration, policy and policy set definitions are deployed at multiple levels within the NoOps Accelerator Landing Zone Management Group hierachy as depicted within the below diagram.

![image](./media/MgmtGroups_Policies_v0.1.jpg)

The subsequent sections will provide a summary of policy sets and policy set definitions applied at each level of the Management Group hierachy.

>NOTE: Although the below sections will define which policy definitions/sets are applied at specific scopes, please remember that policy will inherit within your management group hierachy.

## Intermediate Root

This management group is a parent to all the other management groups created withn the default Azure Landing Zone configuration. Policy assignment is predominantly focused on assignment of security and monitoring best practices to ensure compliance and reduced operational overhead.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>
  
![image](./media/IntRoot_v0.1.jpg)
  
</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **5**     |
| `Policy Definitions`      | **3**     |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Intermediate Root Management Group**.

| Assignment Name                                                            | Definition Name                                                                  | Policy Type                           | Description                                                                                                                                                                                                                                                                                                                                                                          | Effect(s)                           | Version |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------- | ------- |

### Platform

This management group contains all the platform child management groups, like management, connectivity, and identity. There are currently no policies assigned at this management group

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>
  
![image](./media/Platform_v0.1.jpg)
  
</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **0**     |
</td></tr> </table>

### Connectivity

This management group contains a dedicated subscription for connectivity. This subscription will host the Azure networking resources required for the platform, like Azure Virtual WAN, Azure Firewall, and Azure DNS private zones. Policy assignment is predominantly focused on Azure DDoS Protection.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>
  
![image](./media/Connectivity_v0.1.jpg)
  
</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **1**     |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Connectivity Management Group**.

| Assignment Name                                                            | Definition Name                                                            | Policy Type                       | Description                                                                                                                                                               | Effect(s) | Version |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ------- |

### Management

This management group contains a dedicated subscription for management, monitoring, and security. This subscription will host an Azure Log Analytics workspace, including associated solutions, and an Azure Automation account. Policy assignment is predominantly focused on the deployment and configuration of the Log Analytics Workspace.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>
  
![image](./media/Management_v0.1.jpg)
  
</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **1**     |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Management Management Group**.

| Assignment Name          | Definition Name                                                                                | Policy Type                       | Description                                                                                                               | Effect(s)         | Version |
| ------------------------ | ---------------------------------------------------------------------------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ----------------- | ------- |

### Identity

This management group contains a dedicated subscription for identity. This subscription is a placeholder for Windows Server Active Directory Domain Services (AD DS) virtual machines (VMs) or Azure Active Directory Domain Services. Policy assignment is predominantly focused on hardening and management of resources in the identity subscription.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>
  
![image](./media/Identity_v0.1.jpg)
  
</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **4**     |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Identity Management Group**.

| Assignment Name                                                                                                     | Definition Name                                                                                                     | Policy Type                       | Description                                                                                                                                    | Effect(s)         | Version |
| ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- | ------- |

### Landing Zones

This is the parent management group for all the landing zone child management groups. Policy assignment is predominantly focused on ensuring workloads residing under this hierachy are secure and compliant.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>

![image](./media/LandingZone_v0.1.jpg)

</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **1**     |
| `Policy Definitions`      | **12**    |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Landing Zones Management Group**.

| Assignment Name                                                                                                     | Definition Name                                                                                                     | Policy Type                         | Description                                                                                                                                                                                                                                                                                                                                                                         | Effect(s)                                        | Version |
| ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ | ------- |

### Internal

This management group is for internal landing zones. This group is for workloads that require connectivity or hybrid connectivity with the corporate network via the hub in the connectivity subscription. Policy assignment is predominantly focused on ensuring workloads residing under this hierachy are secure and compliant.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>

![image](./media/Internal_v0.1.jpg)

</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **2**     |
| `Policy Definitions`      | **3**     |
</td></tr> </table>

The table below provides the specific **Custom** and **Built-in** **policy definitions** and **policy definitions sets** assigned at the **Corp Management Group**.

| Assignment Name                                                | Definition Name                                                | Policy Type                         | Description                                                                                                                                                                                            | Effect(s)         | Version |
| -------------------------------------------------------------- | -------------------------------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------- | ------- |

### Sandbox

This management group is for subscriptions that will only be used for testing and exploration by an organization. These subscriptions will be securely disconnected from the corporate and online landing zones. Sandboxes also have a less restrictive set of policies assigned to enable testing, exploration, and configuration of Azure services. There are currently no policies assigned at this management group.

<table>
<tr><th>Management Group </th><th>Policy Configuration</th></tr>
<tr></tr>
<tr><td>

![image](./media/Sandbox_v0.1.jpg)

</td><td>
  
| **Policy Type**           | **Count** |
| :---                      |   :---:   |
| `Policy Definition Sets`  | **0**     |
| `Policy Definitions`      | **0**     |
</td></tr> </table>