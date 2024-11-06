module "flannel" {
  source        = "./modules/kubecost"
  chart_version = "2.3.4" # https://github.com/kubecost/cost-analyzer-helm-chart/releases
}
