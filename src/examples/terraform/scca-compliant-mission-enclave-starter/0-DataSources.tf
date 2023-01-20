##################
### DATA       ###
##################

# Contributor role
data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}