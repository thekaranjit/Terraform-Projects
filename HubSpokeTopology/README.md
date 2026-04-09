# Azure Hub-and-Spoke Terraform Configuration

This Terraform configuration sets up a Hub-and-Spoke network topology on Azure, which is a common architecture pattern for enterprise Azure deployments.

## Architecture Overview

The Hub-and-Spoke topology consists of:

- **Hub VNet**: Central virtual network containing shared resources (gateway, firewall, bastion)
- **Spoke VNets**: Isolated virtual networks for different workloads or departments
- **VNet Peering**: Direct connections between hub and spoke networks for secure communication

## Project Structure

```
HubSpokeTopology/
├── provider.tf          # Azure provider configuration
├── variables.tf         # Input variables definition
├── main.tf              # Main infrastructure configuration
├── outputs.tf           # Output values
├── terraform.tfvars     # Default variable values
└── README.md            # This file
```

## Files Description

### provider.tf
Configures the Azure provider and specifies the required Terraform version and provider version.

### variables.tf
Defines all input variables used throughout the configuration:
- Resource group and location settings
- Hub VNet address space and subnets
- Spoke VNets configuration with multiple subnets
- Peering settings and common tags

### main.tf
Contains the main infrastructure resources:
- Resource Group
- Hub Virtual Network with subnets
- Spoke Virtual Networks with subnets
- Network Security Groups (NSGs) for hub and spokes
- VNet peering connections
- NSG associations with subnets

### outputs.tf
Exports important resource IDs and attributes for reference:
- Resource Group information
- VNet IDs and names
- Subnet configurations
- NSG details
- Peering status

### terraform.tfvars
Provides default values for variables. Customize these values based on your requirements.

## Prerequisites

- Terraform >= 1.0
- Azure CLI installed and configured
- Azure subscription with appropriate permissions

## Usage

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

This will show you all the resources that will be created.

### 3. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to create the resources.

### 4. Verify Deployment

After successful deployment, Terraform will output:
- Resource Group ID and name
- Hub VNet details
- Spoke VNet details
- VNet peering status

## Customization

### Modify Hub Network

Edit `terraform.tfvars` to change:
```hcl
hub_vnet_name          = "vnet-hub"
hub_vnet_address_space = ["10.0.0.0/16"]

hub_subnet_config = {
  "gateway-subnet" = {
    address_prefix = "10.0.1.0/24"
  }
  # Add or modify subnets as needed
}
```

### Add or Remove Spokes

Modify the `spoke_vnets` variable in `terraform.tfvars`:
```hcl
spoke_vnets = {
  "spoke1" = {
    address_space = ["10.1.0.0/16"]
    subnets = {
      "app-subnet" = {
        address_prefix = "10.1.1.0/24"
      }
    }
  }
  # Add more spokes as needed
}
```

### Adjust Peering Settings

```hcl
enable_vnet_peering      = true
allow_forwarded_traffic  = true
allow_gateway_transit    = true
```

## Network Architecture

```
                    ┌─────────────────┐
                    │   Hub VNet      │
                    │  10.0.0.0/16    │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
        ┌─────▼────────┐ ┌──▼──────────┐ ┌─▼──────────────┐
        │ Spoke1 VNet  │ │ Spoke2 VNet │ │ Spoke3 VNet    │
        │ 10.1.0.0/16  │ │ 10.2.0.0/16 │ │ 10.3.0.0/16    │
        └──────────────┘ └─────────────┘ └────────────────┘
```

## Security Considerations

- **Network Security Groups (NSGs)**: Default rules allow VNet-to-VNet communication while blocking external traffic
- **Firewall Subnet**: Can host an Azure Firewall for centralized traffic filtering
- **Bastion Subnet**: Can host Azure Bastion for secure RDP/SSH access
- **Gateway Subnet**: Reserved for VPN/ExpressRoute gateways

## Cost Estimation

The base configuration includes:
- 1 Resource Group
- 1 Hub VNet with 3 subnets
- 2 Spoke VNets with 2 subnets each
- Network Security Groups for each VNet

Additional costs depend on:
- VPN/ExpressRoute gateways (if deployed)
- Azure Firewall (if deployed)
- Azure Bastion (if deployed)
- VM/Container instances in the networks

## Troubleshooting

### Issues with VNet Peering
- Ensure address spaces don't overlap
- Verify NSG rules allow necessary traffic
- Check that `allow_forwarded_traffic` is set appropriately

### Authentication Errors
- Ensure Azure CLI is logged in: `az login`
- Verify subscription with: `az account show`

### Resource Already Exists
Delete the conflicting resource or import it:
```bash
terraform import azurerm_resource_group.rg /subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME
```

## Cleanup

To remove all resources created by this configuration:

```bash
terraform destroy
```

Type `yes` when prompted to confirm deletion.

## Best Practices

1. **Use Remote State**: Store Terraform state in Azure Storage for team collaboration
2. **Implement Access Controls**: Use Azure RBAC to control who can modify infrastructure
3. **Enable Logging**: Configure NSG flow logs and Azure Monitor diagnostics
4. **Regular Backups**: Document and backup your Terraform configuration
5. **Code Review**: Implement pipeline checks before applying changes

## Advanced Enhancements

Consider adding:
- **Azure Firewall**: For centralized threat protection
- **Azure VPN Gateway**: For on-premises connectivity
- **Azure ExpressRoute**: For dedicated private connectivity
- **Route Tables**: For advanced traffic routing
- **Application Gateway**: For load balancing
- **API Management**: For API gateway capabilities

## Links and References

- [Azure Hub-and-Spoke Architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Virtual Network Peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
- [Azure Network Security Groups](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)

## Support

For issues or questions:
1. Review Terraform error messages carefully
2. Check [Azure documentation](https://docs.microsoft.com/azure)
3. Consult [Terraform registry documentation](https://registry.terraform.io/)

---

**Last Updated**: 2026-04-09
**Terraform Version**: 1.0+
**Azure Provider Version**: 3.0+
