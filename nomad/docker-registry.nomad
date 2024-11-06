variable "image_version" {
  type    = string
  default = "registry:2"
}

variable "user" {
  type    = string
  default = "docker"
}

variable "pass" {
  type    = string
  default = "-_-"
}

job "docker-registry" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "tools"

  // constraint {
  //   attribute = "${attr.unique.hostname}"
  //   value     = "nomad-worker-01"
  // }

  group "docker-registry-group" {
    count = 1

    volume "docker_registry_data" {
      type            = "csi"
      source          = "docker_registry_data"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    network {
      port "http" {
        to = 5000
      }
    }

    service {
      name = "docker-registry"
      port = "http"
      tags = [
        "docker-registry",
        "traefik.enable=true",
        "traefik.http.routers.docker-registry.rule=Host(`docker-registry.geracorp.ru`)",
        "traefik.http.routers.docker-registry.entrypoints=web-secure",
        "traefik.http.routers.docker-registry.tls.certresolver=main",
        "traefik.http.routers.docker-registry.middlewares=docker-registry-auth",
        "traefik.http.middlewares.docker-registry-auth.basicauth.users=${var.user}:${var.pass}"
      ]
      check {
        type     = "http"
        path     = "/v2/"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "registry-task" {
      driver = "docker"
      resources {
        cpu    = 1000
        memory = 512
      }
      config {
        image       = "${var.image_version}"
        ports       = ["http"]
        dns_servers = [attr.unique.network.ip-address]
        volumes = [
          "registry/config.yml:/etc/docker/registry/config.yml",
          "registry/entrypoint.sh:/entrypoint.sh"
        ]
      }
      volume_mount {
        volume      = "docker_registry_data"
        destination = "/var/lib/registry"
        read_only   = false
      }
      template {
        destination = "registry/config.yml"
        data        = <<EOH
version: 0.1
log:
  level: info
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
  delete:
    enabled: true
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
    Access-Control-Allow-Origin: ['*']
EOH
      }

      template {
        change_mode = "noop"
        destination = "registry/entrypoint.sh"
        perms       = "755"
        data        = <<EOH
#!/bin/sh
set -e
case "$1" in
    *.yaml|*.yml) set -- registry serve "$@" ;;
    serve|garbage-collect|help|-*) set -- registry "$@" ;;
esac
exec "$@" &
while true;do /bin/registry garbage-collect -m /etc/docker/registry/config.yml; sleep 8h; done
        EOH
      }
    }
  }
}
