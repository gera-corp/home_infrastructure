locals {
  kubeconfig = "~/.kube/home-config"
}

module "gitlab-operator" {
  source        = "./modules/gitlab-operator"
  chart_version = "1.1.1" #https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/releases
  kubeconfig    = local.kubeconfig
}

module "gitlab" {
  source       = "./modules/gitlab"
  chartVersion = "8.1.1" #https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/CHANGELOG.md
  kubeconfig   = local.kubeconfig
}

module "gitlab-runners" {
  source        = "./modules/gitlab-runners"
  chart_version = "0.66.0" #https://gitlab.com/gitlab-org/charts/gitlab-runner/-/blob/main/CHANGELOG.md
  kubeconfig    = local.kubeconfig
  runner_token  = "glrt-sKLQU6sJaU66XJsBQrzP"
}
