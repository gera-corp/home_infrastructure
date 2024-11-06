type = "csi"

id = "seafile-mariadb-vol"

name      = "seafile-mariadb-vol"
namespace = "tools"

external_id = "csi-nfs"
plugin_id   = "nfs"

capability {
  access_mode     = "multi-node-multi-writer"
  attachment_mode = "file-system"
}

context {
  server = "192.168.1.150"
  share  = "/mnt/nfs_share/seafile/mysql"
}

mount_options {
  mount_flags = ["nolock,vers=4.2"]
}