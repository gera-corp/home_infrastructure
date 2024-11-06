job "plex-tv" {
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "ubuntu-docker"
  }

  group "plex-group" {
    volume "plex-config" {
      type      = "host"
      read_only = false
      source    = "plex-config"
    }
    volume "plex-transcode" {
      type      = "host"
      read_only = false
      source    = "plex-transcode"
    }
    volume "plex-data" {
      type      = "host"
      read_only = false
      source    = "plex-data"
    }

    task "plex-task" {
      driver = "docker"
      resources {
        cpu    = 1000
        memory = 2000
      }
      volume_mount {
        volume      = "plex-config"
        destination = "/config"
        read_only   = false
      }
      volume_mount {
        volume      = "plex-transcode"
        destination = "/transcode"
        read_only   = false
      }
      volume_mount {
        volume      = "plex-data"
        destination = "/data"
        read_only   = false
      }
      env {
        TZ         = "Europe/Moscow"
        PLEX_CLAIM = "-_-"
      }
      config {
        network_mode = "host"
        image        = "plexinc/pms-docker:latest"
      }
    }
  }
}
