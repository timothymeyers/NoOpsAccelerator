# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#############################################
# DATA                                      #
#############################################
data "azurerm_cosmosdb_account" "this" { 
  name                = var.cosmosdb_account_name
  resource_group_name = var.resource_group_name  
}