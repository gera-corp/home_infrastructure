terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.3"
    }
  }
}

provider "vault" {
  address = var.vault_addr
  auth_login {
    path = "auth/userpass/login/${var.vault_ausername}"

    parameters = {
      password = var.vault_password
    }
  }
}

provider "proxmox" {
  endpoint  = data.vault_generic_secret.proxmox.data["proxmox_api_url"]
  api_token = data.vault_generic_secret.proxmox.data["proxmox_api_token_id_proxmox_api_token_secret"]
  insecure  = true
}
