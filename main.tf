terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34.1"
    }
  }
  required_version = ">= 1.3.0"
}

provider "digitalocean" {
  # Authentication is done via DO_API_TOKEN env variable
  # export DO_TOKEN="your_api_token"
  token = var.do_token
}

variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

resource "digitalocean_kubernetes_cluster" "my_cluster" {
  name    = "k8s-8gb-cluster"
  region  = "blr1"
  version = "1.33.1-do.3" # Recommended version

  # VPC - default is used automatically
  vpc_uuid = null

  # Default Node Pool
  node_pool {
    name       = "worker-pool"
    size       = "s-4vcpu-8gb" 
    #node_count = 1
    # Uncomment below if you want autoscaling
    auto_scale  = true
    min_nodes   = 1
    max_nodes   = 3
  }

  # Control Plane HA (skip for now to save cost)
  # ha = true
}

output "kubeconfig" {
  description = "Kubeconfig file for accessing the cluster"
  value       = digitalocean_kubernetes_cluster.my_cluster.kube_config[0].raw_config
  sensitive   = true
}
