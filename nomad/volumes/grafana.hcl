type = "csi"

id = "grafana"

name      = "grafana"
namespace = "monitoring"

external_id = "csi-nfs"
plugin_id   = "nfs"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

context {
  server = "192.168.1.150"
  share  = "/mnt/nfs_share/grafana/"
}

mount_options {
  mount_flags = ["nolock,vers=4.2"]
}