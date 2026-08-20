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

variable "ssh_public_key" {
  description = "SSH public key for cloud-init user"
  type        = string
  sensitive   = true
}

variable "debian_image_url" {
  description = "URL for the Debian 13 cloud image"
  type        = string
  default     = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

variable "ci_user" {
  description = "Cloud-init default user"
  type        = string
  default     = "debian"
}