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
  default = ""
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
  default = "10"
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
  type        = string
  description = "vault username"
}

variable "vault_password" {
  type        = string
  sensitive   = true
  description = "vault password"
}

variable "vault_addr" {
  type    = string
  default = ""
}
