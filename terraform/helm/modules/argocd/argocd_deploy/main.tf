resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm" # Official Chart Repo
  chart            = "argo-cd"                              # Official Chart Name
  namespace        = "argocd"
  version          = var.chart_version
  create_namespace = true
  values = [
    templatefile("${path.module}/argocd.yaml", {
      avp_image_version_tag = var.avp_image_version_tag
      avp_version           = var.avp_version
    })
  ]
}
