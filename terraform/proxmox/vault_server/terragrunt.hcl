terraform {
  source = "../modules/debian_server"
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
    "vault-server-01" = {
      "clone"        = "111"
      "description"  = "Vault server"
      "vm_id"        = "550"
      "node_name"    = "proxmox-01"
      "cores"        = "2"
      "memory"       = "1024"
      "datastore_id" = "SSD256"
      "disk_size"    = "10"
      "ipv4_address" = "192.168.1.160/24"
    },
    "vault-server-02" = {
      "clone"        = "113"
      "description"  = "Vault server"
      "vm_id"        = "551"
      "node_name"    = "proxmox-02"
      "cores"        = "2"
      "memory"       = "1024"
      "datastore_id" = "SSD256"
      "disk_size"    = "10"
      "ipv4_address" = "192.168.1.161/24"
    },
    "vault-server-03" = {
      "clone"        = "114"
      "description"  = "Vault server"
      "vm_id"        = "552"
      "node_name"    = "proxmox-03"
      "cores"        = "2"
      "memory"       = "1024"
      "datastore_id" = "NVME01-250GB"
      "disk_size"    = "10"
      "ipv4_address" = "192.168.1.162/24"
    }
  }

  vault_addr = "https://vault-cluster.local.geracorp.work"
}
