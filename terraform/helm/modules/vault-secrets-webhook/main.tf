resource "helm_release" "bank-vault" {
  name             = "bank-vault"
  repository       = "oci://ghcr.io/bank-vaults/helm-charts"
  chart            = "vault-secrets-webhook"
  namespace        = "vault-infra"
  version          = var.chart_version
  create_namespace = true
  values = [
    "${file("values.yaml")}"
  ]
}

locals {
  manifests_files = fileset("${path.module}/manifests", "*.yaml")
}

locals {
  manifests_content = flatten([
    for file in local.manifests_files : [
      for doc in split("---", file("${path.module}/manifests/${file}")) : yamldecode(trimspace(doc))
    ]
  ])
}

resource "kubernetes_manifest" "vault-secret-webhook" {
  for_each = { for idx, manifest in local.manifests_content : idx => manifest }
  manifest = each.value
}
