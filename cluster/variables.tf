variable "cluster_name" {
  type    = string
  default = "k8s-8gb-cluster"
}

variable "region" {
  type    = string
  default = "blr1"
}

variable "k8s_version" {
  type    = string
  default = "1.33.1-do.3"
}

variable "node_size" {
  type    = string
  default = "s-4vcpu-8gb"
}
