output "subnet_ids" {
  description = "Returns all the subnets ids in the Virtual Network. As a map of ID"
  value       = module.mod_subnet.subnet_ids
}

output "route_table_id" {
  description = "The id of the route table"
  value       = module.mod_routetable.id
}

output "route_table_name" {
  description = "The name of the route table"
  value       = module.mod_routetable.name
}

output "network_security_group_id" {
  description = "The id of the network security group"
  value       = module.mod_network_nsg.id
}

output "network_security_group_name" {
  description = "The name of the network security group"
  value       = module.mod_network_nsg.name
}