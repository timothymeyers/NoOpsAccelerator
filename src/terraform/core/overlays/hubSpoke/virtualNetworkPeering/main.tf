# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the Hub Network Peering to Spokes based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              hubToSpokePeering
              SpokeTohubPeering
AUTHOR/S: jspinella
*/

module "hub_to_spoke" {
  source = "../../../modules/Microsoft.Network/virtualNetworks/virtualNetworkPeering"

  peering_name_1_to_2 = var.peering_name_1_to_2
  peering_name_2_to_1 = var.peering_name_2_to_1

  vnet_1_id = var.vnet_1_id
  vnet_1_name = var.vnet_1_name
  vnet_1_rg = var.vnet_1_rg

  vnet_2_id = var.vnet_2_id
  vnet_2_name = var.vnet_2_name
  vnet_2_rg = var.vnet_2_rg

  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic = var.allow_forwarded_traffic
  allow_gateway_transit = var.allow_gateway_transit
  use_remote_gateways = var.use_remote_gateways
}
