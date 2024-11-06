variable "chart_version" {
  type = string
}
variable "kubeconfig" {
  type    = string
  default = "~/.kube/k8s-cash-stage"
}
