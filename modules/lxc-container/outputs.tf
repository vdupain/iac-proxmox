output "lxc_ids" {
  description = "Map of LXC container IDs keyed by hostname"
  value = {
    for k, c in proxmox_virtual_environment_container.lxc : k => c.id
  }
}

output "lxc_ipv4_addresses" {
  description = "Map of LXC container IPv4 addresses keyed by hostname"
  value = {
    for k, c in proxmox_virtual_environment_container.lxc : k => c.ipv4
  }
}

output "lxc_names" {
  description = "Map of LXC container names keyed by hostname"
  value = {
    for k, c in proxmox_virtual_environment_container.lxc : k => c.initialization[0].hostname
  }
}