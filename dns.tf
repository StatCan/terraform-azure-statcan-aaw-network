###########################################################
# Deploy a DNS zone
###########################################################
resource "azurerm_dns_zone" "dns" {
  name                = var.dns_zone
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags
}

# Deploy a private DNS zone that
# will allow us to register hostnames
# only within the environment.
resource "azurerm_private_dns_zone" "private_dns" {
  name                = var.dns_zone
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_hub" {
  name                  = azurerm_virtual_network.hub.name
  resource_group_name   = azurerm_resource_group.network.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  tags                  = local.tags
}

# Register internal ingresses
resource "azurerm_private_dns_a_record" "general" {
  count = var.ingress_general_private_ip != null ? 1 : 0

  name                = "*"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = 300
  records             = [var.ingress_general_private_ip]
}

resource "azurerm_private_dns_a_record" "authenticated" {
  count = var.ingress_authenticated_private_ip != null ? 1 : 0

  name                = "*.auth"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = 300
  records             = [var.ingress_authenticated_private_ip]
}

resource "azurerm_private_dns_a_record" "kubeflow" {
  count = var.ingress_kubeflow_private_ip != null ? 1 : 0

  name                = "kubeflow"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = 300
  records             = [var.ingress_kubeflow_private_ip]
}

resource "azurerm_private_dns_a_record" "kubecost" {
  count = var.ingress_authenticated_private_ip != null ? 1 : 0

  name                = "kubecost"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = 300
  records             = [var.ingress_authenticated_private_ip]
}

resource "azurerm_private_dns_a_record" "monitoring_kibana" {
  count = var.ingress_authenticated_private_ip != null ? 1 : 0

  name                = "monitoring-kibana"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = 300
  records             = [var.ingress_authenticated_private_ip]
}

resource "azurerm_private_dns_a_record" "prometheus" {
  count = var.ingress_authenticated_private_ip != null ? 1 : 0

  name                = "prometheus"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = 300
  records             = [var.ingress_authenticated_private_ip]
}

resource "azurerm_private_dns_a_record" "alertmanager" {
  count = var.ingress_authenticated_private_ip != null ? 1 : 0

  name                = "alertmanager"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = 300
  records             = [var.ingress_authenticated_private_ip]
}

resource "azurerm_private_dns_a_record" "protected_b" {
  count = var.ingress_protected_b_private_ip != null ? 1 : 0

  name                = "*.protected-b"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = 300
  records             = [var.ingress_protected_b_private_ip]
}

# Can replace this once the *.protected-b cert is set up.
resource "azurerm_private_dns_a_record" "vetting_elastic" {
  count = var.ingress_protected_b_private_ip != null ? 1 : 0

  name                = "org-ces-system-vetting-elastic"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = 300
  records             = [var.ingress_protected_b_private_ip]
}

resource "azurerm_private_dns_a_record" "trino_dev" {
  count = var.ingress_protected_b_private_ip != null ? 1 : 0

  name                = "trino-protb"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = 300
  records             = [var.ingress_protected_b_private_ip]
}

resource "azurerm_private_dns_a_record" "geoanalytics" {
  count = var.ingress_geoanalytics_private_ip != null ? 1 : 0

  name                = "geoanalytics"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = 300
  records             = [var.ingress_geoanalytics_private_ip]
}

resource "azurerm_private_dns_a_record" "jfrog_artifactory" {
  count               = var.ingress_jfrog_private_ip != null ? 1 : 0
  name                = "jfrog-artifactory"
  zone_name           = azurerm_private_dns_zone.private_dns.name
  resource_group_name = azurerm_private_dns_zone.private_dns.resource_group_name
  ttl                 = 300
  records             = [var.ingress_jfrog_private_ip]
}
