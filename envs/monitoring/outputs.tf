output "vm_ids" {
  description = "Map of VM IDs keyed by hostname"
  value       = module.monitoring_vms.vm_ids
}

output "vm_ipv4_addresses" {
  description = "Map of VM IPv4 addresses keyed by hostname"
  value       = module.monitoring_vms.vm_ipv4_addresses
}

output "qemu_ipv4_addresses" {
  description = "QEMU guest agent IPv4 addresses (observed after boot)"
  value       = module.monitoring_vms.qemu_ipv4_addresses
}

output "vm_names" {
  description = "Map of VM names keyed by hostname"
  value       = module.monitoring_vms.vm_names
}