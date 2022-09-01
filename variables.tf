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

variable "cloud_main_firewall_ip" {
  description = "IP of cloud main firewall"
  default     = null
}

variable "cloud_main_start" {
  type = object({
    first  = number
    second = number
  })
  description = "Starting octect for cloud main network resources."
}

variable "cloud_main_gitlab_ip" {
  description = "IP of cloud main gitlab (gitlab.k8s.cloud.statcan.ca)"
  default     = null
}