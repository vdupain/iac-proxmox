module "lxc_test" {
  source = "../../modules/lxc-container"

  proxmox = var.proxmox

  ssh_keys = var.ssh_keys

  containers = {
    test = {
      host_node        = "pve0"
      hostname         = "lxc-test"
      ip               = "192.168.50.230"
      cidr             = 24
      gateway          = "192.168.50.1"
      vlan_id          = 50
      mtu              = 1400
      bridge           = "vmbr0"
      cpu              = 1
      memory_dedicated = 1024
      memory_swap      = 512
      disk_size        = 4
      datastore_id     = "local-zfs"
      template_file_id = "local:vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"
      description      = "Example LXC test container"
      dns_domain       = "homelab.vincentdupain.com"
      dns_servers      = ["192.168.50.1"]
      unprivileged     = true
      tags             = ["terraform", "lxc", "example"]
    }
  }
}