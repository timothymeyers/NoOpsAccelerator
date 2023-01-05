
################################
### GLOBAL VARIABLES         ###
################################

resource "random_id" "uniqueString" {
  keepers = {
    # Generate a new id each time we change resourePrefix variable
    org_prefix = var.required.org_prefix
    subid      = var.hub_subid
  }
  byte_length = 8
}

locals {
  firewall_premium_environments = ["public", "usgovernment"] # terraform azurerm environments where Azure Firewall Premium is supported

  // Central Logging
  centrals_diagnostic_log_categories = ["Administrative", "Security", "ServiceHealth", "Alert", "Recommendation", "Policy", "Autoscale", "ResourceHealth"]

  # RESOURCE PREFIXES
  resourceToken    = "resource_token"
  nameToken        = "name_token"
  namingConvention = "${lower(var.required.org_prefix)}-${var.location}-${lower(var.required.deploy_environment)}-${local.nameToken}-${local.resourceToken}"

  /*
    NAMING CONVENTION
    Here we define a naming conventions for resources.

    First, we take `var.required.org_prefix`, `var.location`, and `var.required.deploy_environment` by variables.
    Then, using string interpolation "${}", we insert those values into a naming convention.
    Finally, we use the replace() function to replace the tokens with the actual resource name.

    For example, if we have a resource named "hub", we will replace the token "name_token" with "hub".
    Then, we will replace the token "resource_token" with "rg" to get the resource group name.
  */

  // RESOURCE NAME CONVENTIONS WITH ABBREVIATIONS
  resourceGroupNamingConvention         = replace(local.namingConvention, local.resourceToken, "rg")
  storageAccountNamingConvention        = lower("${var.required.org_prefix}st${local.nameToken}unique_storage_token")
  subnetNamingConvention                = replace(local.namingConvention, local.resourceToken, "snet")
  virtualNetworkNamingConvention        = replace(local.namingConvention, local.resourceToken, "vnet")
  networkSecurityGroupNamingConvention  = replace(local.namingConvention, local.resourceToken, "nsg")
  firewallNamingConvention              = replace(local.namingConvention, local.resourceToken, "afw")
  firewallPolicyNamingConvention        = replace(local.namingConvention, local.resourceToken, "afwp")
  publicIpAddressNamingConvention       = replace(local.namingConvention, local.resourceToken, "pip")
  logAnalyticsWorkspaceNamingConvention = replace(local.namingConvention, local.resourceToken, "log")
  keyVaultNamingConvention              = replace(local.namingConvention, local.resourceToken, "kv")

  // LOGGING NAMES
  loggingName                        = "logging"
  loggingShortName                   = "log"
  loggingResourceGroupName           = replace(local.resourceGroupNamingConvention, local.nameToken, local.loggingName)
  loggingLogStorageAccountShortName  = replace(local.storageAccountNamingConvention, local.nameToken, local.loggingShortName)
  loggingLogStorageAccountUniqueName = replace(local.loggingLogStorageAccountShortName, "unique_storage_token", "${random_id.uniqueString.hex}")
  loggingLogStorageAccountName       = format("%.24s", lower(replace(local.loggingLogStorageAccountUniqueName, "/[[:^alnum:]]/", "")))

  // LOG ANALYTICS NAMES

  logAnalyticsWorkspaceName = replace(local.logAnalyticsWorkspaceNamingConvention, local.nameToken, local.loggingName)


  // hub NAMES
  hubName                        = "hub"
  hubShortName                   = "hub"
  hubResourceGroupName           = replace(local.resourceGroupNamingConvention, local.nameToken, local.hubName)
  hubLogStorageAccountShortName  = replace(local.storageAccountNamingConvention, local.nameToken, local.hubShortName)
  hubLogStorageAccountUniqueName = replace(local.hubLogStorageAccountShortName, "unique_storage_token", "${random_id.uniqueString.hex}")
  hubLogStorageAccountName       = format("%.24s", lower(replace(local.hubLogStorageAccountUniqueName, "/[[:^alnum:]]/", "")))
  hubVirtualNetworkName          = replace(local.virtualNetworkNamingConvention, local.nameToken, local.hubName)
  hubNetworkSecurityGroupName    = replace(local.networkSecurityGroupNamingConvention, local.nameToken, local.hubName)
  hubSubnetName                  = replace(local.subnetNamingConvention, local.nameToken, local.hubName)

  // ROUTETABLE VALUES
  hubRouteTableName = "${local.hubSubnetName}-routetable"

  // FIREWALL NAMES

  firewallName                          = replace(local.firewallNamingConvention, local.nameToken, local.hubName)
  firewallPolicyName                    = replace(local.firewallPolicyNamingConvention, local.nameToken, local.hubName)
  firewallClientPublicIPAddressName     = replace(local.publicIpAddressNamingConvention, local.nameToken, "afw-client")
  firewallManagementPublicIPAddressName = replace(local.publicIpAddressNamingConvention, local.nameToken, "afw-mgmt")

  // FIREWALL VALUES

  firewallPublicIPAddressSkuName   = "Standard"
  firewallPublicIpAllocationMethod = "Static"

  // Ops NAMES
  opsName                        = "operations"
  opsShortName                   = "ops"
  opsResourceGroupName           = replace(local.resourceGroupNamingConvention, local.nameToken, local.opsName)
  opsLogStorageAccountShortName  = replace(local.storageAccountNamingConvention, local.nameToken, local.opsShortName)
  opsLogStorageAccountUniqueName = replace(local.opsLogStorageAccountShortName, "unique_storage_token", "${random_id.uniqueString.hex}")
  opsLogStorageAccountName       = format("%.24s", lower(replace(local.opsLogStorageAccountUniqueName, "/[[:^alnum:]]/", "")))
  opsVirtualNetworkName          = replace(local.virtualNetworkNamingConvention, local.nameToken, local.opsName)
  opsNetworkSecurityGroupName    = replace(local.networkSecurityGroupNamingConvention, local.nameToken, local.opsName)
  opsSubnetName                  = replace(local.subnetNamingConvention, local.nameToken, local.opsName)

  // ROUTETABLE VALUES
  opsRouteTableName = "${local.opsSubnetName}-routetable"

  // IDENTITY NAMES
  idName                        = "identity"
  idShortName                   = "id"
  idResourceGroupName           = replace(local.resourceGroupNamingConvention, local.nameToken, local.idName)
  idLogStorageAccountShortName  = replace(local.storageAccountNamingConvention, local.nameToken, local.idShortName)
  idLogStorageAccountUniqueName = replace(local.idLogStorageAccountShortName, "unique_storage_token", "${random_id.uniqueString.hex}")
  idLogStorageAccountName       = format("%.24s", lower(replace(local.idLogStorageAccountUniqueName, "/[[:^alnum:]]/", "")))
  idVirtualNetworkName          = replace(local.virtualNetworkNamingConvention, local.nameToken, local.idName)
  idNetworkSecurityGroupName    = replace(local.networkSecurityGroupNamingConvention, local.nameToken, local.idName)
  idSubnetName                  = replace(local.subnetNamingConvention, local.nameToken, local.idName)

  // SHARED SERVICEs NAMES
  svcsName                        = "sharedservices"
  svcsShortName                   = "svcs"
  svcsResourceGroupName           = replace(local.resourceGroupNamingConvention, local.nameToken, local.svcsName)
  svcsLogStorageAccountShortName  = replace(local.storageAccountNamingConvention, local.nameToken, local.svcsShortName)
  svcsLogStorageAccountUniqueName = replace(local.svcsLogStorageAccountShortName, "unique_storage_token", "${random_id.uniqueString.hex}")
  svcsLogStorageAccountName       = format("%.24s", lower(replace(local.svcsLogStorageAccountUniqueName, "/[[:^alnum:]]/", "")))
  svcsVirtualNetworkName          = replace(local.virtualNetworkNamingConvention, local.nameToken, local.svcsName)
  svcsNetworkSecurityGroupName    = replace(local.networkSecurityGroupNamingConvention, local.nameToken, local.svcsName)
  svcsSubnetName                  = replace(local.subnetNamingConvention, local.nameToken, local.svcsName)

  // netart NAMES
  netartName                        = "netart"
  netartShortName                   = "netart"
  netartResourceGroupName           = replace(local.resourceGroupNamingConvention, local.nameToken, local.netartName)
  netartLogStorageAccountShortName  = replace(local.storageAccountNamingConvention, local.nameToken, local.netartShortName)
  netartLogStorageAccountUniqueName = replace(local.netartLogStorageAccountShortName, "unique_storage_token", "${random_id.uniqueString.hex}")
  netartLogStorageAccountName       = format("%.24s", lower(replace(local.netartLogStorageAccountUniqueName, "/[[:^alnum:]]/", "")))
  netartKeyVaultShortName           = replace(local.keyVaultNamingConvention, local.nameToken, local.netartShortName)
  netartKeyVaultUniqueName          = replace(local.netartKeyVaultShortName, "unique_storage_token", "${random_id.uniqueString.hex}")
  netartKeyVaultName                = format("%.24s", lower(replace(local.netartKeyVaultUniqueName, "/[[:^alnum:]]/", "")))
}
