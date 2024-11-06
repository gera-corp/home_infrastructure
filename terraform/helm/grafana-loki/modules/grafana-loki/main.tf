resource "helm_release" "grafana-loki" {
  name             = "grafana-loki"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "grafana-loki"
  namespace        = "loki"
  version          = var.chart_version
  create_namespace = true
  values           = [file("${path.module}/loki-stack.yaml")]
}
