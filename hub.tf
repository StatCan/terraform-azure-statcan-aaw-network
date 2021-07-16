locals {
  hub_network = "${var.start.first}.${var.start.second}"
}

resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}-vnet-hub"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  tags                = var.tags

  address_space = ["${local.hub_network}.0.0/16"]

  ddos_protection_plan {
    id     = var.ddos_protection_plan_id
    enable = true
  }
}

resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name

  address_prefixes = ["${local.hub_network}.255.192/26"]
}

# Peer with the spoke vnets
resource "azurerm_virtual_network_peering" "hub_aks" {
  name = "${var.prefix}-peer-hub-aks"

  resource_group_name       = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.aks.id

  allow_forwarded_traffic = true
  allow_gateway_transit   = true
  use_remote_gateways     = false
}

resource "azurerm_virtual_network_peering" "hub_data" {
  name = "${var.prefix}-peer-hub-data"

  resource_group_name       = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.data.id

  allow_forwarded_traffic = true
  allow_gateway_transit   = true
  use_remote_gateways     = false
}
