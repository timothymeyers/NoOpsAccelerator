# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurerm_client_config" "current_client" {}

resource "azurerm_consumption_budget_subscription" "budget" {
  name            = var.name
  subscription_id = data.azurerm_subscription.current_client.id

  amount     = var.budget_amount
  time_grain = var.budget_time

  time_period {
    start_date = var.budget_start_date
    end_date   = var.budget_end_date
  }

  notification = var.budget_notification

}