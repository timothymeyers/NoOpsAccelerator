locals {
  default_tags = var.default_tags_enabled ? {
    env  = var.environment
    core = var.workload_name
  } : {}
}
