resource "azurerm_network_security_group" "aks_system" {
  name                = "${var.prefix}-nsg-aks-system"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "aks_system" {
  subnet_id                 = azurerm_subnet.aks_system.id
  network_security_group_id = azurerm_network_security_group.aks_system.id
}

# Unclassified
resource "azurerm_network_security_group" "aks_user_unclassified" {
  name                = "${var.prefix}-nsg-aks-user-unclassified"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "aks_user_unclassified" {
  subnet_id                 = azurerm_subnet.aks_user_unclassified.id
  network_security_group_id = azurerm_network_security_group.aks_user_unclassified.id
}

resource "azurerm_network_security_rule" "aks_user_unclassified_deny_protected_b_outbound" {
  name                         = "deny-protected-b-outbound"
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Deny"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = concat(azurerm_subnet.aks_user_protected_b.address_prefixes, azurerm_subnet.data_protected_b.address_prefixes)
  resource_group_name          = azurerm_resource_group.network.name
  network_security_group_name  = azurerm_network_security_group.aks_user_unclassified.name
}

resource "azurerm_network_security_rule" "aks_user_unclassified_deny_protected_b_inbound" {
  name                        = "deny-protected-b-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = concat(azurerm_subnet.aks_user_protected_b.address_prefixes, azurerm_subnet.data_protected_b.address_prefixes)
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.aks_user_unclassified.name
}

resource "azurerm_network_security_group" "data_unclassified" {
  name                = "${var.prefix}-nsg-data-unclassified"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "data_unclassified" {
  subnet_id                 = azurerm_subnet.data_unclassified.id
  network_security_group_id = azurerm_network_security_group.data_unclassified.id
}

resource "azurerm_network_security_rule" "data_unclassified_deny_protected_b_outbound" {
  name                         = "deny-protected-b-outbound"
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Deny"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = concat(azurerm_subnet.aks_user_protected_b.address_prefixes, azurerm_subnet.data_protected_b.address_prefixes)
  resource_group_name          = azurerm_resource_group.network.name
  network_security_group_name  = azurerm_network_security_group.data_unclassified.name
}

resource "azurerm_network_security_rule" "data_unclassified_deny_protected_b_inbound" {
  name                        = "deny-protected-b-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = concat(azurerm_subnet.aks_user_protected_b.address_prefixes, azurerm_subnet.data_protected_b.address_prefixes)
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.data_unclassified.name
}

# Protected B
resource "azurerm_network_security_group" "aks_user_protected_b" {
  name                = "${var.prefix}-nsg-aks-user-protected-b"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "aks_user_protected_b" {
  subnet_id                 = azurerm_subnet.aks_user_protected_b.id
  network_security_group_id = azurerm_network_security_group.aks_user_protected_b.id
}

resource "azurerm_network_security_rule" "aks_user_protected_b_deny_unclassified_outbound" {
  name                         = "deny-unclassified-outbound"
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Deny"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = concat(azurerm_subnet.aks_user_unclassified.address_prefixes, azurerm_subnet.data_unclassified.address_prefixes)
  resource_group_name          = azurerm_resource_group.network.name
  network_security_group_name  = azurerm_network_security_group.aks_user_protected_b.name
}

resource "azurerm_network_security_rule" "aks_user_protected_b_deny_unclassified_inbound" {
  name                        = "deny-unclassified-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = concat(azurerm_subnet.aks_user_unclassified.address_prefixes, azurerm_subnet.data_unclassified.address_prefixes)
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.aks_user_protected_b.name
}

resource "azurerm_network_security_group" "data_protected_b" {
  name                = "${var.prefix}-nsg-data-protected-b"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "data_protected_b" {
  subnet_id                 = azurerm_subnet.data_protected_b.id
  network_security_group_id = azurerm_network_security_group.data_protected_b.id
}

resource "azurerm_network_security_rule" "data_protected_b_deny_unclassified_outbound" {
  name                         = "deny-unclassified-outbound"
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Deny"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = concat(azurerm_subnet.aks_user_unclassified.address_prefixes, azurerm_subnet.data_unclassified.address_prefixes)
  resource_group_name          = azurerm_resource_group.network.name
  network_security_group_name  = azurerm_network_security_group.data_protected_b.name
}

resource "azurerm_network_security_rule" "data_protected_b_deny_unclassified_inbound" {
  name                        = "deny-unclassified-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = concat(azurerm_subnet.aks_user_unclassified.address_prefixes, azurerm_subnet.data_unclassified.address_prefixes)
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.data_protected_b.name
}
