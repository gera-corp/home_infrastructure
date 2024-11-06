module "grafana-loki" {
  source        = "./modules/grafana-loki"
  chart_version = "4.6.20" #https://github.com/bitnami/charts/blob/main/bitnami/grafana-loki/CHANGELOG.md
}
