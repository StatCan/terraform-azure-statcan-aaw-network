resource "azurerm_public_ip" "firewall" {
  name                = "${var.prefix}-pip-firewall"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_public_ip" "ingress_general" {
  name                = "${var.prefix}-pip-ingress-general"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_public_ip" "ingress_kubeflow" {
  name                = "${var.prefix}-pip-ingress-kubeflow"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_public_ip" "ingress_authenticated" {
  name                = "${var.prefix}-pip-ingress-authenticated"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
}

# Register in DNS
resource "azurerm_dns_a_record" "general" {
  name                = "*"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_dns_zone.dns.resource_group_name
  ttl                 = 300
  records             = [azurerm_public_ip.ingress_general.ip_address]
}

resource "azurerm_dns_a_record" "kubeflow" {
  name                = "kubeflow"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_dns_zone.dns.resource_group_name
  ttl                 = 300
  records             = [azurerm_public_ip.ingress_kubeflow.ip_address]
}

resource "azurerm_dns_a_record" "kubecost" {
  name                = "kubecost"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_dns_zone.dns.resource_group_name
  ttl                 = 300
  records             = [azurerm_public_ip.ingress_authenticated.ip_address]
}

resource "azurerm_dns_a_record" "monitoring_kibana" {
  name                = "monitoring-kibana"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_dns_zone.dns.resource_group_name
  ttl                 = 300
  records             = [azurerm_public_ip.ingress_authenticated.ip_address]
}

resource "azurerm_dns_a_record" "prometheus" {
  name                = "prometheus"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_dns_zone.dns.resource_group_name
  ttl                 = 300
  records             = [azurerm_public_ip.ingress_authenticated.ip_address]
}

resource "azurerm_dns_a_record" "alertmanager" {
  name                = "alertmanager"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_dns_zone.dns.resource_group_name
  ttl                 = 300
  records             = [azurerm_public_ip.ingress_authenticated.ip_address]
}

# Create firewall
resource "azurerm_firewall" "firewall" {
  name                = "${var.prefix}-fw"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags
  zones               = var.availability_zones

  sku_name = "AZFW_VNet"
  sku_tier = "Standard"

  firewall_policy_id = azurerm_firewall_policy.firewall.id

  ip_configuration {
    name                 = "firewall"
    subnet_id            = azurerm_subnet.hub_firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  ip_configuration {
    name                 = "ingress-general"
    public_ip_address_id = azurerm_public_ip.ingress_general.id
  }

  ip_configuration {
    name                 = "ingress-kubeflow"
    public_ip_address_id = azurerm_public_ip.ingress_kubeflow.id
  }

  ip_configuration {
    name                 = "ingress-authenticated"
    public_ip_address_id = azurerm_public_ip.ingress_authenticated.id
  }
}

resource "azurerm_firewall_policy" "firewall" {
  name                = "${var.prefix}-fwpol"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name

  # Until this issue is resolved:
  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/9620
  # we have to lowercase all tags on the firewall policy
  tags = zipmap([for k in keys(var.tags) : lower(k)], values(var.tags))

  # Because of the above issue, changes to the upercase SSC_CBRID must be ignored
  # so that Terraform does not attempt to reconcile by removing this tag that it cannot add
  lifecycle {
    ignore_changes = [
      tags["SSC_CBRID"]
    ]
  }

  threat_intelligence_mode = "Deny"

  # Enable DNS proxying
  dns {
    proxy_enabled = true
  }
}

# Allow AKS service traffic
resource "azurerm_firewall_policy_rule_collection_group" "aks" {
  name               = "${var.prefix}-fwprcg-aks"
  firewall_policy_id = azurerm_firewall_policy.firewall.id

  priority = 100

  application_rule_collection {
    name     = "aks-application"
    priority = 1000
    action   = "Allow"

    rule {
      name                  = "aks"
      destination_fqdn_tags = ["AzureKubernetesService"]
      source_addresses      = azurerm_virtual_network.aks.address_space

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "software-updates"
      destination_fqdns = ["security.ubuntu.com", "azure.archive.ubuntu.com", "changelogs.ubuntu.com"]
      source_addresses  = azurerm_virtual_network.aks.address_space

      protocols {
        port = 80
        type = "Http"
      }
    }

    rule {
      name              = "software-gpu"
      destination_fqdns = ["nvidia.github.io", "us.download.nvidia.com", "apt.dockerproject.org"]
      source_addresses  = azurerm_virtual_network.aks.address_space

      protocols {
        port = 443
        type = "Https"
      }
    }

    # Permit Azure AD
    # To allow use of Azure AD credentials from within the AAW environment
    #   (for example: GitLab, MinIO)
    rule {
      name              = "azuread-auth"
      destination_fqdns = ["login.microsoftonline.com", "device.login.microsoftonline.com", "*.msftauth.net", "*.msauth.net", "*.msauthimages.net", "login.live.com"]
      source_addresses  = azurerm_virtual_network.aks.address_space
      protocols {
        port = 443
        type = "Https"
      }
    }
  }

  network_rule_collection {
    name     = "aks-network"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "aks-tunnel"
      source_addresses      = azurerm_virtual_network.aks.address_space
      destination_addresses = ["AzureCloud.${replace(var.location, " ", "")}"]
      destination_ports     = ["1194"]
      protocols             = ["UDP"]
    }

    rule {
      name              = "ntp"
      source_addresses  = azurerm_virtual_network.aks.address_space
      destination_fqdns = ["ntp.ubuntu.com"]
      destination_ports = ["123"]
      protocols         = ["UDP"]
    }

    rule {
      name                  = "user-unclassified-web"
      source_addresses      = azurerm_subnet.aks_user_unclassified.address_prefixes
      destination_addresses = ["*"]
      destination_ports     = ["80", "443"]
      protocols             = ["TCP"]
    }

    rule {
      name             = "user-unclassified-ssh"
      source_addresses = azurerm_subnet.aks_user_unclassified.address_prefixes
      # 64.254.29.209 = SEDAR / CSA Data Provider. For an SFTP pull of
      # non-protected SEDAR data in a live feed.
      # Statcan DScD contact is Monica Pickard or Andres Solis Montero
      destination_addresses = ["64.254.29.209"]
      destination_ports     = ["22"]
      protocols             = ["TCP"]
    }
  }
}

# Allow Platform Components
resource "azurerm_firewall_policy_rule_collection_group" "cloud_native_platform" {
  name               = "${var.prefix}-fwprcg-cloud-native-platform"
  firewall_policy_id = azurerm_firewall_policy.firewall.id

  priority = 110

  network_rule_collection {
    name     = "dns"
    priority = 110
    action   = "Allow"

    rule {
      name                  = "dns"
      source_addresses      = azurerm_subnet.aks_system.address_prefixes
      destination_addresses = ["*"]
      destination_ports     = ["53"]
      protocols             = ["UDP", "TCP"]
    }
  }

  network_rule_collection {
    name     = "cns-platform-components"
    priority = 120
    action   = "Allow"

    rule {
      name                  = "cnp-alertmanager"
      source_addresses      = azurerm_subnet.aks_system.address_prefixes
      destination_addresses = [var.management_cluster_https_ingress_gateway_ip]
      destination_ports     = ["443"]
      protocols             = ["TCP"]
    }
  }

  application_rule_collection {
    name     = "cloud-native-platform"
    priority = 1010
    action   = "Allow"

    rule {
      name              = "letsencrypt"
      destination_fqdns = ["*.letsencrypt.org"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "letsencrypt-ocsp"
      destination_fqdns = ["*.lencr.org"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 80
        type = "Http"
      }
    }

    rule {
      name              = "microsoft-graph"
      destination_fqdns = ["graph.microsoft.com"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "slack-webhook"
      destination_fqdns = ["hooks.slack.com"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "azure-ratecard"
      destination_fqdns = ["prices.azure.com", "ratecard.azure-api.net", "apim-ratecard-v1.azure-api.net"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 443
        type = "Https"
      }
    }
  }
}

# Allow Docker Hub
resource "azurerm_firewall_policy_rule_collection_group" "docker" {
  name               = "${var.prefix}-fwprcg-docker"
  firewall_policy_id = azurerm_firewall_policy.firewall.id

  priority = 200

  application_rule_collection {
    name     = "docker"
    priority = 1000
    action   = "Allow"

    rule {
      name              = "docker-hub"
      destination_fqdns = ["*.docker.io", "*.docker.com"]
      source_addresses  = azurerm_virtual_network.aks.address_space

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "docker-ecr"
      destination_fqdns = ["public.ecr.aws"]
      source_addresses  = azurerm_virtual_network.aks.address_space

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "mcr"
      destination_fqdns = ["mcr.microsoft.com"]
      source_addresses  = azurerm_virtual_network.aks.address_space

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "quay"
      destination_fqdns = ["quay.io", "*.quay.io"]
      source_addresses  = azurerm_virtual_network.aks.address_space

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "gcr"
      destination_fqdns = ["gcr.io", "*.gcr.io", "storage.googleapis.com"]
      source_addresses  = concat(azurerm_subnet.aks_system.address_prefixes, azurerm_subnet.aks_user_unclassified.address_prefixes)

      protocols {
        port = 443
        type = "Https"
      }
    }

    // Registry and its CDNs
    rule {
      name              = "k8s"
      destination_fqdns = ["registry.k8s.io", "*docker.pkg.dev"]
      source_addresses  = concat(azurerm_subnet.aks_system.address_prefixes, azurerm_subnet.aks_user_unclassified.address_prefixes)

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "gitlab"
      destination_fqdns = ["registry.gitlab.com", "gitlab.com", "cdn.registry.gitlab-static.net"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name = "jfrog"
      # Additional for policies download: https://www.jfrog.com/confluence/display/JFROG/Configuring+Xray
      destination_fqdns = ["*.jfrog.io", "*.amazonaws.com", "*.cloudfront.net", "dl.bintray.com", "akamai.bintray.com"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "elastic"
      destination_fqdns = ["docker.elastic.co", "*.elastic.co", "*.docker.elastic.co"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "ghcr"
      destination_fqdns = ["ghcr.io", "pkg-containers.githubusercontent.com"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 443
        type = "Https"
      }
    }
  }
}

# Allow DAaaS resources
# (connections required to operator DAaaS services)
resource "azurerm_firewall_policy_rule_collection_group" "daaas" {
  name               = "${var.prefix}-fwprcg-daaas"
  firewall_policy_id = azurerm_firewall_policy.firewall.id

  priority = 121

  network_rule_collection {
    name     = "daaas-network"
    priority = 121
    action   = "Allow"

    # Open SMTP for Vetting App - DAAAS-1787
    rule {
      name                  = "smtp"
      source_addresses      = azurerm_subnet.aks_system.address_prefixes
      destination_addresses = ["*"]
      destination_ports     = ["25"]
      protocols             = ["TCP"]
    }
  }

  application_rule_collection {
    name     = "daaas"
    priority = 1021
    action   = "Allow"

    # To allow Argo CD deployments to read deployment resources
    rule {
      name              = "argocd-deployment-resources"
      destination_fqdns = ["github.com", "statcan.github.io", "charts.bitnami.com", "raw.githubusercontent.com", "objects.githubusercontent.com"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "jfrog"
      destination_fqdns = ["jfrog.aaw.cloud.statcan.ca"]
      source_addresses  = azurerm_virtual_network.aks.address_space

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "pypi"
      destination_fqdns = ["pypi.org", "files.pythonhosted.org"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "cran"
      destination_fqdns = ["cran.r-project.org"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 443
        type = "Https"
      }
    }

    rule {
      name              = "conda-forge"
      destination_fqdns = ["conda.anaconda.org"]
      source_addresses  = azurerm_subnet.aks_system.address_prefixes

      protocols {
        port = 443
        type = "Https"
      }
    }

  }
}

# Allow Legacy AAW
# (this allows access to old MinIO and Vault temporarily)
resource "azurerm_firewall_policy_rule_collection_group" "legacy_aaw" {
  name               = "${var.prefix}-fwprcg-legacy-aaw"
  firewall_policy_id = azurerm_firewall_policy.firewall.id

  priority = 120

  application_rule_collection {
    name     = "legacy-aaw"
    priority = 1020
    action   = "Allow"

    rule {
      name              = "legacy"
      destination_fqdns = ["*.covid.cloud.statcan.ca"]
      source_addresses  = concat(azurerm_subnet.aks_system.address_prefixes, azurerm_subnet.aks_user_unclassified.address_prefixes)

      protocols {
        port = 443
        type = "Https"
      }
    }
  }
}

# Allow Access to Select Cloud Main Services
resource "azurerm_firewall_policy_rule_collection_group" "cloud_main_system" {
  count              = var.cloud_main_gitlab_ssh_ip == null || var.management_cluster_https_ingress_gateway_ip == null ? 0 : 1
  name               = "${var.prefix}-fwprcg-cloud-main-system"
  firewall_policy_id = azurerm_firewall_policy.firewall.id

  priority = 350

  network_rule_collection {
    name     = "allow-gitlab-cloud-main"
    priority = 1020
    action   = "Allow"

    rule {
      name                  = "cloud-main-gitlab"
      destination_addresses = [var.cloud_main_gitlab_ssh_ip, var.management_cluster_https_ingress_gateway_ip]
      source_addresses      = azurerm_subnet.aks_cloud_main_system.address_prefixes
      # Users might interact with gitlab over https or ssh
      destination_ports = ["22", "443"]
      protocols         = ["TCP"]
    }
  }
}

# Ingress
resource "azurerm_firewall_policy_rule_collection_group" "ingress" {
  name               = "${var.prefix}-fwprcg-ingress"
  firewall_policy_id = azurerm_firewall_policy.firewall.id

  priority = 60000

  dynamic "nat_rule_collection" {
    for_each = compact([var.ingress_general_private_ip])
    content {
      name     = "ingress-general"
      priority = 60001
      action   = "Dnat"

      rule {
        name                = "ingress-general-http"
        protocols           = ["TCP"]
        source_addresses    = var.ingress_allowed_sources
        destination_address = azurerm_public_ip.ingress_general.ip_address
        destination_ports   = ["80"]
        translated_address  = nat_rule_collection.value
        translated_port     = "80"
      }

      rule {
        name                = "ingress-general-https"
        protocols           = ["TCP"]
        source_addresses    = var.ingress_allowed_sources
        destination_address = azurerm_public_ip.ingress_general.ip_address
        destination_ports   = ["443"]
        translated_address  = nat_rule_collection.value
        translated_port     = "443"
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = compact([var.ingress_kubeflow_private_ip])
    content {
      name     = "ingress-kubeflow"
      priority = 60002
      action   = "Dnat"

      rule {
        name                = "ingress-kubeflow-http"
        protocols           = ["TCP"]
        source_addresses    = var.ingress_allowed_sources
        destination_address = azurerm_public_ip.ingress_kubeflow.ip_address
        destination_ports   = ["80"]
        translated_address  = nat_rule_collection.value
        translated_port     = "80"
      }

      rule {
        name                = "ingress-kubeflow-https"
        protocols           = ["TCP"]
        source_addresses    = var.ingress_allowed_sources
        destination_address = azurerm_public_ip.ingress_kubeflow.ip_address
        destination_ports   = ["443"]
        translated_address  = nat_rule_collection.value
        translated_port     = "443"
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = compact([var.ingress_authenticated_private_ip])
    content {
      name     = "ingress-authenticated"
      priority = 60003
      action   = "Dnat"

      rule {
        name                = "ingress-authenticated-http"
        protocols           = ["TCP"]
        source_addresses    = var.ingress_allowed_sources
        destination_address = azurerm_public_ip.ingress_authenticated.ip_address
        destination_ports   = ["80"]
        translated_address  = nat_rule_collection.value
        translated_port     = "80"
      }

      rule {
        name                = "ingress-authenticated-https"
        protocols           = ["TCP"]
        source_addresses    = var.ingress_allowed_sources
        destination_address = azurerm_public_ip.ingress_authenticated.ip_address
        destination_ports   = ["443"]
        translated_address  = nat_rule_collection.value
        translated_port     = "443"
      }
    }
  }
}
