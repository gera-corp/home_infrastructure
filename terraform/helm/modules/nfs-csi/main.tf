resource "helm_release" "nfs-csi" {
  name             = "csi"
  repository       = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/"
  chart            = "nfs-subdir-external-provisioner"
  namespace        = "csi"
  version          = var.chart_version
  create_namespace = true
  set {
    name  = "nfs.server"
    value = "192.168.1.150"
  }
  set {
    name  = "nfs.path"
    value = "/mnt/nfs_share"
  }
}
