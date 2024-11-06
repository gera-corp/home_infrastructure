job "prometheus" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "monitoring"

  // constraint {
  //   attribute = "${attr.unique.hostname}"
  //   value     = "nmcs-client-02"
  // }

  group "monitoring" {
    count = 1

    network {
      port "prometheus_ui" {
        static = 9090
        to     = 9090
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    volume "prometheus-db" {
      type            = "csi"
      source          = "prometheus-db"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "prometheus" {
      driver = "docker"
      resources {
        cpu    = 200
        memory = 700
      }

      config {
        image = "prom/prometheus:v2.47.2"
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml"
        ]
        ports = ["prometheus_ui"]
        // logging {
        //   type = "fluentd"
        //   config {
        //     fluentd-address = "fluentd-port.service.consul:24224"
        //     tag             = "${NOMAD_TASK_NAME}"
        //   }
        // }
        dns_servers = [attr.unique.network.ip-address]
      }

      service {
        name = "prometheus"
        tags = ["urlprefix-/"]
        port = "prometheus_ui"

        check {
          name     = "prometheus_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }

      volume_mount {
        volume      = "prometheus-db"
        destination = "/prometheus"
        read_only   = false
      }

      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"
        data        = <<EOH
---
global:
  scrape_interval:     10s
  evaluation_interval: 10s

scrape_configs:

  - job_name: 'nomad_metrics'
    consul_sd_configs:
    - server: 'https://{{ env "NOMAD_IP_prometheus_ui" }}:8501'
      services: ['nomad-client', 'nomad']
      tls_config:
        insecure_skip_verify: true
    relabel_configs:
    - source_labels: ['__meta_consul_tags']
      regex: '(.*)http(.*)'
      action: keep
    metrics_path: /v1/metrics
    scheme: https
    tls_config:
      insecure_skip_verify: true
    params:
      format: ['prometheus']

  - job_name: 'BlueVPS'
    static_configs:
    - targets:
      - 46.246.97.163:9100

  - job_name: 'Proxmox'
    static_configs:
    - targets:
      - 192.168.1.2:9221  # Proxmox-01 VE node with PVE exporter.
      - 192.168.1.3:9221  # Proxmox-02 VE node with PVE exporter.
    metrics_path: /pve
    params:
      module: [default]

  - job_name: 'opnsense'
    static_configs:
    - targets:
      - 192.168.1.1:9100

  - job_name: 'OhmGraphite'
    static_configs:
    - targets: ['10.0.0.11:4445']
EOH
      }
    }
  }
}
