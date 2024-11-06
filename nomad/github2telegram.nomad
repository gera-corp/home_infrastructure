job "github2telegram" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "tools"

  group "github2telegram-group" {

    volume "github2telebot-db" {
      type            = "csi"
      source          = "github2telebot-db"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "github2telegram_bot" {
      driver = "docker"

      resources {
        cpu    = 100
        memory = 50
      }
      config {
        image = "gerain/github2telegram:test2"
        volumes = [
          "app/config.yaml:/app/config.yaml"
        ]
        logging {
          type = "fluentd"
          config {
            fluentd-address = "fluentd-port.service.consul:24224"
            tag             = "docker.${NOMAD_TASK_NAME}"
          }
        }
      }
      vault {
        policies = ["github2telegram-bot"]
        env      = true
      }
      volume_mount {
        volume      = "github2telebot-db"
        destination = "/db"
        read_only   = false
      }
      template {
        change_mode = "restart"
        destination = "app/config.yaml"
        perms       = "755"
        data        = <<EOH
---
# Port for Debug info
# listen: ":6060"
logger:
- logger: ''
  file: stdout
  level: info
  encoding: json
  encoding_time: iso8601
  encoding_duration: seconds
# Only sqlite3 was tested
database_type: sqlite3
database_url: "/db/github2telegram.sqlite3"
database_login: ''
database_password: ''
# Username that will have access to bot controls. Currently only one can be specified
{{- with secret "secret/tools/github2telegram-bot" }}
admin_username: "{{.Data.ADMIN_USER}}"
# Please note, that github might ban bot if you are polling too quick, safe option is about 10 minutes for moderate amount of feeds (100)
polling_interval: "30m"
endpoints:
  # Currently only telegram is supported
  telegram:
    token: "{{.Data.BOT_TOKEN}}"
{{- end }}
    type: telegram
EOH
      }
    }
  }
}