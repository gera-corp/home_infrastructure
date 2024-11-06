module "minio" {
  source        = "../modules/minio"
  chart_version = "14.8.0" # https://artifacthub.io/packages/helm/bitnami/minio
}
