variable "servers_configuration" {
  description = "Map of configuration for servers"
  type        = any
  default     = {}
}

variable "description" {
  type    = string
  default = "Debian server"
}

variable "vm_id" {
  type    = string
  default = "400"
}

variable "node_name" {
  type    = string
  default = "proxmox-01"
}

variable "clone" {
  type    = string
  default = "debian-11.7.0-amd64"
}

variable "cores" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = string
  default = "1024"
}

variable "datastore_id" {
  type    = string
  default = "SSD256"
}

variable "disk_size" {
  type    = string
  default = "10G"
}

variable "ipv4_address" {
  type    = string
  default = "ip=192.168.1.150/24"
}

variable "gateway" {
  type    = string
  default = "192.168.1.1"
}

variable "ssh_user" {
  type    = string
  default = ""
}

variable "vault_ausername" {
  type = string
}

variable "vault_password" {
  type      = string
  sensitive = true
}

variable "vault_addr" {
  type    = string
  default = ""
}

variable "provisioner_commands" {
  type    = string
  default = ""
}

variable "provisioning_node" {
  type    = bool
  default = false
}

variable "provisioning_master" {
  type    = bool
  default = false
}
