# Terraform Projects

A collection of Terraform Infrastructure-as-Code (IaC) projects for deploying and managing cloud infrastructure on Azure.

## Overview

This repository contains multiple Terraform projects demonstrating best practices for infrastructure automation, network architecture, and cloud resource management.

## Projects

### 1. Hub-and-Spoke Topology
**Directory**: `HubSpokeTopology/`

A production-ready Terraform configuration that implements the Hub-and-Spoke network architecture pattern on Azure.

#### Features:
- **Hub Virtual Network** (10.0.0.0/16)
  - Gateway Subnet (10.0.1.0/24)
  - Firewall Subnet (10.0.2.0/24)
  - Bastion Subnet (10.0.3.0/24)

- **Spoke Virtual Networks** (customizable)
  - Spoke 1 (10.1.0.0/16) with App and DB subnets
  - Spoke 2 (10.2.0.0/16) with App and DB subnets
  - Expandable to additional spokes

- **Network Security**
  - Network Security Groups (NSGs) for hub and spokes
  - VNet peering with configurable traffic forwarding
  - Gateway transit support for on-premises connectivity

- **Automatic Resource Management**
  - Single resource group for organization
  - Comprehensive output values for resource references
  - Reusable variables for easy customization

#### Quick Start:
```bash
cd HubSpokeTopology
terraform init
terraform plan
terraform apply
```

#### Customization:
Edit `terraform.tfvars` to customize:
- Geographic region
- IP address spaces
- Number of spokes
- Environment tags
- Peering settings

See [HubSpokeTopology/README.md](HubSpokeTopology/README.md) for detailed documentation.

## Prerequisites

- **Terraform** >= 1.0
  - Install from [terraform.io](https://www.terraform.io/)
  
- **Azure CLI** >= 2.0
  - Install from [Azure CLI documentation](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
  
- **Azure Subscription**
  - Access to create resources in Azure

- **Authentication**
  - Logged in with: `az login`
  - Verify subscription: `az account show`

## Repository Structure

```
Terraform-Projects/
├── README.md                          # This file
├── .gitignore                         # Git ignore rules
├── .git/                              # Git repository
│
└── HubSpokeTopology/                  # Hub-and-Spoke Network Topology
    ├── provider.tf                    # Azure provider configuration
    ├── variables.tf                   # Input variables
    ├── main.tf                        # Main infrastructure resources
    ├── outputs.tf                     # Output values
    ├── terraform.tfvars               # Default variable values
    ├── .gitignore                     # Terraform-specific ignores
    └── README.md                      # Project documentation
```

## Getting Started

### 1. Clone the Repository
```bash
git clone <repository-url>
cd Terraform-Projects
```

### 2. Navigate to a Project
```bash
cd HubSpokeTopology
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Review and Plan
```bash
terraform plan -out=tfplan
```

### 5. Apply the Configuration
```bash
terraform apply tfplan
```

### 6. Verify Resources
```bash
terraform output
```

## Common Terraform Commands

| Command | Description |
|---------|-------------|
| `terraform init` | Initialize Terraform working directory |
| `terraform plan` | Show what changes will be made |
| `terraform apply` | Apply configuration changes |
| `terraform destroy` | Delete all resources |
| `terraform output` | Display output values |
| `terraform state list` | List all resources in state file |
| `terraform validate` | Validate configuration syntax |
| `terraform fmt` | Format Terraform code |

## Best Practices

### State Management
- Use remote state for production (Azure Storage recommended)
- Never commit `.tfstate` files
- Implement state locking for team environments

### Security
- Keep `terraform.tfvars` with sensitive data out of version control
- Use Azure Key Vault for secrets
- Implement least-privilege access in NSGs
- Enable audit logging for infrastructure changes

### Code Organization
- Separate concerns into multiple files (provider, variables, main, outputs)
- Use meaningful variable and resource names
- Document complex configurations
- Use modules for reusable components

### Version Control
- Always review changes before applying with `terraform plan`
- Use branches for experimental changes
- Tag releases in Git
- Maintain comprehensive commit messages

## Environment-Specific Configurations

To use different configurations for different environments:

```bash
# Development
terraform apply -var-file="dev.tfvars"

# Production
terraform apply -var-file="prod.tfvars"
```

## Troubleshooting

### Authentication Issues
```bash
# Check current Azure account
az account show

# Login to Azure
az login

# Set specific subscription
az account set --subscription <subscription-id>
```

### Terraform State Issues
```bash
# Remove local state (if corrupted)
rm -rf .terraform/
rm terraform.tfstate*

# Reinitialize
terraform init
```

### Resource Conflicts
```bash
# Import existing resources
terraform import azurerm_resource_group.rg /subscriptions/SUB_ID/resourceGroups/RG_NAME
```

### Validation Errors
```bash
# Validate Terraform syntax
terraform validate

# Format Terraform code
terraform fmt -recursive
```

## Azure Architecture Documentation

For more information on Azure architecture patterns:
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [Hub-and-Spoke Architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure Virtual Networking](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)

## Terraform Documentation

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/language)

## Contributing

To add new projects or improve existing ones:

1. Create a new directory for your project
2. Follow the file structure (provider.tf, variables.tf, main.tf, outputs.tf)
3. Add comprehensive README.md documentation
4. Include appropriate .gitignore rules
5. Test thoroughly before committing

## Additional Resources

- **Azure Cost Estimation**: Use [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
- **Network Topology Planning**: Use [Azure Architecture Advisor](https://learn.microsoft.com/en-us/assessments/azure-advisor/)
- **Policy Compliance**: Check [Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/)

## Support

For issues or questions:

1. **Check Terraform Logs**
   ```bash
   TF_LOG=DEBUG terraform apply
   ```

2. **Review Azure Documentation**
   - [Azure Docs](https://learn.microsoft.com/en-us/azure/)

3. **Consult Terraform Registry**
   - [Terraform Registry](https://registry.terraform.io/)

4. **Review Project-Specific README**
   - Each project contains detailed documentation in its README.md

## License

This project is for educational and laboratory purposes.

## Changelog

### Version 1.0 (2026-04-09)
- Initial repository setup
- Added Hub-and-Spoke Network Topology project
- Comprehensive documentation and examples
- Production-ready Terraform configuration

---

**Last Updated**: 2026-04-09  
**Terraform Version**: 1.0+  
**Azure Provider Version**: 3.0+
