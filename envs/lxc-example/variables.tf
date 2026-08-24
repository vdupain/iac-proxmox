variable "proxmox" {
  description = "Proxmox connection configuration"
  type = object({
    endpoint           = string
    insecure           = optional(bool, true)
    api_token          = optional(string)
    username           = optional(string)
    password           = optional(string)
    ssh_agent          = optional(bool, false)
    random_vm_ids      = optional(bool, false)
    random_vm_id_start = optional(number, 1000)
    random_vm_id_end   = optional(number, 2000)
  })
  sensitive = true
}

variable "ssh_keys" {
  description = "SSH public keys for the container user"
  type        = list(string)
  sensitive   = true
}