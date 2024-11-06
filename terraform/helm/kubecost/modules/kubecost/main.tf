resource "helm_release" "kubecost" {
  name             = "kubecost"
  repository       = "https://kubecost.github.io/cost-analyzer/"
  chart            = "cost-analyzer"
  namespace        = "kubecost"
  version          = var.chart_version
  create_namespace = true
  values           = [file("${path.module}/values.yaml")]
}
