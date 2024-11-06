module "traefik" {
  source        = "../modules/traefik"
  chart_version = "33.0.0" # https://github.com/traefik/traefik-helm-chart/releases
}
