variable "resource_group_name" {
  description = "The resource group object where to create the resource."
}

variable "location" {
  description = "The location where to create the resource."
}

variable "vnets" {
  description = "Virtual networks objects - contains all virtual networks that could potentially be used by the module."
}

variable "aml" {
  description = "Azure Machine Learning objects - contains all AML workspaces that could potentially be used by the module."
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}

variable "diagnostics" {
  description = "(Required) Diagnostics object with the definitions and destination services"
}

variable "private_endpoints" {
  default = {}
}

variable "resource_groups" {
  default = {}
}

variable "private_dns" {
  default = {}
}
