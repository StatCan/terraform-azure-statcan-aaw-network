locals {
  hub_network = "${var.start.first}.${var.start.second}"
}

resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}-vnet-hub"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  tags                = local.tags

  address_space = ["${local.hub_network}.0.0/16"]

  ddos_protection_plan {
    id     = var.ddos_protection_plan_id
    enable = true
  }
}

# Generate a route table
resource "azurerm_route_table" "firewall" {
  name                = "${var.prefix}-rt-firewall"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  tags                = local.tags

  # Disable BGP route propagation so that we don't
  # learn the routes of on-prem resources.
  disable_bgp_route_propagation = true
}

resource "azurerm_route" "firewall_default" {
  name                = "${var.prefix}-route-default"
  resource_group_name = azurerm_resource_group.network.name
  route_table_name    = azurerm_route_table.firewall.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

resource "azurerm_route" "firewall_cloud_main" {
  count                  = var.cloud_main_address_prefix == null || var.cloud_main_firewall_ip == null ? 0 : 1
  name                   = "${var.prefix}-route-cloud-main"
  resource_group_name    = azurerm_resource_group.network.name
  route_table_name       = azurerm_route_table.firewall.name
  address_prefix         = var.cloud_main_address_prefix
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.cloud_main_firewall_ip
}

resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name

  address_prefixes = ["${local.hub_network}.255.192/26"]
}

# Associate the route table with the subnets
resource "azurerm_subnet_route_table_association" "hub_firewall" {
  subnet_id      = azurerm_subnet.hub_firewall.id
  route_table_id = azurerm_route_table.firewall.id
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
