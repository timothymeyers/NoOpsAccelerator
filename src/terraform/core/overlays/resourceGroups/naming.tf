data "azurecaf_name" "rg" {
  name          = var.workload_name
  resource_type = "azurerm_resource_group"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.org_name, var.environment, local.name_suffix, var.use_caf_naming ? "" : local.clara_slug])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}
