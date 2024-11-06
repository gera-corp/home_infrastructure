job "kibana" {
  datacenters = ["dc1"]
  type        = "service"

  //   constraint {
  //     attribute = "${attr.unique.hostname}"
  //     value     = "nmcs-dns-test"
  //   }

  group "kibana-gp" {

    network {
      port "kibana-port" {
        to     = 5601
        static = 5601
      }
    }

    service {
      port = "kibana-port"
      name = "kibana-port"
      tags = [
        "kibana"
      ]
    }

    volume "kibana" {
      type            = "csi"
      source          = "kibana"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "kibana-task" {
      driver = "docker"

      resources {
        cpu    = 1000
        memory = 1024
      }
      config {
        image       = "kibana:7.17.9"
        ports       = ["kibana-port"]
        dns_servers = [attr.unique.network.ip-address]
        // logging {
        //   type = "fluentd"
        //   config {
        //     fluentd-address = "fluentd-port.service.consul:24224"
        //     tag             = "${NOMAD_TASK_NAME}"
        //   }
        // }
      }

      env {
        SERVER_NAME            = "kibana-port.service.consul"
        ELASTICSEARCH_HOSTS    = "http://elastic.service.consul:9200"
        ELASTICSEARCH_USERNAME = "kibana_system"
        ELASTICSEARCH_PASSWORD = "-_-"
      }

      volume_mount {
        volume      = "kibana"
        destination = "/usr/share/kibana/data"
        read_only   = false
      }
    }
  }
}
