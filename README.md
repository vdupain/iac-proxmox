# iac-proxmox

Infrastructure-as-Code for Proxmox — Terraform modules and environments.

## Repository structure

```
iac-proxmox/
├── modules/
│   └── vm-debian/          # Reusable Debian VM module
│       ├── main.tf         # VM resource definitions
│       ├── variables.tf    # Input variables
│       ├── outputs.tf      # Output values
│       └── versions.tf     # Provider requirements
├── envs/
│   └── monitoring/         # Monitoring VM environment
│       ├── main.tf         # Module call for 2 monitoring VMs
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf    # Proxmox provider configuration
│       ├── versions.tf
│       └── terraform.tfvars.example
└── README.md
```

## Usage

```bash
# Clone the repo
git clone git@github.com:vdupain/iac-proxmox.git
cd iac-proxmox

# Navigate to the environment
cd envs/monitoring

# Copy and fill in variables
cp terraform.tfvars.example terraform.tfvars

# Initialize and apply
terraform init
terraform plan
terraform apply
```

## Modules

### vm-debian

Creates Debian VMs on Proxmox using cloud-init. Supports:

- Static IP configuration with VLAN tagging
- SSH key injection via cloud-init
- QEMU guest agent
- Custom CPU, memory, and disk sizing
- Remote Debian cloud image download

## Environments

### monitoring

Provisions two Debian 13 VMs on VLAN 50 for the monitoring stack:

| VM | IP | Role |
|---|---|---|
| monitoring-grafana | 192.168.50.248 | Grafana dashboard |
| monitoring-prometheus | 192.168.50.249 | Prometheus + Alertmanager |

## Requirements

- Terraform >= 1.8
- bpg/proxmox provider ~> 0.111
- Proxmox API token with appropriate permissions