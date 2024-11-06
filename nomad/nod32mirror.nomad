job "nod32mirror" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "tools"

  // constraint {
  //   attribute = "${attr.unique.hostname}"
  //   value     = "ubuntu-docker"
  // }

  group "nod32mirror-group" {

    network {
      port "http" {
        to     = 80
        static = 8084
      }
    }

    volume "nod32update" {
      type            = "csi"
      source          = "nod32update"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "nod32mirror" {
      driver = "docker"

      service {
        port = "http"
        name = "nod32mirror"
        tags = [
          "nod32mirror",
          "traefik.enable=true",
          "traefik.http.routers.nod32mirror.rule=Host(`nod32mirror.geracorp.ru`)",
          "traefik.http.routers.nod32mirror.entrypoints=web-secure",
          "traefik.http.routers.nod32mirror.tls.certresolver=main"
        ]
      }
      resources {
        cpu    = 100
        memory = 100
      }
      config {
        dns_servers = [attr.unique.network.ip-address]
        volumes = [
          "local/.htpasswd:/etc/nginx/.htpasswd",
          "local/default.conf:/etc/nginx/conf.d/default.conf"
        ]
        image   = "gerain/nod32update-mirror:latest"
        ports   = ["http"]
        command = "sh"
        args = ["-c", <<EOH
"nginx" "-g" "daemon off;" &
while true; do php update.php; sleep 3h; done
        EOH
        ]
      }
      volume_mount {
        volume      = "nod32update"
        destination = "/nod32update/www"
        read_only   = false
      }
      template {
        change_mode   = "signal"
        change_signal = "SIGHUP"
        perms         = "755"
        destination   = "/local/default.conf"
        data          = <<EOH
map $http_user_agent $ver {
        "~^.*(EEA|EES|EFSW|EMSX|ESFW)+\s+Update.*BPC\s+(\d+)\..*$" "ep$2";
        "~^.*Update.*BPC\s+(\d+)\..*$" "v$1";
}

server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root   /nod32update/www;

        # Add index.php to the list if you are using PHP
        index index.html index.htm;

        server_name _;
        real_ip_header X-Real-IP;
        real_ip_recursive on;

        location ~* \.ver$ {
                if ($ver ~ "^ep[6-9]$") {
                        rewrite ^/(dll/)?update.ver$ /eset_upd/$ver/$1update.ver break;
                }
                if ($ver ~ "^ep1[0-9]$") {
                        rewrite ^/(dll/)?update.ver$ /eset_upd/$ver/$1update.ver break;
                }
                if ($ver ~ "^v(5|9)$") {
                        rewrite ^(.*) /eset_upd/$ver/update.ver break;
                }
                if ($ver ~ "^v[3-8]$") {
                        rewrite ^(.*) /eset_upd/v3/update.ver break;
                }
                if ($ver ~ "^v1[0-1]$") {
                        rewrite ^(.*) /eset_upd/v10/dll/update.ver break;
                }
                if ($ver ~ "^v1[2-9]$") {
                        rewrite ^(.*) /eset_upd/$ver/dll/update.ver break;
                }
                auth_basic "Restricted Content";
                auth_basic_user_file /etc/nginx/.htpasswd;
        }
        access_log  /var/log/nginx/host.access.log  main;
        error_log /var/log/nginx/host.error.log;
}
EOH
      }
      template {
        change_mode   = "signal"
        change_signal = "SIGHUP"
        perms         = "755"
        destination   = "/local/.htpasswd"
        data          = <<EOH
gera:$apr1_-/
EOH
      }
    }
  }
}
