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
    "nomad-server-01" = {
      "clone"        = "115"
      "description"  = "Nomad server"
      "vm_id"        = "509"
      "node_name"    = "proxmox-01"
      "cores"        = "2"
      "memory"       = "1024"
      "datastore_id" = "SDD256"
      "disk_size"    = "10"
      "ipv4_address" = "ip=192.168.1.180/24"
    },
    "nomad-server-02" = {
      "clone"        = "115"
      "description"  = "Nomad server"
      "vm_id"        = "510"
      "node_name"    = "proxmox-02"
      "cores"        = "2"
      "memory"       = "1024"
      "datastore_id" = "SDD256"
      "disk_size"    = "10"
      "ipv4_address" = "ip=192.168.1.181/24"
    },
    "nomad-server-03" = {
      "clone"        = "115"
      "description"  = "Nomad server"
      "vm_id"        = "511"
      "node_name"    = "proxmox-02"
      "cores"        = "2"
      "memory"       = "1024"
      "disk_storage" = "SDD256"
      "disk_size"    = "10"
      "ipv4_address" = "ip=192.168.1.182/24"
    }
  }

  vault_addr = "http://vault.service.consul:8200"
}
