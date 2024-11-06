resource "helm_release" "gitlab" {
  name             = "gitlab-runner"
  repository       = "https://charts.gitlab.io" # Official Chart Repo
  chart            = "gitlab-runner"            # Official Chart Name
  namespace        = "gitlab-system"
  version          = var.chart_version
  create_namespace = true
  values = [
    templatefile("${path.module}/gitlab_runner.yaml", {
      runner_token = var.runner_token
    })
  ]
}
