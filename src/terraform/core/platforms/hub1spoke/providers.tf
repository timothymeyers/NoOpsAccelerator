# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

####################
### PROVIDERS    ###
####################
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

# Provider Configuration
provider "azurerm" {
  environment     = var.environment
  metadata_host   = var.metadata_host
  subscription_id = var.hub_subid

  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = true # When that feature flag is set to true, this is required to allow the deletion of the log analytics workspace when the deployment is destroyed.
    }
    key_vault {
      purge_soft_delete_on_destroy = true # When that feature flag is set to true, this is required to allow the deletion of the key vault when the deployment is destroyed.
    }
    resource_group {
      prevent_deletion_if_contains_resources = false # When that feature flag is set to true, this is required to stop the deletion of the resource group when the deployment is destroyed. This is required if the resource group contains resources that are not managed by Terraform.
    }
    virtual_machine { # When that feature flag is set to true, this is required to allow the deletion of the virtual machine when the deployment is destroyed.
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}

provider "azurerm" {
  alias           = "logging"
  environment     = var.environment
  metadata_host   = var.metadata_host
  subscription_id = coalesce(var.ops_subid, var.hub_subid)

  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azurerm" {
  alias           = "hub"
  environment     = var.environment
  metadata_host   = var.metadata_host
  subscription_id = var.hub_subid

  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}

provider "azurerm" {
  alias           = "ops"
  environment     = var.environment
  metadata_host   = var.metadata_host
  subscription_id = coalesce(var.ops_subid, var.hub_subid)

  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}