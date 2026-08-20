terraform {
  required_version = ">= 1.8"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.111"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox.endpoint
  insecure  = var.proxmox.insecure
  api_token = var.proxmox.api_token

  ssh {
    agent    = false
    username = "terraform"
    password = "terraform"
  }
}

variable "proxmox" {
  description = "Proxmox provider configuration"
  type = object({
    endpoint  = string
    insecure  = bool
    api_token = string
  })
  sensitive = true
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

module "monitoring_vms" {
  source = "../../modules/vm-debian"

  proxmox = var.proxmox

  ssh_public_key = var.ssh_public_key

  vms = {
    "grafana" = {
      host_node    = "pve1"
      vmid         = 124
      hostname     = "monitoring-grafana"
      ip           = "192.168.50.248"
      gateway      = "192.168.50.1"
      cidr         = 24
      dns_servers  = ["192.168.50.1"]
      dns_domain   = "homelab.vincentdupain.com"
      vlan_id      = 50
      mtu          = 1400
      bridge       = "vmbr0"
      cpu          = 2
      memory       = 2048
      disk_size    = 20
      datastore_id = "local-zfs"
      user         = "monitoring"
      tags         = ["terraform", "monitoring", "grafana"]
    }
    "prometheus" = {
      host_node    = "pve1"
      vmid         = 125
      hostname     = "monitoring-prometheus"
      ip           = "192.168.50.249"
      gateway      = "192.168.50.1"
      cidr         = 24
      dns_servers  = ["192.168.50.1"]
      dns_domain   = "homelab.vincentdupain.com"
      vlan_id      = 50
      mtu          = 1400
      bridge       = "vmbr0"
      cpu          = 2
      memory       = 2048
      disk_size    = 20
      datastore_id = "local-zfs"
      user         = "monitoring"
      tags         = ["terraform", "monitoring", "prometheus"]
    }
  }
}

output "grafana_vm_id" { value = module.monitoring_vms.vm_ids["grafana"] }
output "prometheus_vm_id" { value = module.monitoring_vms.vm_ids["prometheus"] }
output "grafana_ip" { value = "192.168.50.248" }
output "prometheus_ip" { value = "192.168.50.249" }