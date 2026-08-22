resource "proxmox_virtual_environment_container" "lxc" {
  for_each = var.containers

  node_name     = each.value.host_node
  start_on_boot = true
  started       = true
  unprivileged  = each.value.unprivileged
  tags          = each.value.tags

  cpu {
    cores = each.value.cpu
  }

  memory {
    dedicated = each.value.memory_dedicated
    swap      = each.value.memory_swap
  }

  disk {
    datastore_id = each.value.datastore_id
    size         = each.value.disk_size
  }

  network_interface {
    name    = "eth0"
    bridge  = each.value.bridge
    vlan_id = each.value.vlan_id
    mtu     = each.value.mtu
  }

  features {
    nesting = true
  }

  operating_system {
    template_file_id = each.value.template_file_id
    type             = "debian"
  }

  initialization {
    hostname = each.value.hostname

    dynamic "dns" {
      for_each = each.value.dns_domain != null || each.value.dns_servers != null ? {
        (each.key) = each.value
      } : {}
      content {
        domain  = dns.value.dns_domain
        servers = dns.value.dns_servers
      }
    }

    ip_config {
      ipv4 {
        address = "${each.value.ip}/${each.value.cidr}"
        gateway = each.value.gateway
      }
    }

    user_account {
      keys = [
        var.ssh_public_key,
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC+C79emTtE46iSqxTzqjGNeH8Tu3A6+5jh0WiFL5RC vincent.dupain@protonmail.com",
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyRLx6YuiLftvtcLQY6ZMq5OHUn1PAlQVY+z+8FXwXV vincent.dupain@protonmail.com",
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      initialization[0].dns[0],
    ]
  }
}

resource "time_sleep" "wait_for_ip" {
  depends_on      = [proxmox_virtual_environment_container.lxc]
  create_duration = "15s"
}