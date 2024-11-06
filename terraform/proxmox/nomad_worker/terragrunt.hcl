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
    "nomad-worker-01" = {
      "clone"        = "114"
      "description"  = "Nomad Worker"
      "vm_id"        = "501"
      "node_name"    = "proxmox-01"
      "cores"        = "4"
      "memory"       = "6144"
      "datastore_id" = "SSD256"
      "disk_size"    = "20"
      "ipv4_address" = "ip=192.168.1.190/24"
    },
    "nomad-worker-02" = {
      "clone"        = "114"
      "description"  = "Nomad Worker"
      "vm_id"        = "502"
      "node_name"    = "proxmox-02"
      "cores"        = "4"
      "memory"       = "6144"
      "datastore_id" = "SSD250Gb"
      "disk_size"    = "20"
      "ipconfig0"    = "ip=192.168.1.191/24"
    }
  }

  vault_addr = "http://vault.service.consul:8200"
}
