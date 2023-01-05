# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a SQL Database to the Hub Network
DESCRIPTION: The following components will be options in this deployment
                SQL Database
                SQL Server
AUTHOR/S: jspinella
*/

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
