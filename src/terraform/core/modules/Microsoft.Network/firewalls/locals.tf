#---------------------------------
# Local declarations
#---------------------------------
locals {  
  fw_nat_rules = { for idx, rule in var.firewall_nat_rules : rule.name => {
    idx : idx,
    rule : rule,
    }
  }

  fw_network_rules = { for idx, rule in var.firewall_network_rules : rule.name => {
    idx : idx,
    rule : rule,
    }
  }

  fw_application_rules = { for idx, rule in var.firewall_application_rules : rule.name => {
    idx : idx,
    rule : rule,
    }
  }
}