locals {
  downloads = {
    for k, vm in var.vms : "${vm.host_node}_${k}" => {
      node = vm.host_node
    }
  }
}

# Download cloud image to each node (only downloads once, cached by PVE)
resource "proxmox_download_file" "cloud_image" {
  for_each = local.downloads

  node_name    = each.value.node
  content_type = "iso"
  datastore_id = "local"
  file_name    = "debian-13-${split("_", each.key)[1]}.iso"
  url          = "https://gemmei.ftp.acc.umu.se/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  verify       = false
}

# VMs
resource "proxmox_virtual_environment_vm" "debian_vm" {
  for_each = var.vms

  node_name    = each.value.host_node
  vm_id        = each.value.vmid
  name         = each.value.hostname
  tags         = each.value.tags
  on_boot      = true
  started      = true
  bios         = "ovmf"
  machine      = "q35"
  scsi_hardware = "virtio-scsi-pci"

  agent {
    enabled = true
    timeout = "10m"
  }

  cpu {
    cores = each.value.cpu
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  network_device {
    bridge  = each.value.bridge
    vlan_id = each.value.vlan_id
    mtu     = each.value.mtu
  }

  efi_disk {
    datastore_id = each.value.datastore_id
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    datastore_id = each.value.datastore_id
    interface    = "scsi0"
    cache        = "writethrough"
    discard      = "on"
    ssd          = "true"
    file_format  = each.value.disk_file_format
    size         = each.value.disk_size
    # Use the downloaded cloud image as the disk source
    file_id      = proxmox_download_file.cloud_image["${each.value.host_node}_${each.key}"].id
  }

  boot_order = ["scsi0"]

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = each.value.datastore_id

    ip_config {
      ipv4 {
        address = "${each.value.ip}/${each.value.cidr}"
        gateway = each.value.gateway
      }
    }

    dns {
      domain  = each.value.dns_domain
      servers = each.value.dns_servers
    }

    user_account {
      username = each.value.user
      keys     = [var.ssh_public_key]
    }
  }

  lifecycle {
    ignore_changes = [
      disk[0].file_id,
    ]
  }
}