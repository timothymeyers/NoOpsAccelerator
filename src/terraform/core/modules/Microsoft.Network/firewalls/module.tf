# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------
# Public IP resources for Azure Firewall
#------------------------------------------
resource "azurerm_public_ip_prefix" "fw-pref" {
  name                = lower("${var.firewall_config.name}-prefix")
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix_length       = var.public_ip_prefix_length
  tags                = merge({ "ResourceName" = lower("${var.firewall_config.name}-prefix") }, var.tags, )
}

module "mod_firewall_client_publicIP_address" {
  source = "../publicIPAddress"

  // Global Settings
  location = var.location

  // PIP Client Parameters
  public_ip_address_name = lower("${var.firewall_client_publicIP_address_name}")
  resource_group_name    = var.resource_group_name

  // PIP Client Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Network Firewall Resource: %s", var.firewall_client_publicIP_address_name)
  }) # Tags to be applied to all resources
}

module "mod_firewall_management_publicIP_address" {
  count  = var.enable_forced_tunneling ? 1 : 0
  source = "../publicIPAddress"

  // Global Settings
  location = var.location

  // PIP Management Parameters
  public_ip_address_name = lower("${var.firewall_management_publicIP_address_name}")
  resource_group_name    = var.resource_group_name

  // PIP Management Tags
  tags = merge(var.tags, {
    DeployedBy  = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Network Firewall Resource: %s", var.firewall_management_publicIP_address_name)
  }) # Tags to be applied to all resources
}

#-----------------
# Azure Firewall 
#-----------------
resource "azurerm_firewall" "fw" {
  name                = format("%s", var.firewall_config.name)
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.firewall_config.sku_name
  sku_tier            = var.firewall_config.sku_tier
  # firewall_policy_id  = var.firewall_policy != null ? azurerm_firewall_policy.fw-policy.0.id : null
  dns_servers       = var.firewall_config.dns_servers
  private_ip_ranges = var.firewall_config.private_ip_ranges
  threat_intel_mode = lookup(var.firewall_config, "threat_intel_mode", "Alert")
  zones             = var.firewall_config.zones
  tags              = merge({ "ResourceName" = format("%s", var.firewall_config.name) }, var.tags, )

  ip_configuration {  
      name                 = lower("${var.firewall_config.name}-ipconfig")
      subnet_id            = var.client_subnet_id
      public_ip_address_id = module.mod_firewall_client_publicIP_address.id
  }

  dynamic "management_ip_configuration" {
    for_each = var.enable_forced_tunneling ? [1] : []
    content {
      name                 = lower("${var.firewall_config.name}-forced-tunnel")
      subnet_id            = var.management_subnet_id
      public_ip_address_id = module.mod_firewall_management_publicIP_address[0].id
    }
  }

  dynamic "virtual_hub" {
    for_each = var.virtual_hub != null ? [var.virtual_hub] : []
    content {
      virtual_hub_id  = virtual_hub.value.virtual_hub_id
      public_ip_count = virtual_hub.value.public_ip_count
    }
  }
}


#----------------------------------------------
# Azure Firewall Network/Application/NAT Rules 
#----------------------------------------------
resource "azurerm_firewall_application_rule_collection" "fw_app" {
  for_each            = local.fw_application_rules
  name                = lower(format("fw-app-rule-%s-${var.firewall_config.name}-${var.location}", each.key))
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group_name
  priority            = 100 * (each.value.idx + 1)
  action              = each.value.rule.action

  rule {
    name             = each.key
    description      = each.value.rule.description
    source_addresses = each.value.rule.source_addresses
    source_ip_groups = each.value.rule.source_ip_groups
    fqdn_tags        = each.value.rule.fqdn_tags
    target_fqdns     = each.value.rule.target_fqdns

    protocol {
      type = each.value.rule.protocol.type
      port = each.value.rule.protocol.port
    }
  }
}


resource "azurerm_firewall_network_rule_collection" "fw" {
  for_each            = local.fw_network_rules
  name                = lower(format("fw-net-rule-%s-${var.firewall_config.name}-${var.location}", each.key))
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group_name
  priority            = 100 * (each.value.idx + 1)
  action              = each.value.rule.action

  rule {
    name                  = each.key
    description           = each.value.rule.description
    source_addresses      = each.value.rule.source_addresses
    destination_ports     = each.value.rule.destination_ports
    destination_addresses = each.value.rule.destination_addresses
    destination_fqdns     = each.value.rule.destination_fqdns
    protocols             = each.value.rule.protocols
  }
}

resource "azurerm_firewall_nat_rule_collection" "fw" {
  for_each            = local.fw_nat_rules
  name                = lower(format("fw-nat-rule-%s-${var.firewall_config.name}-${var.location}", each.key))
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group_name
  priority            = 100 * (each.value.idx + 1)
  action              = each.value.rule.action

  rule {
    name                  = each.key
    description           = each.value.rule.description
    source_addresses      = each.value.rule.source_addresses
    destination_ports     = each.value.rule.destination_ports
    destination_addresses = each.value.rule.destination_addresses
    protocols             = each.value.rule.protocols
    translated_address    = each.value.rule.translated_address
    translated_port       = each.value.rule.translated_port
  }
}
