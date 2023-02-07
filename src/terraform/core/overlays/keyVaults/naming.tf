data "azurenoopsutils_resource_name" "keyvault" {
  name          = var.workload_name
  resource_type = "azurerm_key_vault"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_name, var.environment, var.location_short, local.name_suffix, var.use_naming ? "" : "kv"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "keyvault_hsm" {
  name          = var.workload_name
  resource_type = "azurerm_key_vault"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_name, var.environment, var.location_short, local.name_suffix, var.use_naming ? "hsm" : "kvhsm"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}
