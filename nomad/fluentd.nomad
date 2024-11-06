job "fluentd" {
  datacenters = ["dc1"]
  type        = "service"

  group "fluentd" {

    network {
      port "fluentd-port" {
        to     = 24224
        static = 24224
      }
    }

    service {
      port = "fluentd-port"
      name = "fluentd-port"
      tags = [
        "fluentd"
      ]
    }

    task "fluentd-task" {
      driver = "docker"

      resources {
        cpu    = 1000
        memory = 512
      }
      // user = "root"
      config {
        image       = "gerain/fluentd_1.16.1:elasticsearch_7.17.7_plugin_5.2.5"
        hostname    = "fluentd-nomad"
        ports       = ["fluentd-port"]
        dns_servers = [attr.unique.network.ip-address]
        volumes = [
          "local/fluent.conf:/fluentd/etc/fluent.conf",
          "local/template.json:/fluentd/templates/template.json"
        ]
      }
      env {
        FLUENTD_CONF = "fluent.conf"
      }
      template {
        destination = "local/fluent.conf"
        data        = <<EOH
<source>
  @type forward
  bind 0.0.0.0
  port 24224
</source>

<filter docker.*>
  @type record_transformer
  <record>
    container.id ${record["container_id"]}
    container.name ${record["container_name"]}
    message ${record["log"]}
  </record>
  remove_keys $["container_id"], $["container_name"], $["log"]
</filter>

<match docker.*>
  @type copy

  <store>
    @type elasticsearch
    hosts elastic.service.consul
    port 9200
    logstash_format true
    logstash_prefix fluentd
    logstash_dateformat %Y%m%d
    include_tag_key true
    index_name fluentd
    type_name fluentd
    tag_key @log_name
    request_timeout 25s
    user fluentd
    password anigil123
    template_name fluentd
    template_file /fluentd/templates/template.json
  </store>

  <store>
    @type stdout
  </store>
</match>

<label @FLUENT_LOG>
  <filter fluent.*>
    @type record_transformer
    <record>
      host "#{Socket.gethostname}"
      ip "#{ENV['NOMAD_IP_fluentd_port']}"
    </record>
  </filter>

  <match fluent.*>
    @type stdout
  </match>
</label>
EOH
      }
      template {
        destination = "local/template.json"
        data        = <<EOH
{ 
  "index_patterns": ["fluentd-*"],
  "mappings": {
    "properties": {
      "@log_name": {
        "type": "text"
      },
      "@timestamp": {
        "type": "date"
      },
      "container": {
        "properties": {
          "id": {
            "type": "keyword"
          },
          "name": {
            "type": "keyword"
          }
        }
      },
      "error": {
        "type": "keyword"
      },
      "message": {
        "type": "keyword"
      },
      "source": {
        "type": "text"
      },
      "worker": {
        "type": "long"
      }
    }
  }
}
EOH
      }
    }
  }
}
