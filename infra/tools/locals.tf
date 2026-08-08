locals {
  prefix = var.app_name

  common_tags = {
    environment = "tools"
    app         = var.app_name
    managed_by  = "terraform"
  }
}