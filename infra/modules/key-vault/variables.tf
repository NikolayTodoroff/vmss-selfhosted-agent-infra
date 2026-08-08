variable "prefix" {
  description = "Resource name prefix (e.g. nginx-dev)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy into"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID for Key Vault"
  type        = string
}

variable "local_ip_address" {
  description = "Local IP allowed through the Key Vault network ACL for local terraform runs"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}