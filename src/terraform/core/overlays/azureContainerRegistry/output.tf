output "name" {
  description = "Specifies the name of the container registry."
  value       = module.acr.name
}

output "id" {
  description = "Specifies the resource id of the container registry."
  value       = module.acr.id
}

output "login_server" {
  description = "Specifies the login server of the container registry."
  value = module.acr.login_server
}

output "login_server_url" {
  description = "Specifies the login server url of the container registry."
  value = "https://${module.acr.login_server}"
}

output "admin_username" {
  description = "Specifies the admin username of the container registry."
  value = module.acr.admin_username
}
