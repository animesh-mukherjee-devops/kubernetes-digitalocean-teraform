# Kubernetes DigitalOcean Terraform Automation

[![Terraform](https://img.shields.io/badge/Terraform-v1.0+-7B42BC?logo=terraform)](https://www.terraform.io/)
[![DigitalOcean](https://img.shields.io/badge/DigitalOcean-Kubernetes-0080FF?logo=digitalocean)](https://www.digitalocean.com/products/kubernetes)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-Automated-2088FF?logo=github-actions)](https://github.com/features/actions)

## 🚀 Overview

This project provides a fully automated GitOps solution for provisioning and managing Kubernetes clusters on DigitalOcean using Terraform and GitHub Actions. The infrastructure state is managed entirely within GitHub, eliminating the need for external state backends.

### ✨ Key Features

- **Zero Local Setup**: All operations run through GitHub Actions
- **Automated Provisioning**: Push-to-deploy cluster creation
- **State Management**: Terraform state stored securely in GitHub Secrets
- **Safety First**: Manual destruction workflow prevents accidental deletions
- **Cost Effective**: Perfect for development and small production workloads

## 📋 Prerequisites

Before you begin, ensure you have:

- [ ] A DigitalOcean account with billing enabled
- [ ] A GitHub repository (fork or clone this repo)
- [ ] Admin access to configure GitHub Secrets
- [ ] Basic understanding of Kubernetes and Terraform

## 🔧 Setup Instructions

### Step 1: DigitalOcean API Token

1. Log in to your [DigitalOcean Control Panel](https://cloud.digitalocean.com/)
2. Navigate to **API** → **Tokens/Keys**
3. Click **Generate New Token**
4. Give it a name (e.g., `terraform-k8s-automation`)
5. Select **Read & Write** scopes
6. Copy the generated token immediately (it won't be shown again)

### Step 2: GitHub Personal Access Token (PAT)

1. Go to GitHub → Settings → [Developer Settings](https://github.com/settings/tokens)
2. Click **Personal access tokens** → **Fine-grained tokens**
3. Click **Generate new token**
4. Configure the token:
   - **Name**: `terraform-state-manager`
   - **Expiration**: Set as needed (recommend 90 days)
   - **Repository access**: Select this specific repository
   - **Permissions**:
     - Actions: Read and Write
     - Secrets: Read and Write
5. Generate and copy the token

### Step 3: Configure GitHub Secrets

In your repository, go to **Settings** → **Secrets and variables** → **Actions**:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `DO_TOKEN` | Your DigitalOcean API token | Used to manage DO resources |
| `GH_PAT` | Your GitHub PAT | Used to update secrets with state |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     GitHub Repository                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  cluster/                                                │
│  └── main.tf          # Terraform configuration         │
│                                                          │
│  .github/workflows/                                     │
│  ├── terraform-apply.yml    # Create cluster            │
│  └── terraform-destroy.yml  # Destroy cluster           │
│                                                          │
│  GitHub Secrets:                                        │
│  ├── DO_TOKEN         # DigitalOcean API access         │
│  ├── GH_PAT           # GitHub API access               │
│  └── TF_STATE         # Terraform state (auto-managed)  │
│                                                          │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
                  ┌─────────────────┐
                  │   DigitalOcean   │
                  │   Kubernetes     │
                  │     Cluster      │
                  └─────────────────┘
```

## 📦 Project Structure

```
.
├── cluster/
│   └── main.tf                 # Terraform configuration
├── .github/
│   └── workflows/
│       ├── terraform-apply.yml # Automated cluster creation
│       └── terraform-destroy.yml # Manual cluster destruction
└── README.md
```

### Terraform Configuration (`cluster/main.tf`)

The main Terraform file defines:
- DigitalOcean provider configuration
- Kubernetes cluster specification
- Node pool configuration
- Auto-scaling settings
- Output values (kubeconfig, endpoint, etc.)

## 🚦 Usage

### Creating a Kubernetes Cluster

1. **Automatic Deployment**: 
   - Simply push changes to the `main` branch
   - GitHub Actions will automatically provision your cluster
   - Check the Actions tab for progress and logs

2. **Manual Trigger** (if configured):
   ```bash
   git push origin main
   ```

### Accessing Your Cluster

After successful deployment, retrieve your kubeconfig:

1. Check the workflow run output for cluster details
2. Use DigitalOcean CLI:
   ```bash
   doctl kubernetes cluster kubeconfig save <cluster-name>
   ```

3. Verify connection:
   ```bash
   kubectl get nodes
   ```

### Destroying the Cluster

⚠️ **Warning**: This will permanently delete your cluster and all resources within it.

1. Go to **Actions** tab in your repository
2. Select **Terraform Destroy** workflow
3. Click **Run workflow**
4. Select the branch and confirm
5. Monitor the destruction process

## 🔄 Workflow Details

### Apply Workflow (`terraform-apply.yml`)

**Trigger**: Push to `main` branch

**Steps**:
1. Checkout repository code
2. Setup Terraform
3. Initialize Terraform backend
4. Plan infrastructure changes
5. Apply configuration
6. Save state to `TF_STATE` secret
7. Output cluster information

### Destroy Workflow (`terraform-destroy.yml`)

**Trigger**: Manual (`workflow_dispatch`)

**Steps**:
1. Checkout repository code
2. Restore state from `TF_STATE` secret
3. Initialize Terraform
4. Plan destruction
5. Destroy all resources
6. Clear `TF_STATE` secret

## ⚙️ Configuration Options

### Cluster Customization

Edit `cluster/main.tf` to customize:

```hcl
resource "digitalocean_kubernetes_cluster" "primary" {
  name    = "k8s-terraform-demo"
  region  = "nyc3"              # Change region
  version = "1.28.2-do.0"       # Kubernetes version
  
  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-4gb"   # Node size
    auto_scale = true
    min_nodes  = 2
    max_nodes  = 5
  }
}
```

### Available Regions

- `nyc1`, `nyc3` - New York
- `sfo2`, `sfo3` - San Francisco
- `ams3` - Amsterdam
- `sgp1` - Singapore
- `lon1` - London
- `fra1` - Frankfurt
- `tor1` - Toronto
- `blr1` - Bangalore

### Node Sizes (Examples)

| Size | vCPUs | Memory | Price/mo |
|------|-------|--------|----------|
| s-1vcpu-2gb | 1 | 2GB | ~$12 |
| s-2vcpu-4gb | 2 | 4GB | ~$24 |
| s-4vcpu-8gb | 4 | 8GB | ~$48 |
| s-8vcpu-16gb | 8 | 16GB | ~$96 |

## 🛡️ Security Best Practices

1. **Token Rotation**: Regularly rotate your API tokens
2. **Least Privilege**: Use minimal required permissions
3. **Secret Scanning**: Enable GitHub secret scanning
4. **Branch Protection**: Protect your main branch
5. **Audit Logs**: Monitor GitHub Actions logs regularly
6. **Network Policies**: Implement Kubernetes network policies post-deployment

## ⚠️ Limitations & Considerations

### GitHub Secrets Limitation
- **Size Limit**: 64KB maximum per secret
- **Suitable for**: Small to medium clusters
- **Not suitable for**: Large infrastructures with complex state

### Alternative State Backends

For production or larger deployments, consider:

1. **Terraform Cloud**
   ```hcl
   terraform {
     backend "remote" {
       organization = "your-org"
       workspaces {
         name = "k8s-digitalocean"
       }
     }
   }
   ```

2. **S3-Compatible (DigitalOcean Spaces)**
   ```hcl
   terraform {
     backend "s3" {
       endpoint = "nyc3.digitaloceanspaces.com"
       region = "us-east-1"
       key = "terraform.tfstate"
       bucket = "your-bucket"
       skip_credentials_validation = true
       skip_metadata_api_check = true
     }
   }
   ```

## 💰 Cost Estimation

Basic cluster costs (approximate):

| Component | Cost/month |
|-----------|------------|
| Control Plane | Free (managed) |
| 2x s-2vcpu-4gb nodes | ~$48 |
| Load Balancer (if used) | ~$12 |
| **Total** | **~$60** |

*Prices vary by region and are subject to change*

## 🐛 Troubleshooting

### Common Issues

**1. Authentication Failed**
- Verify your `DO_TOKEN` is correct and has read/write permissions
- Check token hasn't expired

**2. State Lock Error**
- Ensure no concurrent workflows are running
- Check Actions tab for stuck workflows

**3. Cluster Creation Timeout**
- DigitalOcean may have capacity issues in your selected region
- Try a different region

**4. Secret Update Failed**
- Verify `GH_PAT` has correct permissions
- Check token expiration date

### Debug Mode

Enable debug logging in workflows:
```yaml
env:
  TF_LOG: DEBUG
```

## 📚 Additional Resources

- [DigitalOcean Kubernetes Documentation](https://docs.digitalocean.com/products/kubernetes/)
- [Terraform DigitalOcean Provider](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Kubernetes Official Documentation](https://kubernetes.io/docs/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👤 Author

**Animesh Mukherjee**
- GitHub: [@animesh-mukherjee-devops](https://github.com/animesh-mukherjee-devops)

## 🙏 Acknowledgments

- DigitalOcean for their excellent Kubernetes service
- HashiCorp for Terraform
- GitHub for Actions and secret management capabilities

---

⭐ If you find this project helpful, please consider giving it a star on GitHub!