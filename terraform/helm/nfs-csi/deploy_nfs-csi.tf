module "nfs-csi" {
  source        = "../modules/nfs-csi"
  chart_version = "4.0.18" # https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/releases
}
