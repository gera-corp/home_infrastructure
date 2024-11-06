job "openspeedtest" {
  datacenters = ["dc1"]
  type        = "service"

  group "openspeedtest" {

    network {
      port "http" {
          to = 3000
      }
    }

    service {
      port = "http"
      name = "openspeedtest"
      tags = [
        "openspeedtest",
        "traefik.enable=true",
        "traefik.http.routers.openspeedtest.rule=Host(`openspeedtest.home.local`)",
        "traefik.http.routers.openspeedtest.entrypoints=web-secure",
        "traefik.http.routers.openspeedtest.tls=true"
      ]
    }
    
    task "openspeedtest" {
      driver = "docker"

      resources {
        cpu    = 4000
        memory = 500
      }
      config {
        image = "openspeedtest/latest"
        ports = ["http"]
      }
    }
  }
}