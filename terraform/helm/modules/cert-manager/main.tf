resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = var.chart_version
  create_namespace = true
  set {
    name  = "crds.enabled"
    value = true
  }
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
resource "kubernetes_manifest" "cert-manager-manifests" {
  for_each = { for idx, manifest in local.manifests_content : idx => manifest }
  manifest = each.value
}
