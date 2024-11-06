type = "csi"

id = "traefik-crt"

name      = "traefik-crt"
namespace = "tools"

external_id = "csi-nfs"
plugin_id   = "nfs"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

context {
  server = "192.168.1.150"
  share  = "/mnt/nfs_share/traefik-crt/"
}

mount_options {
  mount_flags = ["nolock,vers=4.2"]
}
