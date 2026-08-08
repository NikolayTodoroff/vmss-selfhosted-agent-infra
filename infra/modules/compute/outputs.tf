output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.this.id
}

output "vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.this.name
}

output "autoscale_setting_id" {
  value = azurerm_monitor_autoscale_setting.vmss.id
}