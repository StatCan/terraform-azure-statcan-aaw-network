output "hub_virtual_network_id" {
  value = azurerm_virtual_network.hub.id
}

output "hub_virtual_network_name" {
  value = azurerm_virtual_network.hub.name
}

output "hub_virtual_network_resource_group_name" {
  value = azurerm_virtual_network.hub.resource_group_name
}

output "aks_virtual_network_id" {
  value = azurerm_virtual_network.aks.id
}

output "aks_system_address_space" {
  value = azurerm_virtual_network.aks.address_space
}

output "aks_load_balancers_subnet_id" {
  value = azurerm_subnet.aks_load_balancers.id
}

output "aks_load_balancers_subnet_name" {
  value = azurerm_subnet.aks_load_balancers.name
}

output "aks_load_balancers_address_space" {
  value = azurerm_subnet.aks_load_balancers.address_prefixes
}

output "aks_system_subnet_id" {
  value = azurerm_subnet.aks_system.id
}

output "aks_user_unclassified_subnet_id" {
  value = azurerm_subnet.aks_user_unclassified.id
}

output "aks_user_protected_b_subnet_id" {
  value = azurerm_subnet.aks_user_protected_b.id
}

output "egress_ip" {
  value = azurerm_public_ip.egress.ip_address
}

output "dns_zone_id" {
  value = azurerm_dns_zone.dns.id
}

output "dns_zone_resource_group_name" {
  value = azurerm_dns_zone.dns.resource_group_name
}

output "dns_zone_name_servers" {
  value = azurerm_dns_zone.dns.name_servers
}

output "firewall_policy_id" {
  value = azurerm_firewall_policy.firewall.id
}

output "firewall_route_table_name" {
  value = azurerm_route_table.firewall.name
}

output "firewall_route_table_resource_group_name" {
  value = azurerm_route_table.firewall.resource_group_name
}

output "firewall_route_table_id" {
  value = azurerm_route_table.firewall.id
}
