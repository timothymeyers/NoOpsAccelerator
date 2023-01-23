# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#################################
# Global Configuration
#################################

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)
  default = {
    "DeploymentType" : "AzureNoOpsTF"
  }
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "custom_resource_group_name" {
  description = "The name of the resource group in which the resources will be created. If not provided, a new resource group will be created with the name 'rg-<org_name>-<environment>-<workload_name>'"
  type        = string
  default     = ""
}

variable "org_prefix" {
  description = "A name for the organization. It defaults to anoa."
  type        = string
  default     = "anoa"
}

variable "workload_name" {
  description = "A name for the workload. It defaults to anoa."
  type        = string
  default     = "anoa"
}

variable "environment" {
  description = "The Terraform backend environment e.g. public or usgovernment"
  type        = string
}

################################################
# Tier 1 - Operations - Logging Configuration ##
################################################

variable "logging_log_analytics" {
  description = "Log Analytics Workspace variables for the deployment"
  default     = {}
}

variable "deploy_sentinel" {
  description = "Create an Azure Sentinel Log Analytics Workspace Solution"
  type        = bool
  default     = true
}

variable "storage_account_name" {
  description = "Storage Account name for the logging deployment"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name for the logging deployment"
  type        = string
  default     = ""
}

#################################
# Logging Configuration
#################################

variable "deploy_solutions" {
  description = "Deploy Log Analytics Solutions"
  type        = bool
  default     = true
}

variable "log_analytics_resource_id" {
  description = "The name of the log analytics workspace resource id"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "The name of the log analytics workspace"
  type        = string
  default     = ""
}

variable "log_analytics_storage_id" {
  description = "The name of the log analytics storage account"
  type        = string
  default     = ""
}

variable "solution_plans" {
  description = "Specifies solutions to deploy to log analytics workspace"
  type = list(object({
    solution_name = string
    product       = string
    publisher     = string
  }))
  default = [
    {
      solution_name = "AzureActivity"
      product       = "OMSGallery/AzureActivity"
      publisher     = "Microsoft"
    },
    {
      solution_name = "Security"
      product       = "OMSGallery/Security"
      publisher     = "Microsoft"
    },
    {
      solution_name = "ServiceMap"
      product       = "OMSGallery/ServiceMap"
      publisher     = "Microsoft"
    },
    /* {
      solution_name = "VMInsights"
      product       = "OMSGallery/VMInsights"
      publisher     = "Microsoft"
    }, */
    {
      solution_name = "ContainerInsights"
      product       = "OMSGallery/ContainerInsights"
      publisher     = "Microsoft"
    },
    {
      solution_name = "KeyVaultAnalytics"
      product       = "OMSGallery/KeyVaultAnalytics"
      publisher     = "Microsoft"
    },
  ]
}

#################################
# Resource Lock Configuration
#################################

variable "enable_resource_locks" {
  description = "Flag to enable locks on the resources"
  type        = bool
  default     = true
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
  default     = "CanNotDelete"
}