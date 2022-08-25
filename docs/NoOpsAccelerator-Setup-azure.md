# Configure Azure permissions for ARM tenant deployments

This guide will walk you through the process of configuring permissions in your Azure environment to enable ARM tenant level deployments.

> Note: The steps below require you to use an identity that is local to the Azure AD, and **_not_** Guest user account due to known restrictions.

NoOps Accelerator reference implementation requires permission at tenant root scope "/" to be able to configure Management Group and create/move subscription. In order to grant permission at tenant root scope "/", users in "AAD Global Administrators" group can temporarily elevate access, to manage all Azure resources in the directory.

Once the User Access Administrator (UAA) role is enabled, a UAA can grant **_other users and service principals_** within organization to deploy/manage NoOps Accelerator reference implementation by granting "Owner" permission at tenant root scope "/".

Once permission is granted to other **users and service principals**, you can safely disable "User Access Administrator" permission for the "AAD Global Administrator" users. For more information please follow this article [elevated account permissions](https://docs.microsoft.com/azure/role-based-access-control/elevate-access-global-admin)

## 1. Elevate Access to manage Azure resources in the directory

1.1 Sign in to the Azure portal or the Azure Active Directory admin center as a Global Administrator. If you are using Azure AD Privileged Identity Management, activate your Global Administrator role assignment.

1.2 Open Azure Active Directory.

1.3 Under _Manage_, select _Properties_.
![alt](https://docs.microsoft.com/azure/role-based-access-control/media/elevate-access-global-admin/azure-active-directory-properties.png)

1.4 Under _Access management for Azure resources_, set the toggle to Yes.

![alt](https://docs.microsoft.com/azure/role-based-access-control/media/elevate-access-global-admin/aad-properties-global-admin-setting.png)

## 2. Grant Access to User and/or Service principal at root scope "/" to deploy NoOps Accelerator reference implementation

Please ensure you are logged in as a user with UAA role enabled in AAD tenant and logged in user is not a guest user.

Bash

````bash
#sign into AZ CLI, this will redirect you to a webbrowser for authentication, if required
az login

#if you do not want to use a web browser you can use the following bash
read -sp "Azure password: " AZ_PASS && echo && az login -u <username> -p $AZ_PASS

#assign Owner role at Tenant root scope ("/") as a User Access Administrator to current user (gets object Id of the current user (az login))
az role assignment create --scope '/' --role 'Owner' --assignee-object-id $(az ad signed-in-user show --query id --output tsv) --assignee-principal-type User

#(optional) assign Owner role at Tenant root scope ("/") as a User Access Administrator to service principal (set spn_displayname to your service principal displayname)
spn_displayname='<ServicePrincipal DisplayName>'
az role assignment create --scope '/' --role 'Owner' --assignee-object-id $(az ad sp list --display-name $spn_displayname --query '[].{objectId:objectId}' -o tsv) --assignee-principal-type ServicePrincipal
````

PowerShell

````powershell
#sign in to Azure from Powershell, this will redirect you to a webbrowser for authentication, if required
Connect-AzAccount

#get object Id of the current user (that is used above)
$user = Get-AzADUser -UserPrincipalName (Get-AzContext).Account

#assign Owner role at Tenant root scope ("/") as a User Access Administrator to current user
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id

#(optional) assign Owner role at Tenant root scope ("/") as a User Access Administrator to service principal (set $spndisplayname to your service principal displayname)
$spndisplayname = "<ServicePrincipal DisplayName>"
$spn = (Get-AzADServicePrincipal -DisplayName $spndisplayname).id
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $spn
````

Please note, it may take up to 15-30 minutes for permission to propagate at tenant root scope. It is highly recommended that you log out and log back in.

### Creating a scoped role assignment

The Owner privileged root tenant scope *is required* in the deployment of the [Reference implementation](EnterpriseScale-Deploy-reference-implentations.md).  However post deployment, and as your use of Enterprise Scale matures, you are able to limit the scope of the Service principal roleAssignments to a subsection of the Management Group hierarchy.
Eg. `"/providers/Microsoft.Management/managementGroups/YourMgGroup"`.

### 1. Install Azure Active Directory (AAD) Prerequisites

Prerequisite Azure Active Directory items including Groups, Service Principal and Role Assignments are required to perform subsequent deployment steps.  This step is intended to be executed one time on first deployment.  It is packaged as a single PowerShell script and intended to be executed interactively from a PowerShell instance with access to the management plane of target Azure environment.  The script, [Deploy-AAD-prereqs.ps1](Deploy-AAD-prereqs.ps1), does the following:

* Creates Azure AD Group **azure-platform-owners**
* Creates Azure AD Group **azure-platform-readers**
* Assigns **azure-platform-owners** the Owner role at scope **/providers/Microsoft.Management/managementGroups/root_management_group_id**
* Assigns **azure-platform-readers** the Reader role at scope **/providers/Microsoft.Management/managementGroups/root_management_group_id**
* Creates AzureAD App **azure-your-org-deployer**
* Creates AzureAD Service Principal for App **azure-your-org-deployer**
* Adds AzureAD App Service Principal **azure-your-org-deployer** to group **azure-platform-owners**
* Adds Currently Logged in Deployment User to group **azure-platform-readers**

The user running the script must be elevated to **User Rights Administrator** temporarily in Azure Active Directory (Properties tab, see below).  After the script runs successfully the account should be removed from this role.

![](images\aad_useraccesscontributor.png)

Generate a client Secret for the **azure-your-org-deployer** account in the App Registrations blade.  

![](images\aad_clientsecret.png)

Make a note of the secret value, Application ID and Tenant ID.

![](images\aad_info.png)

### 2. Setup GitHub Actions Environments

### 3. Run Build and Release Pipelines

The pipelines should be executed in the following order:

1. Management Groups
2. Network Deployment
3. Policies
4. Roles
5. Mission Workloads
    a. Generic Workload

## Next steps

Please proceed with [deploying reference implementation](./architecture.md).
