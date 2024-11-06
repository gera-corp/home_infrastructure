job "vlmcsd" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "tools"

  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "ubuntu-docker"
  }

  group "vlmcsd-group" {

    network {
      port "vlmcsd" {
        to     = 1688
        static = 1688
      }
    }

    task "vlmcsd" {
      driver = "docker"

      service {
        port = "vlmcsd"
        name = "vlmcsd"
      }
      resources {
        cpu    = 100
        memory = 50
      }
      config {
        image = "mikolatero/vlmcsd"
        ports = ["vlmcsd"]
      }
    }
  }
}