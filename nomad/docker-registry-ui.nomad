variable "instance_name" {
  type    = string
  default = "docker-registry-ui"
}

variable "image" {
  type    = string
  default = "joxit/docker-registry-ui:2.5.6"
}

variable "port" {
  type    = number
  default = 80
}

variable "datacenter" {
  type    = string
  default = "dc1"
}

variable "docker_registry_ui_name" {
  type    = string
  default = "docker-registry-ui"
}

variable "namespace" {
  type    = string
  default = "tools"
}

variable "component" {
  type    = string
  default = "nomad"
}

variable "service_instance" {
  type    = string
  default = "tools"
}

variable "env" {
  type    = string
  default = "nonprod"
}

variable "user" {
  type    = string
  default = "docker"
}

variable "pass" {
  type    = string
  default = "-_-"
}

job "docker-registry-ui" {
  id          = var.instance_name
  name        = var.instance_name
  namespace   = var.namespace
  datacenters = [var.datacenter]

  // constraint {
  //   attribute = "${meta.env}"
  //   value     = "${var.env}"
  // }
  // constraint {
  //   attribute = "${meta.component}"
  //   value     = "${var.component}"
  // }
  // constraint {
  //   attribute = "${meta.service_instance}"
  //   value     = "${var.service_instance}"
  // }

  update {
    stagger      = "10s"
    max_parallel = 1
  }

  group "docker-registry-ui-gp" {
    count = 1

    restart {
      interval = "1m"
      attempts = 4
      delay    = "15s"
      mode     = "delay"
    }

    network {
      port "http" {
        to = var.port
      }
    }
    service {
      name = "docker-registry-ui"
      port = "http"
      tags = [
        "docker-registry-ui",
        "traefik.enable=true",
        "traefik.http.routers.docker-registry-ui.rule=Host(`docker-registry-ui.geracorp.ru`)",
        "traefik.http.routers.docker-registry-ui.entrypoints=web-secure",
        "traefik.http.routers.docker-registry-ui.tls.certresolver=main",
        "traefik.http.routers.docker-registry-ui.middlewares=docker-registry-ui-auth",
        "traefik.http.middlewares.docker-registry-ui-auth.basicauth.users=${var.user}:${var.pass}"
      ]
    }

    task "docker-registry-ui-task" {
      driver = "docker"
      config {
        image = var.image
        ports = ["http"]
      }
      env {
        SINGLE_REGISTRY        = "true"
        REGISTRY_TITLE         = "GERACORP Registry"
        DELETE_IMAGES          = "true"
        SHOW_CONTENT_DIGEST    = "false"
        SHOW_CATALOG_NB_TAGS   = "true"
        CATALOG_MIN_BRANCHES   = "1"
        CATALOG_MAX_BRANCHES   = "1"
        TAGLIST_PAGE_SIZE      = "100"
        REGISTRY_SECURED       = "false"
        CATALOG_ELEMENTS_LIMIT = "1000"
        PULL_URL               = "docker-registry.geracorp.ru"
      }
      template {
        destination = "secrets/port.env"
        change_mode = "restart"
        env         = true
        data        = <<EOH
{{- range $tag, $services := services | byTag}}{{ if eq $tag "docker-registry" }}{{range $services}}{{- range service .Name}}
NGINX_PROXY_PASS_URL = "http://{{.Address}}:{{.Port}}"
{{- end}}{{end}}{{end}}{{end}}
        EOH
      }
      resources {
        cpu    = 100
        memory = 300
      }
    }
  }
}
