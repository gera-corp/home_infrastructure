variable "user" {
  type    = string
  default = "user"
}

variable "pass" {
  type    = string
  default = "-_-"
}

job "miniblog" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "tools"

  // constraint {
  //   attribute = "${attr.unique.hostname}"
  //   value     = "nomad-worker-02"
  // }

  group "miniblog" {

    network {
      port "http" {
        to = 80
      }
    }
    // volume "dirControl" {
    //   type            = "csi"
    //   source          = "nfsaparavi"
    //   access_mode     = "multi-node-multi-writer"
    //   attachment_mode = "file-system"
    // }
    service {
      port = "http"
      name = "miniblog"
      tags = [
        "miniblog",
        "miniblog-auth",
        "traefik.enable=true",
        "traefik.http.routers.miniblog.rule=Host(`miniblog-test.geracorp.ru`)",
        "traefik.http.routers.miniblog.entrypoints=web-secure",
        "traefik.http.routers.miniblog.tls.certresolver=main",
        "traefik.http.routers.miniblog.middlewares=miniblog-auth",
        "traefik.http.middlewares.miniblog-auth.basicauth.users=${var.user}:${var.pass}"
      ]
    }

    task "miniblog" {
      driver = "docker"

      // volume_mount {
      //   volume      = "dirControl"
      //   destination = "/mnt/control"
      // }

      resources {
        cpu    = 100
        memory = 100
      }
      config {
        image       = "gerain/miniblog.core:master-6"
        ports       = ["http"]
        dns_servers = [attr.unique.network.ip-address]
      }

      env {
        PORT = "${NOMAD_PORT_http}"
      }

      template {
        destination = "secrets/port.env"
        env         = true
        data        = <<EOH
{{- range $tag, $services := services | byTag}}{{ if eq $tag "grafana" }}{{range $services}}{{- range service .Name}}
GRAFANA = "{{.Address}}:{{.Port}}"
{{- end}}{{end}}{{end}}{{end}}
        EOH
      }

    }
  }
}
