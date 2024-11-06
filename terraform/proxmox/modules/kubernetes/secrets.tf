data "vault_generic_secret" "kubernetes" {
  path = "secret/kubernetes"
}
data "vault_generic_secret" "proxmox" {
  path = "secret/proxmox"
}
