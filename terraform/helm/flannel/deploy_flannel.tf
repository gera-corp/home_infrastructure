module "flannel" {
  source        = "../modules/flannel"
  chart_version = "0.26.0" # https://github.com/flannel-io/flannel/releases
}
