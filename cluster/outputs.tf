output "kubeconfig" {
  description = "Kubeconfig for the cluster"
  value       = digitalocean_kubernetes_cluster.this.kube_config[0].raw_config
  sensitive   = true
}
