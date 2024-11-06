job "nextcloud" {
  datacenters = ["dc1"]
  type        = "service"

  group "nextcloud-gp" {
    network {
      port "http" {
        to = 80
      }
      port "db-dataport" {
        to     = 3306
        static = 3306
      }
    }
    service {
      port = "http"
      name = "nextcloud-http"
    }
    service {
      port = "db-dataport"
      name = "db-dataport"
    }

    task "nextcloud" {
      driver = "docker"
      resources {
        cpu    = 1000
        memory = 1024
      }
      config {
        image = "nextcloud"
        ports = ["http"]
      }
      env {
        MYSQL_PASSWORD = "123"
        MYSQL_DATABASE = "nextcloud"
        MYSQL_USER     = "nextcloud"
        MYSQL_HOST     = "${NOMAD_HOST_IP_db-dataport}"
      }
    }

    task "mysql" {
      driver = "docker"
      resources {
        cpu    = 1000
        memory = 1024
      }
      config {
        image = "mysql:debian"
        ports = ["db-dataport"]
      }
      env {
        MYSQL_ROOT_PASSWORD = "331"
        MYSQL_USER          = "nextcloud"
        MYSQL_PASSWORD      = "123"
        MYSQL_DATABASE      = "nextcloud"
      }
    }
  }
}