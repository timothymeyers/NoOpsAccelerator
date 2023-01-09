required = {
  org_prefix         = "anoa"
  deploy_environment = "dev"
}

tags = {
  "Organization" : "anoa",
  "Region" : "usgovvirginia",
  "DeployEnvironment" : "dev"
}

# The Terraform backend environment e.g. public or usgovernment
environment = "usgovernment"

# The metadata host for the Azure Cloud e.g. management.azure.com or management.usgovcloudapi.net.
metadata_host = "https://management.usgovcloudapi.net"

# The Azure region for most Platform LZ resources. e.g. for government usgovvirginia
location = "usgovvirginia"

# Map of services you woul like to enable during a deployment.
enable_services = {
  // Enable Identity services
  deploy_custom_roles = true // true to deploy custom roles

  // Enable Bastion services
  enable_bastion_hosts             = true // true to create a bastion host
  bastion_linux_virtual_machines   = true // true to create a linux bastion host
  bastion_windows_virtual_machines = true // true to create a windows bastion host

  // Enable Network services
  enable_network_diagnostics = true  // true to create a diagnostics settings for the network
  enable_bastion_diagnostics = true  // true to create a diagnostics settings for the bastion host
  enable_network_artifacts   = false // true to create a network artifacts for operations
  enable_resource_locks      = false // true to enable resource locks
  enable_firewall            = true  // true to create the Azure Firewall
  enable_forced_tunneling    = true  // true to enable forced tunneling
  enable_vpn_gateway         = true  // true to create the Azure VPN Gateway

  // Enable Security services
  enable_azure_security_center   = false // true to deploy Azure Security Center
  enable_security_center_setting = false // true to enable the Azure Security Center Setting    

  // Enable Monitoring services    
  deploy_laws_solutions = true // true to deploy Azure Monitor Solutions
  deploy_sentinel       = true // true to deploy Azure Sentinel  
}

# The ID for the root management group
root_management_group_id = "anoa"

# The display name for the root management group.
root_management_group_display_name = "anoa"

# If set to true, will disable telemetry for the modules. See https://aka.ms/anoa-terraform-telemetry.
disable_telemetry = true

# The list of management groups to be created under the root.
management_groups = {
  "platform" = {
    display_name               = "platforms"
    management_group_name      = "platforms"
    parent_management_group_id = "anoa"
    subscription_ids           = []
  },
  "workloads" = {
    display_name               = "workloads"
    management_group_name      = "workloads"
    parent_management_group_id = "anoa"
    subscription_ids           = []
  },
  "sandbox" = {
    display_name               = "sandbox"
    management_group_name      = "sandbox"
    parent_management_group_id = "anoa"
    subscription_ids           = []
  },
  "identity" = {
    display_name               = "identity"
    management_group_name      = "identity"
    parent_management_group_id = "platforms"
    subscription_ids           = []
  },
  "transport" = {
    display_name               = "transport"
    management_group_name      = "transport"
    parent_management_group_id = "platforms"
    subscription_ids           = []
  },
  "management" = {
    display_name               = "management"
    management_group_name      = "management"
    parent_management_group_id = "platforms"
    subscription_ids           = []
  },
  "internal" = {
    display_name               = "internal"
    management_group_name      = "internal"
    parent_management_group_id = "workloads"
    subscription_ids           = []
  },
  "partners" = {
    display_name               = "partners"
    management_group_name      = "partners"
    parent_management_group_id = "workloads"
    subscription_ids           = []
  }
}
