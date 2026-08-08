resource "azurerm_public_ip" "lb" {
  name                = "pip-lb-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "this" {
  name                = "lb-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-${var.prefix}"
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "vmss" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "beap-vmss-${var.prefix}"
}

resource "azurerm_lb_probe" "http" {
  loadbalancer_id     = azurerm_lb.this.id
  name                = "probe-http-${var.prefix}"
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.this.id
  name                           = "rule-http-${var.prefix}"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.this.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.vmss.id]
  probe_id                       = azurerm_lb_probe.http.id
  disable_outbound_snat          = true
}