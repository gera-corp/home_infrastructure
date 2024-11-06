resource "kubernetes_manifest" "gitlab" {
  manifest = yamldecode(templatefile("${path.module}/gitlab.yaml", {
    chartVersion = var.chartVersion
  }))
}
