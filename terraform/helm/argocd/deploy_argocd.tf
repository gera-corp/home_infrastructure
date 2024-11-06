locals {
  kubeconfig = "~/.kube/home-config"
}

module "argocd_home_cluster" {
  source                = "../modules/argocd/argocd_deploy"
  chart_version         = "7.7.0"
  avp_version           = "1.18.1" #https://github.com/argoproj-labs/argocd-vault-plugin/releases
  avp_image_version_tag = "v2.13.0"
  kubeconfig            = local.kubeconfig
}

module "argocd_config" {
  source                    = "../modules/argocd/argocd_config"
  git_source_repoURL        = "git@github.com:gera-corp/argocd.git"
  git_source_targetRevision = "HEAD"
  git_source_path           = "home_cluster"
  kubeconfig                = local.kubeconfig
}
