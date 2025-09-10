resource "digitalocean_kubernetes_cluster" "this" {
  name    = var.cluster_name
  region  = var.region
  version = var.k8s_version

  node_pool {
    name       = "worker-pool"
    size       = var.node_size
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
  }
}
