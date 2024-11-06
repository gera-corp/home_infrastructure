job "network-multitool2" {
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "nmcs-dns-test"
  }

  group "network-multitool-group" {

    network {
      mode = "cni/dbnet"
    }

    task "network-multitool-task" {
      driver = "docker"

      resources {
        cpu    = 100
        memory = 100
      }
      config {
        image = "praqma/network-multitool:latest"
      }
    }
  }
}