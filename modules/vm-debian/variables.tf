variable "proxmox" {
  description = "Proxmox provider configuration"
  type = object({
    endpoint  = string
    insecure  = bool
    api_token = string
  })
  sensitive = true
}

variable "vms" {
  description = "Configuration for Debian VMs"
  type = map(object({
    host_node    = string
    vmid         = optional(number)
    hostname     = string
    ip           = string
    gateway      = string
    cidr         = number
    dns_servers  = optional(list(string), ["192.168.50.1"])
    dns_domain   = optional(string, "homelab.vincentdupain.com")
    vlan_id      = optional(number)
    mtu          = optional(number)
    bridge       = optional(string, "vmbr0")
    cpu          = optional(number, 2)
    memory       = optional(number, 2048)
    disk_size    = optional(number, 20)
    datastore_id = optional(string, "local-zfs")
    disk_file_format = optional(string, "qcow2")
    user         = optional(string, "monitoring")
    tags         = optional(list(string), ["terraform", "debian"])
  }))
}

variable "ssh_public_key" {
  description = "SSH public key for cloud-init user"
  type        = string
  sensitive   = true
}
