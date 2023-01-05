# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "budget" {
  source = "../../modules/Microsoft.Consumption/subscription"
  
  name            = var.name
  subscription_id = var.subscription_id

  amount     = var.budget_amount
  time_grain = var.budget_time

  time_period {
    start_date = var.budget_start_date
    end_date   = var.budget_end_date
  }

  notification = var.budget_notification

}
