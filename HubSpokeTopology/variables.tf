variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-hub-spoke"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

# Hub VNet variables
variable "hub_vnet_name" {
  description = "Name of the Hub VNet"
  type        = string
  default     = "vnet-hub"
}

variable "hub_vnet_address_space" {
  description = "Address space for Hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "hub_subnet_config" {
  description = "Configuration for Hub subnets"
  type = map(object({
    address_prefix = string
  }))
  default = {
    "gateway-subnet" = {
      address_prefix = "10.0.1.0/24"
    }
    "firewall-subnet" = {
      address_prefix = "10.0.2.0/24"
    }
    "bastion-subnet" = {
      address_prefix = "10.0.3.0/24"
    }
  }
}

# Spoke VNets variables
variable "spoke_vnets" {
  description = "Configuration for Spoke VNets"
  type = map(object({
    address_space  = list(string)
    subnets = map(object({
      address_prefix = string
    }))
  }))
  default = {
    "spoke1" = {
      address_space = ["10.1.0.0/16"]
      subnets = {
        "subnet-1" = {
          address_prefix = "10.1.1.0/24"
        }
        "subnet-2" = {
          address_prefix = "10.1.2.0/24"
        }
      }
    }
    "spoke2" = {
      address_space = ["10.2.0.0/16"]
      subnets = {
        "subnet-1" = {
          address_prefix = "10.2.1.0/24"
        }
        "subnet-2" = {
          address_prefix = "10.2.2.0/24"
        }
      }
    }
  }
}

variable "enable_vnet_peering" {
  description = "Enable VNet peering between hub and spokes"
  type        = bool
  default     = true
}

variable "allow_forwarded_traffic" {
  description = "Allow forwarded traffic in peering"
  type        = bool
  default     = true
}

variable "allow_gateway_transit" {
  description = "Allow gateway transit in peering"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "HubSpoke"
  }
}
