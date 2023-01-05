# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a Container Instance to the an Network
DESCRIPTION: The following components will be options in this deployment
                Container Instance
                User Assigned Managed Identity
                private DNS Zone
                private endpoint
                diagnostic setting
AUTHOR/S: jspinella
*/

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
