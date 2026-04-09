# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(var.common_tags, {
    Environment = var.environment
  })
}

# ================================
# Hub Virtual Network
# ================================
resource "azurerm_virtual_network" "hub" {
  name                = "${var.hub_vnet_name}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.hub_vnet_address_space

  tags = merge(var.common_tags, {
    Name = "Hub VNet"
  })
}

# Hub Subnets
resource "azurerm_subnet" "hub_subnets" {
  for_each = var.hub_subnet_config

  name                 = "${each.key}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value.address_prefix]
}

# Network Security Group for Hub
resource "azurerm_network_security_group" "hub_nsg" {
  name                = "nsg-hub-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVNetOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = merge(var.common_tags, {
    Name = "Hub NSG"
  })
}

# Associate NSG with Hub Subnets
resource "azurerm_subnet_network_security_group_association" "hub_nsg_assoc" {
  for_each = azurerm_subnet.hub_subnets

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.hub_nsg.id
}

# ================================
# Spoke Virtual Networks
# ================================
resource "azurerm_virtual_network" "spoke" {
  for_each = var.spoke_vnets

  name                = "vnet-${each.key}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = each.value.address_space

  tags = merge(var.common_tags, {
    Name = "Spoke ${each.key}"
  })
}

# Spoke Subnets
resource "azurerm_subnet" "spoke_subnets" {
  for_each = {
    for spoke_name, spoke_config in var.spoke_vnets :
    spoke_name => spoke_config.subnets
  }

  for_each = merge([
    for spoke_name, spoke_config in var.spoke_vnets :
    {
      for subnet_name, subnet_config in spoke_config.subnets :
      "${spoke_name}-${subnet_name}" => {
        spoke_name         = spoke_name
        subnet_name        = subnet_name
        address_prefix     = subnet_config.address_prefix
        vnet_name          = azurerm_virtual_network.spoke[spoke_name].name
      }
    }
  ]...)

  name                 = "${each.value.subnet_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = [each.value.address_prefix]
}

# Network Security Groups for Spokes
resource "azurerm_network_security_group" "spoke_nsg" {
  for_each = var.spoke_vnets

  name                = "nsg-${each.key}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVNetOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = merge(var.common_tags, {
    Name = "Spoke ${each.key} NSG"
  })
}

# Associate NSG with Spoke Subnets
resource "azurerm_subnet_network_security_group_association" "spoke_nsg_assoc" {
  for_each = merge([
    for spoke_name, subnet_dict in {
      for spoke_name, spoke_config in var.spoke_vnets :
      spoke_name => spoke_config.subnets
    } :
    {
      for subnet_name, _ in subnet_dict :
      "${spoke_name}-${subnet_name}" => {
        subnet_id = azurerm_subnet.spoke_subnets["${spoke_name}-${subnet_name}"].id
        nsg_id    = azurerm_network_security_group.spoke_nsg[spoke_name].id
      }
    }
  ]...)

  subnet_id                 = each.value.subnet_id
  network_security_group_id = each.value.nsg_id
}

# ================================
# VNet Peering: Hub to Spokes
# ================================
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = var.enable_vnet_peering ? var.spoke_vnets : {}

  name                      = "hub-to-${each.key}"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke[each.key].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
}

# VNet Peering: Spokes to Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = var.enable_vnet_peering ? var.spoke_vnets : {}

  name                      = "${each.key}-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.spoke[each.key].name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  use_remote_gateways          = var.allow_gateway_transit

  depends_on = [azurerm_virtual_network_peering.hub_to_spoke]
}
