variable "resource_group_name" {
  description = "(Required) Specifies the resource group name"
  type        = string
}

variable "location" {
  description = "(Required) Specifies the location of the log analytics workspace"
  type        = string
}

variable "workspace_name" {
  type        = string
  description = "The name of the Log Analytics Workspace that will link to the Sentinel solution"
}

variable "workspace_resource_id" {
  type        = string
  description = "The resource id of the Log Analytics Workspace that will link to the Sentinel solution"
}

variable "product" {
  type        = string
  description = "The product name of the Log Analytics Workspace that will link to the Sentinel solution"
}

variable "publisher" {
  type        = string
  description = "The publisher name of the Log Analytics Workspace that will link to the Sentinel solution"
}

variable "solution_name" {
  type        = string
  description = "The solution name of the Log Analytics Workspace that will link to the Sentinel solution"
}

variable "promotion_code" {
  type        = string
  description = "(Optional) The promotion code of the Log Analytics Workspace that will link to the Sentinel solution"
  default     = ""
}

variable "tags" {
  description = "(Optional) Specifies the tags of the log analytics workspace"
  type        = map(any)
  default     = {}
}
