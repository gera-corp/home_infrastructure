module "cert-manager" {
  source        = "../modules/cert-manager"
  chart_version = "1.16.1" # https://artifacthub.io/packages/helm/cert-manager/cert-manager
}
