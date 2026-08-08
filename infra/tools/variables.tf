variable "app_name" {
  type    = string
  default = "vmssadoinfra"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "subscription_id" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_ssh_public_key" {
  type = string
}

variable "local_ip_address" {
  description = "Your IP address, allowed to SSH directly into the agent VM"
  type        = string
}