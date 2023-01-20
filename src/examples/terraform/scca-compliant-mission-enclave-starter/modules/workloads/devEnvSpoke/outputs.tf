output "wl_subid" {
  description = "Subscription ID where the Workload Resource Group is provisioned"
  value       = var.wl_subscription_id
}

output "wl_vnetname" {
  description = "The Workload Virtual Network name"
  value       = module.mod_dev_env_aks_workload_spoke_network.virtual_network_name
}
