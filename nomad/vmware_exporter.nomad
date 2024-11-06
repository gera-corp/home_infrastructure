job "vmware_exporter" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "monitoring"

  group "vmware_exporter-group" {

    network {
      port "http" {
        to     = 9272
        static = 9272
      }
    }
    service {
      port = "http"
      name = "vmware-exporter"
      tags = [
        "vmware-exporter"
      ]
    }

    task "vmware_exporter" {
      driver = "docker"
      resources {
        cpu    = 500
        memory = 300
      }
      vault {
        policies = ["vmware_exporter"]
        env      = true
      }
      config {
        image = "pryorda/vmware_exporter"
        ports = ["http"]
        //   logging {
        //     type = "fluentd"
        //     config {
        //       fluentd-address = "fluentd-port.service.consul:24224"
        //       tag             = "vmware_exporter"
        //     }
        //   }
      }
      template {
        destination = "secrets/secret.env"
        env         = true
        data        = <<EOH
        {{ with secret "secret/tools/vmware-exporter" }}
          VSPHERE_HOST       = {{ .Data.VSPHERE_HOST | toJSON }}
          VSPHERE_IGNORE_SSL = {{ .Data.VSPHERE_IGNORE_SSL | toJSON }}
          VSPHERE_SPECS_SIZE = {{ .Data.VSPHERE_SPECS_SIZE | toJSON }}
          VSPHERE_USER       = {{ .Data.VSPHERE_USER | toJSON }}
          VSPHERE_PASSWORD   = {{ .Data.VSPHERE_PASSWORD | toJSON }}
        {{ end }}
        EOH
      }
    }
  }
}