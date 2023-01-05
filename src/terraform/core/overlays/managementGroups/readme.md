# Terraform Enclave Support Overlays Folders

## Overview

## Management Groups Folder

Management Groups is the basis on creating a modular Management Groups network designs. This core is used in Mission Enclave creations.

## Management Groups Folder Structure

The Management Groups folder structure is as follows:

```bash
├───managementGroups
│   ├───main.tf
│   ├───outputs.tf
│   └───variables.tf
└───readme.md
```

## Management Groups Modules

The Management Groups modules are as follows:

### Main

The main module is used to create the Management Groups.

```hcl
module "management_groups" {
  source   = "../../modules/Microsoft.Management/managementGroups"

  root_parent_id = data.azurerm_client_config.current.tenant_id
  root_id        = var.root_id
  root_name      = var.root_display_name
  landing_zones  = var.management_groups

  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}
```

## Inputs

The following table lists the configurable parameters of the Management Groups module and their default values.

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| root_id | The ID of the root Management Group | string | n/a | yes |
| root_display_name | The name of the root Management Group | string | n/a | yes |
| management_groups | The Management Groups to create | list | n/a | yes |

## Outputs

The following table lists the outputs of the Management Groups module.

| Name | Description |
|------|-------------|
| management_groups | The Management Groups created |
