resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = "vmss-${var.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.instance_sku
  instances           = var.instance_count
  admin_username      = var.admin_username
  tags                = var.tags

  custom_data                     = filebase64("${path.module}/cloud-init/nginx.yaml")
  disable_password_authentication = true
  upgrade_mode                    = "Automatic"
  health_probe_id                 = var.health_probe_id

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic-vmss-${var.prefix}"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id

      load_balancer_backend_address_pool_ids = [var.lb_backend_pool_id]
    }
  }

  lifecycle {
    ignore_changes = [instances]
  }
}