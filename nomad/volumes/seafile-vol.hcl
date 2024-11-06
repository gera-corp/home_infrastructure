type = "csi"

id = "seafile-vol"

name      = "seafile-vol"
namespace = "tools"

external_id = "csi-nfs"
plugin_id   = "nfs"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

context {
  server = "192.168.1.150"
  share  = "/mnt/nfs_share/seafile/data"
}

mount_options {
  mount_flags = ["nolock,vers=4.2"]
}