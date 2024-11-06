job "open-monitor" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "tools"

  group "open-monitor-group" {
    network {
      port "http" {
        to     = 80
        static = 8083
      }
    }

    service {
      port = "http"
      name = "open-monitor"
    }

    task "open-monitor" {
      driver = "docker"

      resources {
        cpu    = 200
        memory = 200
      }
      config {
        image = "gerain/open-monitor:latest"
        ports = ["http"]
      }

      env {
        OPENVPNMONITOR_DEFAULT_DATETIMEFORMAT = "%%d/%%m/%%Y"
        OPENVPNMONITOR_DEFAULT_MAPSHEIGHT     = "500"
        OPENVPNMONITOR_SITES_0_PORT           = "5555"
        OPENVPNMONITOR_DEFAULT_MAPS           = "True"
        OPENVPNMONITOR_SITES_0_SHOWDISCONNECT = "False"
        OPENVPNMONITOR_SITES_0_HOST           = "46.246.97.163"
        OPENVPNMONITOR_SITES_0_NAME           = "BlueVPS"
        OPENVPNMONITOR_DEFAULT_LATITUDE       = "-37"
        OPENVPNMONITOR_DEFAULT_LONGITUDE      = "144"
        OPENVPNMONITOR_DEFAULT_SITE           = "Gera"
        OPENVPNMONITOR_SITES_0_ALIAS          = "TCP"
      }
    }
  }
}