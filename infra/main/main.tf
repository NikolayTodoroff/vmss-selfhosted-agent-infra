resource "azurerm_resource_group" "rg_main" {
  name     = "rg-main-${local.prefix}"
  location = var.location
}

data "azurerm_client_config" "current" {}

module "networking" {
  source = "../modules/networking"

  prefix              = local.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_main.name
  tags                = local.common_tags
}

module "compute" {
  source = "../modules/compute"

  prefix               = local.prefix
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg_main.name
  subnet_id            = module.networking.vmss_subnet_id
  admin_username       = var.admin_username
  admin_ssh_public_key = var.admin_ssh_public_key
  tags                 = local.common_tags
  lb_backend_pool_id   = module.load_balancer.backend_pool_id
  health_probe_id      = module.load_balancer.lb_probe_id
}

module "load_balancer" {
  source = "../modules/load-balancer"

  prefix              = local.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_main.name
  tags                = local.common_tags
}

module "key_vault" {
  source = "../modules/key-vault"

  prefix              = local.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  local_ip_address    = var.local_ip_address
  tags                = local.common_tags
}

module "monitoring" {
  source = "../modules/monitoring"

  prefix                       = local.prefix
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg_main.name
  vmss_id                      = module.compute.vmss_id
  lb_id                        = module.load_balancer.lb_id
  alert_email                  = var.alert_email
  tags                         = local.common_tags
  log_analytics_sku            = var.log_analytics_sku
  log_analytics_retention_days = var.log_analytics_retention_days
}