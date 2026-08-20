module "monitoring_vms" {
  source = "../../modules/vm-debian"

  proxmox = var.proxmox

  ssh_public_key   = var.ssh_public_key
  ci_user          = var.ci_user
  debian_image_url = var.debian_image_url

  vms = {
    grafana = {
      host_node        = "pve2"
      hostname         = "monitoring-grafana"
      ip               = "192.168.50.248"
      cidr             = 24
      gateway          = "192.168.50.1"
      vlan_id          = 50
      mtu              = 1400
      bridge           = "vmbr0"
      cpu              = 2
      memory_dedicated = 2048
      disk_size        = 10
      datastore_id     = "local-zfs"
      disk_file_format = "raw"
      dns_domain       = "homelab.vincentdupain.com"
      dns_servers      = ["192.168.50.1"]
    }
    prometheus = {
      host_node        = "pve2"
      hostname         = "monitoring-prometheus"
      ip               = "192.168.50.249"
      cidr             = 24
      gateway          = "192.168.50.1"
      vlan_id          = 50
      mtu              = 1400
      bridge           = "vmbr0"
      cpu              = 2
      memory_dedicated = 2048
      disk_size        = 10
      datastore_id     = "local-zfs"
      disk_file_format = "raw"
      dns_domain       = "homelab.vincentdupain.com"
      dns_servers      = ["192.168.50.1"]
    }
  }
}