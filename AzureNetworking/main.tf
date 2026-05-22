resource "azurerm_resource_group" "ResourceGroup" {
  name     = "Vnet2RG"
  location = "West Europe"
}

resource "azurerm_network_security_group" "NetworkSecurityGroup" {
  name                = "Vnet2NSG"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
}

resource "azurerm_network_security_rule" "AllowRule" {
  name                        = "Allow443-FrontEnd"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "443"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ResourceGroup.name
  network_security_group_name = azurerm_network_security_group.NetworkSecurityGroup.name
}

resource "azurerm_virtual_network" "VirtualNetwork" {
  name                = "Vnet2"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name             = "Frontend"
    address_prefixes = ["10.0.1.0/24"]
    security_group   = azurerm_network_security_group.NetworkSecurityGroup.id
  }

  subnet {
    name             = "Backend"
    address_prefixes = ["10.0.2.0/24"]
  }

  subnet {
    name             = "Database"
    address_prefixes = ["10.0.3.0/24"]
  }

  tags = {
    environment = "Production"
  }
}