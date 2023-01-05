locals {
  resourceToken    = "resource_token"
  nameToken        = "name_token"
  namingConvention = "${lower(var.org_prefix)}-${var.location}-${lower(var.deploy_environment)}-${local.nameToken}-${local.resourceToken}"

  /*
    NAMING CONVENTION
    Here we define a naming conventions for resources.

    First, we take `var.org_prefix`, `var.location`, and `var.deploy_environment` by variables.
    Then, using string interpolation "${}", we insert those values into a naming convention.
    Finally, we use the replace() function to replace the tokens with the actual resource name.

    For example, if we have a resource named "hub", we will replace the token "name_token" with "hub".
    Then, we will replace the token "resource_token" with "rg" to get the resource group name.
  */

  // RESOURCE NAME CONVENTIONS WITH ABBREVIATIONS
  resourceGroupNamingConvention        = replace(local.namingConvention, local.resourceToken, "rg")
  networkSecurityGroupNamingConvention = replace(local.namingConvention, local.resourceToken, "nsg")
  publicIpAddressNamingConvention      = replace(local.namingConvention, local.resourceToken, "pip")
  bastionHostNamingConvention          = replace(local.namingConvention, local.resourceToken, "bas")
  networkInterfaceNamingConvention     = replace(local.namingConvention, local.resourceToken, "nic")
  IpConfigurationNamingConvention      = replace(local.namingConvention, local.resourceToken, "ipconfig")
  virtualMachineNamingConvention       = replace(local.namingConvention, local.resourceToken, "vm")

  // BASTION NAMES
  bastionHostName                            = replace(local.bastionHostNamingConvention, local.nameToken, "hub")
  bastionHostPublicIPAddressName             = replace(local.publicIpAddressNamingConvention, local.nameToken, "bas")
  bastionNetworkInterfaceIpConfigurationName = replace(local.IpConfigurationNamingConvention, local.nameToken, "bas")
  linuxNetworkInterfaceName                  = replace(local.networkInterfaceNamingConvention, local.nameToken, "bas-linux")
  linuxNetworkInterfaceIpConfigurationName   = replace(local.IpConfigurationNamingConvention, local.nameToken, "bas-linux")
  windowsNetworkInterfaceName                = replace(local.networkInterfaceNamingConvention, local.nameToken, "bas-windows")
  windowsNetworkInterfaceIpConfigurationName = replace(local.IpConfigurationNamingConvention, local.nameToken, "bas-windows")
  bastionHostNetworkSecurityGroupName        = replace(local.networkSecurityGroupNamingConvention, local.nameToken, "bas")

  // BASTION VM NAMES
  linuxVmName   = replace(local.virtualMachineNamingConvention, local.nameToken, "bas-linux")
  windowsVmName = replace(local.virtualMachineNamingConvention, local.nameToken, "bas-windows")

  // BASTION VALUES
  bastionHostPublicIPAddressSkuName          = "Standard"
  bastionHostPublicIPAddressAllocationMethod = "Static"
}