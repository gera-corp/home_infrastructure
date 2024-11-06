job "mysql-test" {
  datacenters = ["dc1"]
  type        = "service"

  //   constraint {
  //     attribute = "${attr.unique.hostname}"
  //     value     = "nmcs-dns-test"
  //   }

  group "mysql-test-group" {

    network {
      port "db-port" {
        to     = 3306
        static = 3306
      }
    }

    task "mysql-test-task" {
      driver = "docker"

      service {
        port = "db-port"
        name = "mysql-db-port"

        check {
          type     = "tcp"
          port     = "db-port"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 1000
        memory = 4096
      }
      config {
        image = "mysql:debian"
        ports = ["db-port"]
        // memory_swap = "180m"
        // entrypoint = ["sleep", "3h"]
      }

      env {
        MYSQL_ROOT_PASSWORD = "331pswd331"
      }

    }
  }
}