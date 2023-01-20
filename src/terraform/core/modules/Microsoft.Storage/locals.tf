#-------------------------------
# Local Declarations
#-------------------------------
locals {
  account_tier             = (var.account_kind == "FileStorage" ? "Premium" : split("_", var.sku_name)[0])
  account_replication_type = (local.account_tier == "Premium" ? "LRS" : split("_", var.sku_name)[1])
}