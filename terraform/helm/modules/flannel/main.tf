resource "helm_release" "flannel" {
  name             = "flannel"
  repository       = "https://flannel-io.github.io/flannel/"
  chart            = "flannel"
  namespace        = "kube-flannel"
  version          = var.chart_version
  create_namespace = true
  set {
    name  = "podCidr"
    value = "10.20.0.0/16"
  }
}
