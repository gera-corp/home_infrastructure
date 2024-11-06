module "metrics_server" {
  source        = "../modules/metrics_server"
  chart_version = "3.12.2" # https://artifacthub.io/packages/helm/metrics-server/metrics-server
}
