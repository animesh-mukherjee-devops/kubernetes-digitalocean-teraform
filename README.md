# 🚀 Kubernetes on DigitalOcean with Terraform + GitHub Actions

This project automates the creation and destruction of a **Kubernetes cluster on DigitalOcean** using **Terraform** and **GitHub Actions**.  
Terraform state is stored in **GitHub Secrets**, so everything can be managed directly through GitHub workflows.

---

## ✅ Prerequisites

1. **DigitalOcean API Token**  
   - Create from DigitalOcean → API → Tokens (with Read & Write access).  
   - Save it in repo secrets as `DO_TOKEN`.  

2. **GitHub Personal Access Token (PAT)**  
   - Needed so workflows can update repo secrets.  
   - Create a fine-grained PAT with **Actions (Read/Write)** and **Secrets (Read/Write)**.  
   - Save it in repo secrets as `GH_PAT`.  

---

## 📂 Project Structure

- **`cluster/main.tf`**  
  Defines the DigitalOcean Kubernetes cluster (region, version, node pool, scaling, outputs).  

- **`.github/workflows/terraform-apply.yml`**  
  Runs on pushes to `main`.  
  - Initializes Terraform.  
  - Applies the configuration (creates the cluster).  
  - Saves the generated `terraform.tfstate` into a GitHub Secret (`TF_STATE`).  

- **`.github/workflows/terraform-destroy.yml`**  
  Runs manually (`workflow_dispatch`).  
  - Restores the `.tfstate` from the secret.  
  - Runs `terraform destroy` (deletes the cluster).  
  - Clears the stored `TF_STATE` secret.  

---

## 🚀 Usage Flow

Developer Pushes Code
│
▼
┌─────────────────────────┐
│ Terraform Apply Workflow │
│ - terraform init │
│ - terraform apply │
│ - Save tfstate → Secret │
└─────────────────────────┘
│
▼
DigitalOcean Cluster Created
│
▼
[ Work with your cluster ]
│
▼
┌──────────────────────────┐
│ Terraform Destroy Manual │
│ - Restore tfstate │
│ - terraform destroy │
│ - Delete tfstate secret │
└──────────────────────────┘
│
▼


---

## ⚠️ Notes

- GitHub Secrets have a **64 KB size limit**. Works fine for small clusters, but for larger infrastructures use a remote backend (Terraform Cloud, S3, GCS).  
- The `destroy` workflow is **manual** to avoid accidental cluster deletion.  
- The `GH_PAT` token is required since the default `GITHUB_TOKEN` cannot modify secrets.  

---

## ✅ Summary

- **Push to `main` → Cluster created automatically**.  
- **Manual Destroy → Cluster deleted + state cleared**.  
- All infra is managed in GitHub Actions → no local Terraform needed.  
