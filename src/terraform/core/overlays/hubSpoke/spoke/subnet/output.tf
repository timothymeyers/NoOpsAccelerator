output "subnet_ids" {
  description = "Returns all the subnets ids in the Virtual Network. As a map of ID"
  value       = module.mod_subnet.subnet_ids
}

output "route_table_id" {
  description = "The id of the route table"
  value       = module.mod_routetable.id
}