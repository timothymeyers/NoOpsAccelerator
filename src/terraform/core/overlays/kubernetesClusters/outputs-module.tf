output "terraform_module" {
  description = "Information about this Terraform module"
  value = {
    name       = "aks"
    version    = file("${path.module}/VERSION")
    provider   = "azurerm"
    maintainer = "microsoft"
  }
}