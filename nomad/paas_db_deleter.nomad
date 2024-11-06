variable "image" {
  type    = string
  default = "mysql:8.0.30-debian"
}

variable "datacenter" {
  type    = string
  default = "dc1"
}

variable "namespace" {
  type    = string
  default = "default"
}

job "paas_db_deleter" {
  namespace   = var.namespace
  datacenters = [var.datacenter]
  type        = "batch"

  // constraint {
  //   attribute = "${meta.service_instance}"
  //   value     = "tools"
  // }

  periodic {
    cron             = "*/1 * * * *"
    prohibit_overlap = true
  }

  group "paas_db_deleter-group" {
    count = 1

    task "paas_db_deleter-task" {
      driver = "docker"
      config {
        image      = var.image
        entrypoint = ["bash", "local/entrypoint.sh"]
      }

      // volumes = [
      //   "local/entrypoint.sh:/root/entrypoint.sh:ro"
      // ]

      template {
        change_mode = "noop"
        destination = "local/entrypoint.sh"
        perms       = "755"
        data        = <<EOH
#!/bin/bash
db_drop=$(mysql -NBe "SELECT * FROM information_schema.tables WHERE table_name = 'drop_this_database';" | awk '{print $2}')
for db in $db_drop; do
    echo "Drop $db"
    mysql -Bse "drop database $db;"
done
sleep 50
EOH
      }

      env {
        MYSQL_HOST     = "192.168.1.104"
        MYSQL_TCP_PORT = "3306"
        USER           = "root"
        MYSQL_PWD      = "331"
      }

      // template {
      //   destination = "secrets/sql.env"
      //   env         = true
      //   data        = <<EOH
      //   {{- with secret "secret/tools/rds-app/default" }}
      //     MYSQL_HOST     = {{.Data.db_host}}
      //     MYSQL_TCP_PORT = {{.Data.db_port}}
      //   {{- end }}
      //   {{- with secret "secret/tools/rds-app/user_platform" }}
      //     USER      = {{.Data.user}}
      //     MYSQL_PWD = {{.Data.password}}
      //   {{- end }}
      //   EOH
      // }
      //   resources {
      //     memory = 2048
      //     cpu    = 1000
      //   }
    }
  }
}