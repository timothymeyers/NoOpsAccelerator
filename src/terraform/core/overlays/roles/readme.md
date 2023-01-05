# Terraform Enclave Support Overlays Folders

## Overview

## Roles Folder

Roles is the basis on creating a custom modular Roles designs. This core is used in Mission Enclave creations.

## Roles Folder Structure

The Roles folder structure is as follows:

```bash
├───roles
│   ├───main.tf│
│   └───variables.tf
└───readme.md
```

## Roles Modules

The Roles modules are as follows:

### Main

The main module is used to create the Roles.

```hcl
module "custom_roles" {
  source = "./roles"
  deploy_custom_roles = true
  custom_role_definitions = var.custom_role_definitions
}
```

## Inputs

The following table lists the configurable parameters of the Roles module and their default values.

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| `deploy_custom_roles` | (Required) Specifies whether custom RBAC roles should be created. | bool | n/a | true |
| `custom_role_definitions` | (Required) A list of custom role definitions to create. | list | n/a | true |

```hcl
custom_role_definitions = [
  {
    role_definition_name = "CUSTOM - App Settings Reader"
    description          = "Allows view access for Azure Sites Configuration"
    permissions = {
      actions          = ["Microsoft.Web/sites/config/list/action", "Microsoft.Web/sites/config/read"]
      data_actions     = []
      not_actions      = []
      not_data_actions = []
    }
  },
  {
    role_definition_name = "CUSTOM - App Settings Admin"
    description          = "Allows edit access for Azure Sites Configuration"
    permissions = {
      actions          = ["Microsoft.Web/sites/config/*"]
      data_actions     = []
      not_actions      = []
      not_data_actions = []
    }
  }
]
```

## Outputs

The following table lists the outputs of the Roles module.

| Name | Description |
|------|-------------|
| roles | The Roles created |


