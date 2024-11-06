module "vault-secrets-webhook" {
  source        = "../modules/vault-secrets-webhook"
  chart_version = "1.21.3" # https://github.com/bank-vaults/vault-secrets-webhook/releases
}
