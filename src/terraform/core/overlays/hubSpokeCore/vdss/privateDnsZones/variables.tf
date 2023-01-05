#################################
# Global Configuration
#################################

variable "environment" {
  description = "The Terraform backend environment e.g. public or usgovernment"
  type        = string
  default     = "public"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "hub-vnet"
}

variable "virtual_network_subscription_id" {
  description = "The subscription ID of the virtual network."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)
  default     = {}
}


