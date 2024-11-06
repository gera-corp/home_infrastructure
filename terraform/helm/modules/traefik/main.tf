resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://helm.traefik.io/traefik"
  chart            = "traefik"
  namespace        = "traefik"
  version          = var.chart_version
  create_namespace = true
  values           = [file("${path.module}/values.yaml")]
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
resource "kubernetes_manifest" "traefik-manifests" {
  for_each = { for idx, manifest in local.manifests_content : idx => manifest }
  manifest = each.value
}
