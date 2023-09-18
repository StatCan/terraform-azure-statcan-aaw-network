resource "azurerm_resource_group" "network" {
  name     = "${var.prefix}-rg-network"
  location = var.location
  tags     = local.tags
}

# Generate a route table
resource "azurerm_route_table" "network" {
  name                = "${var.prefix}-rt"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  tags                = local.tags
}

resource "azurerm_route" "network_default" {
  name                   = "${var.prefix}-route-default"
  resource_group_name    = azurerm_resource_group.network.name
  route_table_name       = azurerm_route_table.network.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}
