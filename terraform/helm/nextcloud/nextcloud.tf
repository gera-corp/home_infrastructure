module "nextcloud" {
  source        = "../modules/nextcloud"
  chart_version = "6.1.0" # https://artifacthub.io/packages/helm/nextcloud/nextcloud
}
