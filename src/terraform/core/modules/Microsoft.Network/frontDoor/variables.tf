variable "resource_group_name" {
  description = "The name of the resource group the Bastion Host resides in"
  type        = string
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "frontdoor_name" {
  description = "The name of the Azure Front Door instance."
  type = string
  default = "afd"
}

variable "frontdoor_sku" {
  description = "The SKU of the Azure Front Door instance."
  type = string
  default = "Premium_AzureFrontDoor"
}
