job "dnsmasq" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "tools"

  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "nomad-worker-01"
  }

  group "dnsmasq" {

    network {
      port "dnsmasq_ui" {
        to     = 8080
        static = 5380
      }
      port "dnsmasq_53" {
        to     = 53
        static = 54
      }
    }

    task "dnsmasq" {
      driver = "docker"

      resources {
        memory = 100
        cpu    = 500
      }

      config {
        volumes = ["local/dnsmasq.conf:/etc/dnsmasq.conf"]
        image   = "gerain/webproc_dnsmasq:3.3.0"
        ports   = ["dnsmasq_ui", "dnsmasq_53"]
      }

      service {
        name = "dnsmasqui"
        port = "dnsmasq_ui"
      }
      service {
        name = "dnsmasq53"
        port = "dnsmasq_53"
      }

      template {
        change_mode   = "signal"
        change_signal = "SIGHUP"
        perms         = "755"
        destination   = "/local/dnsmasq.conf"
        data          = <<EOH
#dnsmasq config, for a complete example, see:
#  http://oss.segetech.com/intra/srv/dnsmasq.conf
#log all dns queries
log-queries
#dont use hosts nameservers
no-resolv
#use cloudflare as default nameservers, prefer 1^4
#server=1.0.0.1
#server=1.1.1.1
strict-order
#serve all .company queries using a specific nameserver
server=/consul/192.168.1.100#8600
#explicitly define host-ip mappings
#address=/myhost.company/10.0.0.2
cname=mariadb.,mariadb.service.consul
cname=memcached.,memcached.service.consul
EOH
      }
    }
  }
}