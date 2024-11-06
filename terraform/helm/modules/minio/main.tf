resource "helm_release" "minio" {
  name             = "minio"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "minio"
  namespace        = "minio"
  version          = var.chart_version
  create_namespace = true
  values           = [file("${path.module}/minio.yaml")]
  set {
    name  = "auth.rootUser"
    value = "minio-admin"
  }
  set {
    name  = "auth.rootPassword"
    value = "anigil123"
  }
}
