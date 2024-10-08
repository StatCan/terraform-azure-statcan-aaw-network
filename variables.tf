variable "prefix" {
  description = "Prefix for Azure resources."
}

variable "location" {
  description = "Location of Azure resources."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to Azure resources."

  default = {}
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for Azure resources."
}

variable "ddos_protection_plan_id" {
  description = "DDOS Protection Plan ID"
}

variable "start" {
  type = object({
    first  = number
    second = number
  })
  description = "Starting octect for network resources. This module uses a /14"
}

variable "parent_dns_zone_name" {
  description = "Name of the parent DNS zone"
  default     = ""
}

variable "parent_dns_zone_resource_group_name" {
  description = "Name of the resource group containing the parent DNS zone"
  default     = ""
}

variable "dns_zone" {
  description = "DNS zone"
}

variable "ingress_general_private_ip" {
  description = "Private IP of the general ingress"
  default     = null
}

variable "ingress_kubeflow_private_ip" {
  description = "Private IP of the kubeflow ingress"
  default     = null
}

variable "ingress_authenticated_private_ip" {
  description = "Private IP of the authenticated ingress"
  default     = null
}

variable "ingress_protected_b_private_ip" {
  description = "Private IP of the protected-b ingress"
  default     = null
}

variable "ingress_geoanalytics_private_ip" {
  description = "Private IP of the geoanalytics ingress"
  default     = null
}

variable "ingress_jfrog_private_ip" {
  description = "Private IP of the jfrog ingress"
  default     = null
}

variable "ingress_allowed_sources" {
  type        = list(string)
  description = "Source IPs which are allowed to connect to the ingress gateway"
  default     = ["*"]
}

variable "cloud_main_firewall_ip" {
  description = "IP of cloud main firewall"
  default     = null
}

variable "cloud_main_address_prefix" {
  description = "IP prefix for cloud main addresses."
  default     = null
}

variable "management_cluster_https_ingress_gateway_ip" {
  description = "IP of cloud main (Management cluster) ingress gateway for HTTPs traffic."
  default     = null
}

variable "cloud_main_gitlab_ssh_ip" {
  description = "IP of cloud main gitlab for ssh (gitlab-ssh.cloud.statcan.ca)"
  default     = null
}

variable "geo_database_ip" {
  description = "IP of geo database (geo-prod-mulp-db.postgres.database.azure.com)"
  default     = null
}
