locals {
  consumers = { for hc in flatten([for h in var.hubs :
    [for c in h.consumers : {
      hub  = h.name
      name = c
  }]]) : format("%s.%s", hc.hub, hc.name) => hc }

  keys = { for hk in flatten([for h in var.hubs :
    [for k in h.keys : {
      hub = h.name
      key = k
  }]]) : format("%s.%s", hk.hub, hk.key.name) => hk }

  hubs                = { for h in var.hubs : h.name => h }
  authorization_rules = { for a in var.authorization_rules : a.name => a }
}