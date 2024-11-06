terraform {
  source = "../modules//debian_server"
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
    "nfs-server" = {
      "clone"        = "101"
      "description"  = "NFS Server"
      "vm_id"        = "103"
      "node_name"    = "proxmox-01"
      "cores"        = "2"
      "memory"       = "1024"
      "datastore_id" = "HDD01TB1"
      "disk_size"    = "30"
      "ipv4_address" = "ip=192.168.1.150/24"
    }
  }

  vault_addr = "http://vault.service.consul:8200"
}
