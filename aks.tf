locals {
  aks_network = "${var.start.first}.${var.start.second + 1}"
}

resource "azurerm_virtual_network" "aks" {
  name                = "${var.prefix}-vnet-aks"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  tags                = var.tags

  address_space = ["${local.aks_network}.0.0/16"]
  dns_servers   = [azurerm_firewall.firewall.ip_configuration[0].private_ip_address]
}

# Peer the virtual network with the hub
resource "azurerm_virtual_network_peering" "aks_hub" {
  name = "${var.prefix}-peer-aks-hub"

  resource_group_name       = azurerm_virtual_network.aks.resource_group_name
  virtual_network_name      = azurerm_virtual_network.aks.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = false
}

##
## SUBNETS
##
resource "azurerm_subnet" "aks_load_balancers" {
  name                 = "${var.prefix}-snet-aks-load-balancer"
  resource_group_name  = azurerm_virtual_network.aks.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks.name

  address_prefixes = ["${local.aks_network}.254.0/23"]
}

resource "azurerm_subnet" "aks_cloud_main_system" {
  name                 = "${var.prefix}-snet-aks-cloud-main-system"
  resource_group_name  = azurerm_virtual_network.aks.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks.name

  address_prefixes = ["${local.aks_network}.253.128/25"]

  service_endpoints = local.service_endpoints
}

resource "azurerm_subnet" "aks_system" {
  name                 = "${var.prefix}-snet-aks-system"
  resource_group_name  = azurerm_virtual_network.aks.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks.name

  address_prefixes = ["${local.aks_network}.0.0/18"]

  service_endpoints = local.service_endpoints
}

resource "azurerm_subnet" "aks_user_unclassified" {
  name                 = "${var.prefix}-snet-aks-user-unclassified"
  resource_group_name  = azurerm_virtual_network.aks.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks.name

  address_prefixes = ["${local.aks_network}.64.0/18"]

  service_endpoints = local.service_endpoints
}

resource "azurerm_subnet" "aks_user_protected_b" {
  name                 = "${var.prefix}-snet-aks-user-protected-b"
  resource_group_name  = azurerm_virtual_network.aks.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks.name

  address_prefixes = ["${local.aks_network}.128.0/18"]

  service_endpoints = local.service_endpoints
}

# Associate the route table with the subnets
resource "azurerm_subnet_route_table_association" "aks_load_balancers" {
  subnet_id      = azurerm_subnet.aks_load_balancers.id
  route_table_id = azurerm_route_table.network.id
}

resource "azurerm_subnet_route_table_association" "aks_system" {
  subnet_id      = azurerm_subnet.aks_system.id
  route_table_id = azurerm_route_table.network.id
}

resource "azurerm_subnet_route_table_association" "aks_user_unclassified" {
  subnet_id      = azurerm_subnet.aks_user_unclassified.id
  route_table_id = azurerm_route_table.network.id
}

resource "azurerm_subnet_route_table_association" "aks_user_protected_b" {
  subnet_id      = azurerm_subnet.aks_user_protected_b.id
  route_table_id = azurerm_route_table.network.id
}
