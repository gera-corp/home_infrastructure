terraform {
  source = "../../modules/kubernetes"
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
    "node-k8s-01" = {
      "clone"        = "106"
      "description"  = "K8S-node"
      "vm_id"        = "210"
      "node_name"    = "proxmox-01"
      "cores"        = "4"
      "memory"       = "8192"
      "datastore_id" = "SSD256"
      "disk_size"    = "30"
      "ipv4_address" = "192.168.1.210/24"
    },
    "node-k8s-02" = {
      "clone"        = "101"
      "description"  = "K8S-node"
      "vm_id"        = "211"
      "node_name"    = "proxmox-02"
      "cores"        = "4"
      "memory"       = "8192"
      "datastore_id" = "SSD256"
      "disk_size"    = "30"
      "ipv4_address" = "192.168.1.211/24"
    },
    "node-k8s-03" = {
      "clone"        = "109"
      "description"  = "K8S-node"
      "vm_id"        = "212"
      "node_name"    = "proxmox-03"
      "cores"        = "4"
      "memory"       = "8192"
      "datastore_id" = "NVME01-250GB"
      "disk_size"    = "30"
      "ipv4_address" = "192.168.1.212/24"
    }
    "node-k8s-04" = {
      "clone"        = "109"
      "description"  = "K8S-node"
      "vm_id"        = "213"
      "node_name"    = "proxmox-03"
      "cores"        = "4"
      "memory"       = "8192"
      "datastore_id" = "NVME02-250GB"
      "disk_size"    = "30"
      "ipv4_address" = "192.168.1.213/24"
    },
  }

  provisioning_node = true
  ssh_user          = "debian"
  vault_addr        = "https://vault-cluster.local.geracorp.work"
}
