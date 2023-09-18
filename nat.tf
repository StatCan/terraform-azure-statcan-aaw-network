resource "azurerm_public_ip" "egress" {
  name                = "${var.prefix}-pip-egress"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags

  allocation_method = "Static"
  sku               = "Standard"

  zones = var.availability_zones
}

resource "azurerm_nat_gateway" "nat_gateway" {
  name                    = "${var.prefix}-ngw"
  location                = var.location
  resource_group_name     = azurerm_resource_group.network.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = local.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_egress" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.egress.id
}

resource "azurerm_subnet_nat_gateway_association" "firewall_nat" {
  subnet_id      = azurerm_subnet.hub_firewall.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}
