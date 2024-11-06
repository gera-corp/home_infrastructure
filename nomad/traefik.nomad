job "traefik" {
  datacenters = ["dc1"]
  namespace   = "tools"
  type        = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "nomad-worker-01"
  }

  group "traefik-group" {
    count = 1

    network {
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
      port "admin" {
        static = 8080
      }
      port "nomad-https" {
        static = 4646
      }
    }

    service {
      name = "traefik-http"
      port = "http"
      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    service {
      name = "traefik-https"
      port = "https"
    }

    service {
      name = "nomad"
      port = "nomad-https"
      tags = [
        "nomad",
        "traefik.enable=true",
        "traefik.http.routers.nomad.rule=Host(`nomad.geracorp.ru`)",
        "traefik.http.routers.nomad.entrypoints=web-secure",
        "traefik.http.routers.nomad.tls.certresolver=main",
        "traefik.http.services.nomad.loadbalancer.server.scheme=https"
      ]
    }

    volume "traefik-crt" {
      type            = "csi"
      source          = "traefik-crt"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "traefik-task" {
      driver = "docker"

      volume_mount {
        volume      = "traefik-crt"
        destination = "/letsencrypt"
        read_only   = false
      }

      config {
        image       = "traefik:2.10.5"
        ports       = ["admin", "http", "https"]
        dns_servers = [attr.unique.network.ip-address]
        logging {
          type = "fluentd"
          config {
            fluentd-address = "fluentd-port.service.consul:24224"
            tag             = "docker.${NOMAD_TASK_NAME}"
          }
        }
        args = [
          "--api.dashboard=true",
          "--api.insecure=true", ### For Test only, please do not use that in production
          "--log.level=INFO",
          "--serversTransport.insecureSkipVerify=true",

          "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entryPoints.web-secure.address=:${NOMAD_PORT_https}",

          "--entrypoints.web.http.redirections.entryPoint.to=web-secure",
          "--entrypoints.web.http.redirections.entryPoint.scheme=https",

          "--experimental.http3=true",
          "--entrypoints.web-secure.http3.advertisedport=443",

          "--providers.nomad=false",
          "--providers.nomad.namespace=default",
          "--providers.nomad.endpoint.address=http://nomad.service.consul:4646", ### IP to your nomad server

          "--providers.consulcatalog=true",
          "--providers.consulCatalog.prefix=traefik",
          "--providers.consulCatalog.exposedByDefault=false",
          "--providers.consulCatalog.endpoint.address=http://consul.service.consul:8500",
          "--providers.consulcatalog.endpoint.token=225114bb-0a83-7cc7-af38-f641878423a0",

          "--certificatesresolvers.main.acme.httpchallenge=true",
          "--certificatesresolvers.main.acme.httpchallenge.entrypoint=web",
          "--certificatesresolvers.main.acme.email=gera_ivanoff@mail.ru",
          "--certificatesresolvers.main.acme.storage=/letsencrypt/acme.json"
        ]
      }
    }
  }
}
