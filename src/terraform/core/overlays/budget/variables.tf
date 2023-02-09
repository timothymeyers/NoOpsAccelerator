# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "name" {
  description = "The name of the subnet "
  type        = string
}

variable "resource_group_name" {
  description = "The name of the subnet's resource group "
  type        = string
}

variable "budget_amount" {
  description = "The amount of the budget."
  type        = string
}

variable "budget_time" {
  description = "The time grain of the budget. Possible values are: Monthly, Quarterly, Annually."
  type        = string
  default = "Monthly"
}

variable "budget_start_date" {
  description = "The start date of the budget. If not set, the budget is recurring."
  type        = string
}

variable "budget_end_date" {
  description = "The end date of the budget. If not set, the budget is recurring."
  type        = string
}

variable "budget_notification" {
  description = "The notification of the budget."
  type        = list(object({
    operator  = string
    threshold = number
    contact_emails = list(string)
    contact_groups = list(string)
    contact_roles = list(string)
  }))
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}
