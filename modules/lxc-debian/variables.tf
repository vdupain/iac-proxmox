variable "proxmox" {
  description = "Proxmox connection configuration"
  type = object({
    endpoint  = string
    insecure  = optional(bool, true)
    api_token = optional(string)
    username  = optional(string)
    password  = optional(string)
    ssh_agent = optional(bool, false)
  })
  sensitive = true
}

variable "containers" {
  description = "Map of LXC container configurations"
  type = map(object({
    host_node        = string
    hostname         = string
    ip               = string
    cidr             = optional(number, 24)
    gateway          = string
    vlan_id          = optional(number, null)
    mtu              = optional(number, null)
    bridge           = optional(string, "vmbr0")
    cpu              = optional(number, 1)
    memory_dedicated = optional(number, 1024)
    memory_swap      = optional(number, 512)
    disk_size        = optional(number, 4)
    datastore_id     = optional(string, "local-zfs")
    template_file_id = string
    description      = optional(string, "")
    dns_domain       = optional(string, null)
    dns_servers      = optional(list(string), null)
    unprivileged     = optional(bool, true)
  }))
}

variable "ssh_public_key" {
  description = "SSH public key for the LXC container user"
  type        = string
  sensitive   = true
}