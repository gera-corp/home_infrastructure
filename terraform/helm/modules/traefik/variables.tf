variable "chart_version" {
  type = string
}
variable "kubeconfig" {
  type    = string
  default = "~/.kube/home-config"
}
