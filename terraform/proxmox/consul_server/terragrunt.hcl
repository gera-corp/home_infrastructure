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
    "consul-server-01" = {
      "clone"        = "104"
      "description"  = "Consul server"
      "vm_id"        = "560"
      "node_name"    = "proxmox-01"
      "cores"        = "2"
      "memory"       = "1024"
      "datastore_id" = "SSD256"
      "disk_size"    = "10"
      "ipv4_address" = "192.168.1.170/24"
    },
    "consul-server-02" = {
      "clone"        = "120"
      "description"  = "Consul server"
      "vm_id"        = "561"
      "node_name"    = "proxmox-02"
      "cores"        = "2"
      "memory"       = "1024"
      "datastore_id" = "SSD256"
      "disk_size"    = "10"
      "ipv4_address" = "192.168.1.171/24"
    },
    "consul-server-03" = {
      "clone"        = "120"
      "description"  = "Consul server"
      "vm_id"        = "562"
      "node_name"    = "proxmox-02"
      "cores"        = "2"
      "memory"       = "1024"
      "datastore_id" = "SSD256"
      "disk_size"    = "10"
      "ipv4_address" = "192.168.1.172/24"
    }
  }

  vault_addr = "http://vault.service.consul:8200"
}
