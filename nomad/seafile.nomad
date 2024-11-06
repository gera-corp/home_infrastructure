job "seafile" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "tools"
  priority    = 60

  update {
    healthy_deadline  = "15m"
    progress_deadline = "20m"
  }

  group "seafile-group" {
    network {
      port "seafile-http" {
        to = 80
      }
      port "maria-db" {
        static = 3306
        to     = 3306
      }
      port "memcached" {
        static = 11211
        to     = 11211
      }
    }

    service {
      name = "seafile-service"
      port = "seafile-http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.seafile.rule=Host(`sea.geracorp.ru`)",
        "traefik.http.routers.seafile.entrypoints=web-secure",
        "traefik.http.routers.seafile.tls.certresolver=main"
      ]
      check {
        type                     = "http"
        path                     = "/api2/ping/"
        interval                 = "30s"
        timeout                  = "2s"
        failures_before_critical = 10
      }
    }

    volume "seafile-vol" {
      type            = "csi"
      source          = "seafile-vol"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    volume "seafile-mariadb-vol" {
      type            = "csi"
      source          = "seafile-mariadb-vol"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "seafile" {
      leader = true
      driver = "docker"
      config {
        image              = "seafileltd/seafile-mc:10.0.1"
        image_pull_timeout = "15m"
        ports              = ["seafile-http"]
        command            = "bash"
        args = ["-c", <<EOH
sed -i 's/memcached:11211/${MEMCACHED}:11211/' /scripts/bootstrap.py
"/sbin/my_init" "--" "/scripts/enterpoint.sh"
        EOH
        ]
        // logging {
        //   type = "fluentd"
        //   config {
        //     fluentd-address = "fluentd-port.service.consul:24224"
        //     tag             = "${NOMAD_TASK_NAME}"
        //   }
        // }
        dns_servers = [attr.unique.network.ip-address]
      }
      volume_mount {
        volume      = "seafile-vol"
        destination = "/shared"
        read_only   = false
      }
      env {
        NON_ROOT                   = true
        MEMCACHED                  = "memcached.service.consul"
        DB_HOST                    = "mariadb.service.consul"
        DB_ROOT_PASSWD             = "db_dev"               # Requested, the value shuold be root's password of MySQL service.
        TIME_ZONE                  = "Etc/UTC"              # Optional, default is UTC. Should be uncomment and set to your local time zone.
        SEAFILE_ADMIN_EMAIL        = "gera_ivanoff@mail.ru" # Specifies Seafile admin user, default is 'me@example.com'.
        SEAFILE_ADMIN_PASSWORD     = "-_-"                  # Specifies Seafile admin password, default is 'asecret'.
        SEAFILE_SERVER_LETSENCRYPT = false                  # Whether to use https or not.
        SEAFILE_SERVER_HOSTNAME    = "sea.geracorp.ru"      # Specifies your host name if https is enabled.
      }
      resources {
        cpu    = 1000
        memory = 900
      }
    }

    task "mariadb" {
      driver = "docker"
      config {
        image       = "bitnami/mariadb:10.8.8"
        ports       = ["maria-db"]
        dns_servers = [attr.unique.network.ip-address]
        logging {
          type = "fluentd"
          config {
            fluentd-address = "fluentd-port.service.consul:24224"
            tag             = "${NOMAD_TASK_NAME}"
          }
        }
      }
      volume_mount {
        volume      = "seafile-mariadb-vol"
        destination = "/bitnami/mariadb"
        read_only   = false
      }
      env {
        MARIADB_DATABASE      = "seafile_db"
        MARIADB_ROOT_PASSWORD = "db_dev" # Requested, set the root's password of MySQL service.
        MYSQL_LOG_CONSOLE     = true
      }
      resources {
        cpu    = 1000
        memory = 500
      }
      lifecycle {
        hook    = "prestart"
        sidecar = true
      }
      service {
        name = "mariadb"
        port = "maria-db"
      }
    }

    task "memcached" {
      driver = "docker"
      config {
        image       = "memcached:1.6.21"
        entrypoint  = ["memcached", "-m", "256"]
        ports       = ["memcached"]
        dns_servers = [attr.unique.network.ip-address]
        logging {
          type = "fluentd"
          config {
            fluentd-address = "fluentd-port.service.consul:24224"
            tag             = "${NOMAD_TASK_NAME}"
          }
        }
      }

      service {
        name = "memcached"
        port = "memcached"
      }

      resources {
        memory = 300
      }

      lifecycle {
        hook    = "prestart"
        sidecar = true
      }
    }
  }
}
