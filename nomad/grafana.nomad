variable "VAULT_ADDR" {
  type    = string
  default = ""
}

job "grafana" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "monitoring"

  // constraint {
  //   attribute = "${attr.unique.hostname}"
  //   value     = "nomad-worker-03"
  // }

  update {
    stagger      = "30s"
    max_parallel = 1
  }

  group "grafana" {
    // restart {
    //   attempts = 2
    //   interval = "10m"
    //   delay = "5m"
    //   mode = "delay"
    // }

    network {
      port "http" {
        to = 3000
      }
    }

    service {
      name = "grafana"
      port = "http"
      tags = [
        "grafana",
        "traefik.enable=true",
        "traefik.http.routers.grafana.rule=Host(`mon.geracorp.ru`)",
        "traefik.http.routers.grafana.entrypoints=web-secure",
        "traefik.http.routers.grafana.tls.certresolver=main"
      ]
    }

    volume "grafana" {
      type            = "csi"
      source          = "grafana"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "grafana" {
      driver = "docker"
      config {
        image       = "grafana/grafana:10.2.0"
        ports       = ["http"]
        dns_servers = [attr.unique.network.ip-address]
        logging {
          type = "fluentd"
          config {
            fluentd-address = "fluentd-port.service.consul:24224"
            tag             = "docker.${NOMAD_TASK_NAME}"
          }
        }
      }

      // env {
      // GF_LOG_LEVEL = "DEBUG"
      // GF_LOG_MODE = "console"
      // GF_SERVER_HTTP_PORT = "${NOMAD_PORT_http}"
      // GF_PATHS_PROVISIONING = "/local/provisioning"
      // }

      // artifact {
      //   source      = "github.com/burdandrei/nomad-monitoring/examples/grafana/provisioning"
      //   destination = "local/provisioning/"
      // }

      // artifact {
      //   source      = "github.com/burdandrei/nomad-monitoring/examples/grafana/dashboards"
      //   destination = "local/dashboards/"
      // }

      // env {
      //   GF_INSTALL_PLUGINS = "grafana-piechart-panel"
      //   VAULT_ADDR         = var.VAULT_ADDR
      // }

      env {
        GF_LOG_LEVEL = "INFO"
        GF_LOG_MODE  = "console"
      }

      resources {
        cpu    = 100
        memory = 300
      }

      volume_mount {
        volume      = "grafana"
        destination = "/var/lib/grafana"
        read_only   = false
      }
    }
  }
}
