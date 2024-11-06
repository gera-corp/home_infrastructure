job "nginx-for-test" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "default"

  //   constraint {
  //     attribute = "${attr.unique.hostname}"
  //     value     = "nmcs-dns-test"
  //   }

  group "nginx-group" {

    network {
      port "http" {
        to = 80
      }
      //   port "db-port" {
      //     to = 3306
      //     // static = 3306
      //   }
    }

    // service {
    //   port = "db-port"
    //   name = "db-port"
    // }
    service {
      port = "http"
      name = "nginx"
      tags = [
        "nginx-test",
        "urlprefix-/",
        "traefik.enable=true",
        "traefik.http.routers.nginx-test.rule=Host(`nginx-test.geracorp.ru`)",
        "traefik.http.routers.nginx-test.entrypoints=web-secure",
        "traefik.http.routers.nginx-test.tls.certresolver=main"
      ]
    }

    // volume "grafana" {
    //   type = "csi"
    //   source = "grafana-test"
    //   access_mode = "single-node-writer"
    //   attachment_mode = "file-system"
    // }

    task "nginx-task" {
      driver = "docker"

      resources {
        cpu    = 100
        memory = 100
      }
      config {
        image       = "nginx:stable"
        ports       = ["http"]
        dns_servers = [attr.unique.network.ip-address]
      }

      // env {
      //   PORT = "${NOMAD_PORT_http}"
      // }

      //       template {
      //         data        = <<EOF
      // {{- range service "db-port" }}
      // server {{ .Address }}:{{ .Port }}{{- end }}
      // test
      // {{- range $tag, $services := service "miniblog" | byTag -}}
      // {{ if eq $tag "miniblog" }}
      // {{ range $services -}}
      // test {
      // server {{.Address}}:{{.Port}}
      // }
      // {{ end -}}
      // {{ end }}
      // {{- end -}}
      // test

      // EOF
      //         destination = "local/nginx.conf"
      //       }
    }

    // task "mysql-test-task" {
    //   driver = "podman"

    //   resources {
    //     cpu    = 100
    //     memory = 512
    //   }
    //   config {
    //     image = "docker://mysql:debian"
    //     ports = ["db-port"]
    //     // memory_swap = "180m"
    //     // entrypoint = ["sleep", "3h"]
    //   }
    //   env {
    //     MYSQL_ROOT_PASSWORD = "331"
    //   }
    // }
  }
}