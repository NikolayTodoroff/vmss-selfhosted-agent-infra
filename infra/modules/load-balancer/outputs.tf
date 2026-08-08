output "lb_id" {
  value = azurerm_lb.this.id
}

output "lb_public_ip" {
  value = azurerm_public_ip.lb.ip_address
}

output "backend_pool_id" {
  value = azurerm_lb_backend_address_pool.vmss.id
}

output "frontend_ip_configuration_name" {
  value = "frontend-${var.prefix}"
}

output "lb_probe_id" {
  value = azurerm_lb_probe.http.id
}