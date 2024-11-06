resource "helm_release" "gitlab" {
  name             = "gitlab-operator"
  repository       = "https://charts.gitlab.io" # Official Chart Repo
  chart            = "gitlab-operator"          # Official Chart Name
  namespace        = "gitlab-system"
  version          = var.chart_version
  create_namespace = true
  values           = [file("${path.module}/gitlab-operator.yaml")]
}
