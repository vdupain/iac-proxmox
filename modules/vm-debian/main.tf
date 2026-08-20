locals {
  # Unique image download key per (host_node, image_url) pair
  image_downloads = toset([
    for k, v in var.vms : "${v.host_node}:${var.debian_image_url}"
  ])
}

resource "proxmox_download_file" "debian_image" {
  for_each = local.image_downloads

  node_name    = split(":", each.key)[0]
  content_type = "iso"
  datastore_id = "local"

  file_name           = "debian-13-genericcloud-amd64.qcow2"
  url                 = var.debian_image_url
  overwrite           = false
  overwrite_unmanaged = true
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.vms

  node_name = each.value.host_node
  name      = each.value.hostname
  tags      = ["terraform", "debian", "monitoring"]
  on_boot   = true
  started   = true

  machine       = "q35"
  scsi_hardware = "virtio-scsi-pci"

  agent {
    enabled = true
    timeout = "30s"
    wait_for_ip {
      disabled = false
      ipv4     = true
    }
  }

  cpu {
    cores = each.value.cpu
    type  = "host"
  }

  memory {
    dedicated = each.value.memory_dedicated
  }

  network_device {
    bridge  = each.value.bridge
    vlan_id = each.value.vlan_id
    mtu     = each.value.mtu
  }

  disk {
    datastore_id = each.value.datastore_id
    interface    = "scsi0"
    cache        = "writethrough"
    discard      = "on"
    ssd          = "true"
    file_format  = each.value.disk_file_format
    size         = each.value.disk_size
    file_id      = proxmox_download_file.debian_image["${each.value.host_node}:${var.debian_image_url}"].id
  }

  boot_order = ["scsi0"]

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = each.value.datastore_id

    user_account {
      username = var.ci_user
      keys     = [var.ssh_public_key]
    }

    dynamic "dns" {
      for_each = (each.value.dns_domain != null || each.value.dns_servers != null) ? [1] : []
      content {
        domain  = each.value.dns_domain
        servers = each.value.dns_servers
      }
    }

    ip_config {
      ipv4 {
        address = "${each.value.ip}/${each.value.cidr}"
        gateway = each.value.gateway
      }
    }
  }

  lifecycle {
    ignore_changes = [
      initialization[0].dns[0],
    ]
  }
}

resource "time_sleep" "wait_for_ip" {
  depends_on      = [proxmox_virtual_environment_vm.vm]
  create_duration = "30s"
}