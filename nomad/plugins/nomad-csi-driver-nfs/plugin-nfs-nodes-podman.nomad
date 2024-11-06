job "plugin-nfs-nodes-podman" {
  datacenters = ["dc1"]
  namespace   = "plugins"

  # you can run node plugins as service jobs as well, but this ensures
  # that all nodes in the DC have a copy.
  type = "system"

  group "nodes" {
    restart {
      interval = "10m"
      delay    = "5m"
    }
    task "plugin" {
      driver = "podman"

      config {
        image = "docker://registry.k8s.io/sig-storage/nfsplugin:v4.4.0"

        args = [
          "--v=5",
          "--nodeid=${attr.unique.hostname}",
          "--endpoint=unix:///csi/csi.sock",
          "--drivername=nfs.csi.k8s.io"
        ]

        # node plugins must run as privileged jobs because they
        # mount disks to the host
        privileged = true
      }

      csi_plugin {
        id             = "nfs"
        type           = "node"
        mount_dir      = "/csi"
        health_timeout = "10m"
      }

      resources {
        memory = 100
      }
    }
  }
}

