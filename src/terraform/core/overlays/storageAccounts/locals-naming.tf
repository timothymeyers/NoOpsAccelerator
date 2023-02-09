# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------
# Local Naming configuration - Default (required). 
#-----------------------------------------------------------

locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  sa_name = coalesce(var.storage_account_custom_name, lower(data.azurenoopsutils_resource_name.sa.result))
}
