resource "proxmox_virtual_environment_vm" "debian_server" {
  for_each    = var.servers_configuration
  name        = each.key
  description = lookup(each.value, "description", var.description)
  vm_id       = lookup(each.value, "vm_id", var.vm_id)
  node_name   = lookup(each.value, "node_name", var.node_name)
  on_boot     = true

  clone {
    datastore_id = lookup(each.value, "datastore_id", var.datastore_id)
    vm_id        = lookup(each.value, "clone", var.clone)
  }

  cpu {
    cores = lookup(each.value, "cores", var.cores)
  }

  memory {
    dedicated = lookup(each.value, "memory", var.memory)
  }

  vga {
    type   = "std"
    memory = 16
  }

  initialization {
    datastore_id = lookup(each.value, "datastore_id", var.datastore_id)
    ip_config {
      ipv4 {
        address = lookup(each.value, "ipv4_address", var.ipv4_address)
        gateway = lookup(each.value, "gateway", var.gateway)
      }
    }
  }

  network_device {
    bridge = "vmbr1"
  }

  disk {
    datastore_id = lookup(each.value, "datastore_id", var.datastore_id)
    interface    = "virtio0"
    ssd          = false
    file_format  = "raw"
    size         = lookup(each.value, "disk_size", var.disk_size)
    iothread     = true
    discard      = "on"
    replicate    = "true"
  }
  lifecycle {
    ignore_changes = [
      disk[0].replicate
    ]
  }
}
