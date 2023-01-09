# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################################################
# VARIABLES                                      #
##################################################
variable "scope" {}
variable "mode" {}
variable "role_definition_name" {
  default = null
}
variable "role_definition_id" {
  default = null
}
variable "principal_id" {}
variable "skip_service_principal_aad_check" {
  default = false
}