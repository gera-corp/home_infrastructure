resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server" # https://github.com/kubernetes-sigs/metrics-server/releases
  chart            = "metrics-server"                                   # Official Chart Name
  namespace        = "metrics-server"
  version          = var.chart_version
  create_namespace = true
  values           = [file("${path.module}/metrics-server.yaml")]
}
