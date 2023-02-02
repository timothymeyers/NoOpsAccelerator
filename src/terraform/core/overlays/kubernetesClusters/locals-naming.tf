locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  name     = coalesce(var.custom_name, data.azurenoopsutils_resource_name.keyvault.result)
  aks_name = coalesce(var.custom_name, data.azurenoopsutils_resource_name.keyvault_hsm.result)
}
