terraform {
  source = "../../modules/kubernetes/"
}

remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}

inputs = {
  servers_configuration = {
    "control-plane-01" = {
      "clone"        = "106"
      "description"  = "K8S-node"
      "vm_id"        = "200"
      "node_name"    = "proxmox-01"
      "cores"        = "4"
      "memory"       = "4096"
      "datastore_id" = "HDD02TB1"
      "disk_size"    = "20"
      "ipv4_address" = "192.168.1.200/24"
    },
    "control-plane-02" = {
      "clone"        = "101"
      "description"  = "K8S-node"
      "vm_id"        = "201"
      "node_name"    = "proxmox-02"
      "cores"        = "4"
      "memory"       = "4096"
      "datastore_id" = "SSD128"
      "disk_size"    = "20"
      "ipv4_address" = "192.168.1.201/24"
    },
    "control-plane-03" = {
      "clone"        = "109"
      "description"  = "K8S-node"
      "vm_id"        = "202"
      "node_name"    = "proxmox-03"
      "cores"        = "4"
      "memory"       = "4096"
      "datastore_id" = "NVME01-250GB"
      "disk_size"    = "20"
      "ipv4_address" = "192.168.1.202/24"
    }
  }

  provisioning_master = true
  ssh_user            = "debian"
  vault_addr          = "https://vault-cluster.local.geracorp.work"
}
