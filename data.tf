locals {
  data_network = "${var.start.first}.${var.start.second + 2}"

  # Defines the Service Endpoints to be available on the VNets
  service_endpoints = ["Microsoft.ContainerRegistry", "Microsoft.Storage", "Microsoft.Sql", "Microsoft.KeyVault"]
}

resource "azurerm_virtual_network" "data" {
  name                = "${var.prefix}-vnet-data"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  tags                = var.tags

  address_space = ["${local.data_network}.0.0/16"]
  dns_servers   = [azurerm_firewall.firewall.ip_configuration[0].private_ip_address]
}

# Peer the virtual network with the hub
resource "azurerm_virtual_network_peering" "data_hub" {
  name = "${var.prefix}-peer-data-hub"

  resource_group_name       = azurerm_virtual_network.data.resource_group_name
  virtual_network_name      = azurerm_virtual_network.data.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = false
}


##
## SUBNETS
##
resource "azurerm_subnet" "data_system" {
  name                 = "${var.prefix}-snet-data-system"
  resource_group_name  = azurerm_virtual_network.data.resource_group_name
  virtual_network_name = azurerm_virtual_network.data.name

  address_prefixes = ["${local.data_network}.0.0/22"]
}

resource "azurerm_subnet" "data_unclassified" {
  name                 = "${var.prefix}-snet-data-unclassified"
  resource_group_name  = azurerm_virtual_network.data.resource_group_name
  virtual_network_name = azurerm_virtual_network.data.name

  address_prefixes = ["${local.data_network}.4.0/22"]
}

resource "azurerm_subnet" "data_protected_b" {
  name                 = "${var.prefix}-snet-data-protected-b"
  resource_group_name  = azurerm_virtual_network.data.resource_group_name
  virtual_network_name = azurerm_virtual_network.data.name

  address_prefixes = ["${local.data_network}.8.0/22"]
}

# Associate the subnets with the route table
resource "azurerm_subnet_route_table_association" "data_system" {
  subnet_id      = azurerm_subnet.data_system.id
  route_table_id = azurerm_route_table.network.id
}
resource "azurerm_subnet_route_table_association" "data_unclassified" {
  subnet_id      = azurerm_subnet.data_unclassified.id
  route_table_id = azurerm_route_table.network.id
}

resource "azurerm_subnet_route_table_association" "data_protected_b" {
  subnet_id      = azurerm_subnet.data_protected_b.id
  route_table_id = azurerm_route_table.network.id
}
