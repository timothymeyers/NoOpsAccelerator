output "wl_subid" {
  description = "Subscription ID where the Workload Resource Group is provisioned"
  value       = var.wl_subid
}

output "wl_vnetname" {
  description = "The Workload Virtual Network name"
  value       = module.dev_env_aks_workload_spoke_network.virtual_network_name
}
