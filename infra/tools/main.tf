resource "azurerm_resource_group" "rg_tools" {
  name     = "rg-tools-${local.prefix}"
  location = var.location
}

resource "azurerm_virtual_network" "tools" {
  name                = "vnet-tools-${local.prefix}"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_tools.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "tools" {
  name                 = "snet-tools-${local.prefix}"
  resource_group_name  = azurerm_resource_group.rg_tools.name
  virtual_network_name = azurerm_virtual_network.tools.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_security_group" "agent" {
  name                = "nsg-agent-${local.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_tools.name
  tags                = local.common_tags
}

resource "azurerm_network_security_rule" "allow_ssh_from_me" {
  name                        = "AllowSshFromMyIp"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.local_ip_address}/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_tools.name
  network_security_group_name = azurerm_network_security_group.agent.name
}

resource "azurerm_subnet_network_security_group_association" "tools" {
  subnet_id                 = azurerm_subnet.tools.id
  network_security_group_id = azurerm_network_security_group.agent.id
}

resource "azurerm_public_ip" "agent" {
  name                = "pip-agent-${local.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_tools.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "agent" {
  name                = "nic-agent-${local.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_tools.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tools.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.agent.id
  }

  tags = local.common_tags
}

resource "azurerm_linux_virtual_machine" "agent" {
  name                = "vm-agent-${local.prefix}"
  resource_group_name = azurerm_resource_group.rg_tools.name
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.agent.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  disable_password_authentication = true

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

  tags = local.common_tags
}