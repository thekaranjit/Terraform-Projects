output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "hub_vnet_id" {
  description = "ID of the Hub Virtual Network"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Name of the Hub Virtual Network"
  value       = azurerm_virtual_network.hub.name
}

output "hub_vnet_address_space" {
  description = "Address space of the Hub Virtual Network"
  value       = azurerm_virtual_network.hub.address_space
}

output "hub_subnets" {
  description = "Map of Hub Subnets with their IDs and address prefixes"
  value = {
    for subnet_name, subnet in azurerm_subnet.hub_subnets :
    subnet_name => {
      id              = subnet.id
      address_prefix  = subnet.address_prefixes
      name            = subnet.name
    }
  }
}

output "spoke_vnets" {
  description = "Map of Spoke Virtual Networks with their details"
  value = {
    for spoke_name, vnet in azurerm_virtual_network.spoke :
    spoke_name => {
      id            = vnet.id
      name          = vnet.name
      address_space = vnet.address_space
    }
  }
}

output "spoke_subnets" {
  description = "Map of Spoke Subnets with their IDs and address prefixes"
  value = {
    for subnet_key, subnet in azurerm_subnet.spoke_subnets :
    subnet_key => {
      id              = subnet.id
      address_prefix  = subnet.address_prefixes
      name            = subnet.name
    }
  }
}

output "hub_nsg_id" {
  description = "ID of the Hub Network Security Group"
  value       = azurerm_network_security_group.hub_nsg.id
}

output "spoke_nsgs" {
  description = "Map of Spoke Network Security Groups with their IDs"
  value = {
    for spoke_name, nsg in azurerm_network_security_group.spoke_nsg :
    spoke_name => {
      id   = nsg.id
      name = nsg.name
    }
  }
}

output "vnet_peering_status" {
  description = "Status of VNet peering connections"
  value = var.enable_vnet_peering ? {
    hub_to_spoke_peers = [for peer_name in keys(azurerm_virtual_network_peering.hub_to_spoke) : peer_name]
    spoke_to_hub_peers = [for peer_name in keys(azurerm_virtual_network_peering.spoke_to_hub) : peer_name]
  } : "VNet peering is disabled"
}
