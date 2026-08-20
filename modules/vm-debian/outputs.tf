output "vm_ids" {
  description = "VM IDs created"
  value = {
    for k, vm in proxmox_virtual_environment_vm.debian_vm : k => vm.vm_id
  }
}

output "vm_ip_addresses" {
  description = "Static IP addresses configured for each VM"
  value = {
    for k, vm in var.vms : k => vm.ip
  }
}

output "vm_names" {
  description = "VM hostnames"
  value = {
    for k, vm in proxmox_virtual_environment_vm.debian_vm : k => vm.name
  }
}

output "vm_ipv4_addresses" {
  description = "IPv4 addresses from QEMU guest agent"
  depends_on = [proxmox_virtual_environment_vm.debian_vm]
  value = {
    for k, vm in proxmox_virtual_environment_vm.debian_vm : k => try(
      [for addr in flatten(vm.ipv4_addresses) : addr if !startswith(addr, "127.")][0],
      vm.initialization[0].ip_config[0].ipv4[0].address
    )
  }
}
