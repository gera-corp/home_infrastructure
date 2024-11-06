variable "image_version" {
  type    = string
  default = "jenkins/jenkins:2.414.3-lts"
}
job "jenkins" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "tools"

  // constraint {
  //   attribute = "${attr.unique.hostname}"
  //   value     = "nomad-worker-02"
  // }

  group "jenkins-group" {
    count = 1

    volume "jenkins-data" {
      type            = "csi"
      source          = "jenkins-data"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    network {
      port "http" {
        to     = 8080
        static = 8099
      }
      port "jnlp" {
        to = 50000
      }
    }

    service {
      name = "jenkins-http"
      port = "http"
      check {
        type     = "http"
        path     = "/login"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "install-plugins" {
      driver = "docker"
      volume_mount {
        volume      = "jenkins-data"
        destination = "/var/jenkins_home"
        read_only   = false
      }
      config {
        image       = "${var.image_version}"
        dns_servers = [attr.unique.network.ip-address]
        command     = "jenkins-plugin-cli"
        args = [
          "--plugins",
          "dark-theme",
          "ansicolor",
          "pipeline-stage-view",
          "timestamper",
          "blueocean",
          "configuration-as-code",
          "git",
          "github",
          "hashicorp-vault-plugin",
          "job-dsl",
          "nomad",
          "uno-choice",
          "--plugin-download-directory",
          "/var/jenkins_home/plugins/"
        ]
      }
      resources {
        cpu    = 500
        memory = 1024
      }
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
    }

    task "jenkins" {
      driver = "docker"
      volume_mount {
        volume      = "jenkins-data"
        destination = "/var/jenkins_home"
        read_only   = false
      }
      resources {
        cpu    = 1000
        memory = 2048
      }
      config {
        image       = "${var.image_version}"
        ports       = ["http", "jnlp"]
        dns_servers = [attr.unique.network.ip-address]
        volumes = [
          "local/config/jenkins.yaml:/var/jenkins_home/jenkins.yaml"
        ]
      }
      env {
        JAVA_OPTS = "-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"
      }
      vault {
        policies      = ["jenkins", "nomad-policy-jenkins-workers"]
        change_mode   = "signal"
        change_signal = "SIGINT"
      }
      template {
        destination = "local/config/jenkins.yaml"
        change_mode = "noop"
        data        = <<EOH
jenkins:
  agentProtocols:
  - "JNLP4-connect"
  - "Ping"
  clouds:
  - nomad:
      name: "nomad"
      nomadUrl: "https://nomad.geracorp.ru"
      tlsEnabled: true
      nomadACLCredentialsId: "nomad-token-jenkins-workers"
      prune: true
      workerTimeout: 1
      templates:
      - labels: "jenkins-nomad-worker"
        idleTerminationInMinutes: 1
        jobTemplate: |-
          {
            "Job": {
              "Region": "global",
              "Namespace": "tools",
              "ID": "%WORKER_NAME%",
              "Type": "batch",
              "Datacenters": [
                "dc1"
              ],
              "TaskGroups": [
                {
                  "Name": "jenkins-worker-taskgroup",
                  "Count": 1,
                  "RestartPolicy": {
                    "Attempts": 0,
                    "Interval": 10000000000,
                    "Mode": "fail",
                    "Delay": 10000000000
                  },
                  "Tasks": [
                    {
                      "Name": "jenkins-worker",
                      "Driver": "docker",
                      "Config": {
                        "image": "docker-registry.geracorp.ru/tools/jenkins-agent:v1.0.1",
                        "image_pull_timeout": "15m",
                        "dns_servers": ["{{ env "attr.unique.network.ip-address" }}"],
                        "ports": ["jenkins-worker-port"]
                      },
                      "Vault": {
                        "Policies": [
                          "jenkins-workers"
                        ]
                      },
                      "Env": {
                        "JENKINS_URL": "http://{{ env "NOMAD_ADDR_http" }}",
                        "JENKINS_AGENT_NAME": "%WORKER_NAME%",
                        "JENKINS_SECRET": "%WORKER_SECRET%",
                        "JENKINS_TUNNEL": "{{ env "NOMAD_ADDR_jnlp" }}",
                        "NOMAD_ADDR": "https://{{ env "attr.unique.network.ip-address" }}:4646"
                      },
                      "Resources": {
                        "CPU": 500,
                        "MemoryMB": 512
                      }
                    }
                  ],
                  "EphemeralDisk": {
                    "SizeMB": 300
                  },
                  "Networks": [
                    {
                      "DynamicPorts": [
                        {
                          "Label": "jenkins-worker-port",
                          "Value": 0,
                          "To": 8336,
                          "HostNetwork": "default"
                        }
                      ]
                    }
                  ],
                  "Services": [
                    {
                      "Name": "jenkins-worker-port",
                      "PortLabel": "jenkins-worker-port",
                      "Provider": "consul"
                    }
                  ]
                }
              ]
            }
          }
        numExecutors: 1
        prefix: "jenkins-worker"
        reusable: true
  numExecutors: 2
  remotingSecurity:
    enabled: true
  labelString: "master"
jobs:
  - script: >
      job('seedjob') {
        label('master')
        logRotator(-1, 10)
        scm {
            git {
              branch('master')
              remote {
                github('gera-corp/jenkins', 'ssh', 'github.com')
                credentials('github_jenkins_deploy_key')
              }
            }
        }
        triggers {
            githubPush()
        }
        steps {
          dsl {
            external('jobDSL/seedJob.groovy')
          }
        }
      }
unclassified:
  themeManager:
    disableUserThemes: true
    theme: "darkSystem"
  hashicorpVault:
    configuration:
      vaultCredentialId: "vaultToken"
      vaultUrl: "http://vault.service.consul:8200"
  location:
    url: "http://jenkins-http.service.consul:${NOMAD_HOST_PORT_http}"
credentials:
  system:
    domainCredentials:
      - credentials:
          - vaultTokenCredential:
              description: "Vault Token"
              id: "vaultToken"
              scope: GLOBAL
              token: "{{ env "VAULT_TOKEN" }}"
          - vaultUsernamePasswordCredentialImpl:
              engineVersion: 1
              id: "jenkins-github-integration"
              passwordKey: "password"
              path: "secret/tools/jenkins/credentials/jenkins-github-integration"
              scope: GLOBAL
              usernameKey: "username"
          - vaultStringCredentialImpl:
              engineVersion: 1
              id: "nomad-token-jenkins-workers"
              path: "nomad/creds/jenkins-workers"
              scope: GLOBAL
              vaultKey: "secret_id"
          - vaultSSHUserPrivateKeyImpl:
              engineVersion: 1
              id: "github_jenkins_deploy_key"
              passphraseKey: "passphrase"
              path: "secret/tools/jenkins/credentials/github_jenkins"
              privateKeyKey: "private_key"
              scope: GLOBAL
              usernameKey: "username"
          - vaultSSHUserPrivateKeyImpl:
              engineVersion: 1
              id: "github_packer_proxmox_deploy_key"
              passphraseKey: "passphrase"
              path: "secret/tools/jenkins/credentials/github_packer_proxmox"
              privateKeyKey: "private_key"
              scope: GLOBAL
              usernameKey: "username"
          - vaultStringCredentialImpl:
              engineVersion: 1
              id: "proxmox_api_user"
              path: "secret/tools/jenkins/credentials/proxmox_credentials"
              scope: GLOBAL
              vaultKey: "proxmox_api_user"
          - vaultStringCredentialImpl:
              engineVersion: 1
              id: "proxmox_api_password"
              path: "secret/tools/jenkins/credentials/proxmox_credentials"
              scope: GLOBAL
              vaultKey: "proxmox_api_password"
security:
  gitHostKeyVerificationConfiguration:
    sshHostKeyVerificationStrategy: "noHostKeyVerificationStrategy"
EOH
      }
    }
  }
}
