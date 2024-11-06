job "cinemagic" {
  datacenters = ["dc1"]
  type        = "service"

  group "cinemagic" {

    network {
      port "http" {
        to = 80
      }
    }

    service {
      port = "http"
      name = "cinemagic-http"
      tags = [
        "cinemagic",
        "urlprefix-/",
        "traefik.enable=true",
        "traefik.http.routers.cinemagic.rule=Host(`cinemagic.ai`)",
        "traefik.http.routers.cinemagic.entrypoints=web-secure",
        "traefik.http.routers.cinemagic.tls.certresolver=main"
      ]
    }
    
    task "cinemagic-task" {
      driver = "docker"

      resources {
        cpu    = 100
        memory = 200
      }
      config {
        image = "gerain/wesite-cinemagic:latest"
        ports = ["http"]
      }
    }
  }
}