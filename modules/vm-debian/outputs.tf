output "vm_ids" {
  description = "Map of VM IDs keyed by hostname"
  value = {
    for k, vm in proxmox_virtual_environment_vm.vm : k => vm.id
  }
}

output "vm_ipv4_addresses" {
  description = "Map of VM IPv4 addresses keyed by hostname"
  value = {
    for k, vm in proxmox_virtual_environment_vm.vm : k => vm.initialization[0].ip_config[0].ipv4[0].address
  }
}

output "qemu_ipv4_addresses" {
  description = "QEMU guest agent IPv4 addresses (observed after boot)"
  depends_on  = [time_sleep.wait_for_ip]
  value = {
    for k, vm in proxmox_virtual_environment_vm.vm : k => try(
      [for i, name in vm.network_interface_names : vm.ipv4_addresses[i][0]
      if !startswith(name, "lo") && length(vm.ipv4_addresses[i]) > 0][0],
      vm.initialization[0].ip_config[0].ipv4[0].address
    )
  }
}

output "vm_names" {
  description = "Map of VM names keyed by hostname"
  value = {
    for k, vm in proxmox_virtual_environment_vm.vm : k => vm.name
  }
}