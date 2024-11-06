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
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = lookup(each.value, "memory", var.memory)
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

  vga {
    memory = 16
    type   = "std"
  }

  disk {
    datastore_id = lookup(each.value, "datastore_id", var.datastore_id)
    interface    = "virtio0"
    ssd          = false
    file_format  = "raw"
    size         = lookup(each.value, "disk_size", var.disk_size)
    iothread     = true
    discard      = "on"
  }
  lifecycle {
    ignore_changes = [
      disk[0].replicate
    ]
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = data.vault_generic_secret.kubernetes.data["ssh_private_key"]
    host        = element(element(self.ipv4_addresses, index(self.network_interface_names, "eth0")), 0)
  }

  provisioner "remote-exec" {
    inline = concat(["echo Provisioning"], [for command in local.provisioner_commands_k8s_master : command if var.provisioning_master])
  }
  provisioner "remote-exec" {
    inline = concat(["echo Provisioning"], [for command in local.provisioner_commands_k8s_node : command if var.provisioning_node])
  }
}

locals {
  provisioner_commands_k8s_master = ["sudo -S kubeadm join ${data.vault_generic_secret.kubernetes.data["kubernete_cluster_address"]} --token ${data.vault_generic_secret.kubernetes.data["token"]} --discovery-token-ca-cert-hash ${data.vault_generic_secret.kubernetes.data["cert_hash"]} --control-plane --certificate-key ${data.vault_generic_secret.kubernetes.data["certificate-key"]}"]
  provisioner_commands_k8s_node   = ["sudo -S kubeadm join ${data.vault_generic_secret.kubernetes.data["kubernete_cluster_address"]} --token ${data.vault_generic_secret.kubernetes.data["token"]} --discovery-token-ca-cert-hash ${data.vault_generic_secret.kubernetes.data["cert_hash"]}"]
}
