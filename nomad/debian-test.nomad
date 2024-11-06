job "debian-test" {
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "nmcs-dns-test"
  }

  group "debian-test-group" {

    // network {
    //   port "http" {
    //     to = 80
    //   }
    // }

    // service {
    //   port = "http"
    //   name = "miniblog"
    // }

    task "debian-test-task" {
      driver = "docker"
      resources {
        cpu    = 100
        memory = 100
      }
      config {
        image = "debian:bullseye"
        // memory_swap = "180m"
        entrypoint = ["sleep", "3h"]
      }
    }
  }
}