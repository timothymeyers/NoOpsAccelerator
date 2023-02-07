# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This module deploys an automation schedule to the specified resource group.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule

resource "azurerm_automation_schedule" "automation_schedule" {
  name                    = var.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  frequency               = var.frequency
  interval                = try(var.interval, null)
  timezone                = try(var.timezone, null)
  start_time              = try(var.start_time, null)
  description             = try(var.description, null)
  week_days               = try(var.week_days, null)
  month_days              = try(var.month_days, null)

  dynamic "monthly_occurrence" {
    for_each = try(var.monthly_occurrences, null) == null ? [] : [1]

    content {
      day        = monthly_occurrence.day
      occurrence = monthly_occurrence.occurrence
    }
  }
}
