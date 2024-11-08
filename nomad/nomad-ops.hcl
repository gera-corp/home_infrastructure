job "nomad-ops" {
  namespace   = "nomad-ops"
  datacenters = ["dc1"]
  type        = "service"

  # Specify this job to have rolling updates, two-at-a-time, with
  # 30 second intervals.
  update {
    stagger      = "30s"
    max_parallel = 1
  }

  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  group "nomad-ops-group" {
    # Only 1
    count = 1

    network {
      mode = "host"
      port "http" {
        to     = 8080
        static = 8085
      }
    }

    service {
      name = "nomad-ops"
      tags = ["http", "view", "traefik.enable=true"]

      port = "http"

      # comment to use consul
      provider = "nomad"

      check {
        type     = "http"
        path     = "/api/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    volume "nomad-ops" {
      type            = "csi"
      source          = "nomad-ops"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    # Create an individual task (unit of work). This particular
    # task utilizes a Docker container to front a web application.
    task "operator" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      driver = "docker"

      # available with nomad >=v1.5.0
      # use manually supplied NOMAD_TOKEN before that
      identity {
        # Expose Workload Identity in NOMAD_TOKEN env var
        env = true
        # Expose Workload Identity in ${NOMAD_SECRETS_DIR}/nomad_token file
        #file = true
      }

      env {
        NOMAD_TOKEN              = "-_-"
        NOMAD_OPS_LOCAL_REPO_DIR = "/data/repos"
        # Adjust accordingly
        NOMAD_ADDR = "http://nomad.service.consul:4646"
        # comment and provide a NOMAD_TOKEN instead
        # NOMAD_TOKEN_FILE = "${NOMAD_SECRETS_DIR}/nomad_token"
        TRACE = "FALSE"
      }

      # Configuration is specific to each driver.
      config {
        image = "ghcr.io/nomad-ops/nomad-ops:v0.6.0"
        args = [
          "serve",
          "--http", "0.0.0.0:${NOMAD_PORT_http}",
          "--dir", "/data/pb_data"
        ]

        ports = [
          "http",
        ]

        dns_servers = [attr.unique.network.ip-address]

        // mounts = [
        //   {
        //     type   = "volume"
        //     target = "/data"
        //     source = "nomad-ops-data"
        //   }
        // ]
      }

      volume_mount {
        volume      = "nomad-ops"
        destination = "/data"
        read_only   = false
      }

      # Specify the maximum resources required to run the task,
      # include CPU, memory, and bandwidth.
      resources {
        cpu    = 200 # MHz
        memory = 500 # MB
      }
    }
  }
}
