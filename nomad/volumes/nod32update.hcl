# Register external nfs volume with Nomad CSI
# https://www.nomadproject.io/docs/commands/volume/register
type = "csi"
# Unique ID of the volume, volume.source field in a job 
id = "nod32update"
# Display name of the volume.
name      = "nod32update"
namespace = "tools"

# ID of the physical volume from the storage provider
external_id = "csi-nfs"
plugin_id   = "nfs"

# You must provide at least one capability block
# You must provide a block for each capability
# you intend to use in a job's volume block
# https://www.nomadproject.io/docs/commands/volume/register
capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

# https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/docs/driver-parameters.md
context {
  server = "192.168.1.150"
  share  = "/mnt/nfs_share/nod32update/"
}

mount_options {
  # mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
  mount_flags = ["nolock,vers=4.2"]
}
