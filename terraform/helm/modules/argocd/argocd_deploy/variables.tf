variable "chart_version" {
  description = "Helm Chart Version of ArgoCD: https://github.com/argoproj/argo-helm/releases"
  type        = string
  default     = "6.2.3"
}

variable "avp_version" {
  type = string
}

variable "avp_image_version_tag" {
  type = string
}

variable "kubeconfig" {
  type = string
}
