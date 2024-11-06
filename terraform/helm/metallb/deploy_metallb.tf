module "metallb" {
  source        = "../modules/metallb"
  chart_version = "0.14.8" # https://github.com/metallb/metallb/releases
}
