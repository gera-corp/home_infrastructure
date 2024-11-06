job "slack-bot" {
  datacenters = ["dc1"]
  type        = "service"

  //   constraint {
  //     attribute = "${attr.unique.hostname}"
  //     value     = "nmcs-dns-test"
  //   }

  group "slack-bot-group" {

    network {
      port "slack-bot-port" {
        to = 5000
        // static = 3306
      }
    }

    service {
      port = "slack-bot-port"
      name = "flask-port"
      tags = [
        "grafana",
        "traefik.enable=true",
        "traefik.http.routers.slack-bot.rule=Host(`slack-bot.geracorp.ru`)",
        "traefik.http.routers.slack-bot.entrypoints=web-secure",
        "traefik.http.routers.slack-bot.tls.certresolver=main"
      ]
    }

    task "slack-bot-task" {
      driver = "docker"

      resources {
        cpu    = 200
        memory = 512
      }
      config {
        image = "gerain/slack-email-bot:latest"
        ports = ["slack-bot-port"]
      }

      env {
        SLACK_BOT_TOKEN      = "-_-"
        SLACK_SIGNING_SECRET = "-_-"
        CONTROL_WORD         = "andromeda"
        SMTP_SERVER          = "smtp.gmail.com"
        SUBJECT              = "Check the fucking mail"
        EMAIL_SENDER         = "slacksender@gmail.com"
        EMAIL_RECEIVER       = "alexander.neumyvakin@aparavi.com"
        EMAIL_PASSWORD       = "-_-"
      }
    }
  }
}
