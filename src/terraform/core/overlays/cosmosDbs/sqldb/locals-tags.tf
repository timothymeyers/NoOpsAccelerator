# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------
# Local Tags configuration - Default (required). 
#------------------------------------------------------------

locals {
  default_tags = var.default_tags_enabled ? {
    env  = var.environment
    core = var.workload_name
  } : {}
}
