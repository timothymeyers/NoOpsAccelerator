# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

locals {
  default_tags = var.default_tags_enabled ? {
    env           = var.deploy_environment
  } : {}
}
