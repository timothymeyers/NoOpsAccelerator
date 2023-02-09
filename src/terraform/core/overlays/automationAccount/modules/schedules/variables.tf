# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "name" {
  description = "(Required) Specifies the name of the Automation Account. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "frequency" {
  description = "(Required) The frequency of the schedule. Possible values are `OneTime`, `Day`, `Hour`, `Week`, `Month`, `MonthWeek`, `Year`."
  type        = string
}

variable "interval" {
  description = "(Optional) The interval of the schedule. Possible values are `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `11`, `12`, `13`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`, `25`, `26`, `27`, `28`, `29`, `30`, `31`, `32`, `33`, `34`, `35`, `36`, `37`, `38`, `39`, `40`, `41`, `42`, `43`, `44`, `45`, `46`, `47`, `48`, `49`, `50`, `51`, `52`, `53`, `54`, `55`, `56`, `57`, `58`, `59`, `60`."
  type        = number
}

variable "timezone" {
  description = "(Optional) The timezone of the schedule."
  type        = string
}

variable "start_time" {
  description = "(Optional) The start time of the schedule."
  type        = string
}

variable "description" {
  description = "(Optional) The description of the schedule."
  type        = string
}

variable "week_days" {
  description = "(Optional) The week days of the schedule. Possible values are `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, `Sunday`."
  type        = list(string)
}

variable "month_days" {
  description = "(Optional) The month days of the schedule. Possible values are `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `11`, `12`, `13`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`, `25`, `26`, `27`, `28`, `29`, `30`, `31`."
  type        = list(number)
}

variable "monthly_occurrences" {
  description = "(Optional) A `monthly_occurrence` block as defined below."
  type        = list(any)
}

variable "automation_account_name" {
  description = "(Required) The name of the Automation Account where to create the schedule."
  type        = string
}

variable "tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}

