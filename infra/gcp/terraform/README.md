# Terraform Deployment Guide

Deploy the Todo App to Google Cloud Run using Terraform Infrastructure as Code.

## Prerequisites

1. **Terraform** installed (v1.0+)
2. **Google Cloud SDK** installed and configured
3. **GCP Project** with billing enabled
4. **Service Account** with appropriate permissions

## Setup

### 1. Initialize Terraform

```bash
cd infra/gcp/terraform
terraform init
```

### 2. Create terraform.tfvars

Copy the example file and fill in your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your configuration:

```hcl
gcp_project_id = "your-project-id"
gcp_region     = "us-central1"

database_url          = "postgresql://..."
database_url_unpooled = "postgresql://..."

auth_secret        = "your-secret"
better_auth_secret = "your-secret"
```

### 3. Validate Configuration

```bash
terraform validate
```

### 4. Plan Deployment

```bash
terraform plan -out=tfplan
```

Review the planned changes carefully.

### 5. Apply Configuration

```bash
terraform apply tfplan
```

## Outputs

After successful deployment, Terraform will output:

- `backend_url` - Backend Cloud Run service URL
- `frontend_url` - Frontend Cloud Run service URL
- `artifact_registry_url` - Artifact Registry repository URL

## Managing State

### Local State (Development)

State is stored locally in `terraform.tfstate`. Keep this file safe.

### Remote State (Production)

For production, use Cloud Storage for remote state:

```bash
# Create a GCS bucket for state
gsutil mb gs://your-terraform-state-bucket

# Configure backend in main.tf
terraform init -backend-config="bucket=your-terraform-state-bucket"
```

## Common Operations

### Update Environment Variables

```bash
# Modify terraform.tfvars
terraform plan
terraform apply
```

### Scale Resources

```bash
# Update memory/CPU in terraform.tfvars
terraform apply
```

### Destroy Resources

```bash
terraform destroy
```

## Troubleshooting

### API Not Enabled

```bash
gcloud services enable run.googleapis.com artifactregistry.googleapis.com
```

### Permission Denied

Ensure your service account has:
- `roles/run.admin`
- `roles/artifactregistry.admin`
- `roles/iam.serviceAccountUser`

### State Lock Issues

```bash
terraform force-unlock LOCK_ID
```

## Best Practices

1. **Use Remote State** - Store state in Cloud Storage for team collaboration
2. **Version Control** - Commit `terraform.tfvars.example` but not `terraform.tfvars`
3. **Plan Before Apply** - Always review `terraform plan` output
4. **Use Workspaces** - Separate dev/staging/prod environments
5. **Enable State Locking** - Prevent concurrent modifications

## Advanced Configuration

### Multiple Environments

```bash
# Create workspaces
terraform workspace new dev
terraform workspace new prod

# Switch between workspaces
terraform workspace select dev
terraform apply
```

### Custom Domain

Add to `main.tf`:

```hcl
resource "google_cloud_run_domain_mapping" "frontend" {
  location = var.gcp_region
  name     = "yourdomain.com"
  spec {
    route_name = google_cloud_run_service.frontend.name
  }
}
```

### Cloud CDN

Add to `main.tf`:

```hcl
resource "google_compute_backend_service" "frontend_cdn" {
  name            = "frontend-cdn"
  protocol        = "HTTPS"
  enable_cdn      = true
  
  backend {
    group = google_cloud_run_service.frontend.id
  }
}
```

## Support

For issues or questions:
1. Check Terraform logs: `TF_LOG=DEBUG terraform apply`
2. Review GCP Cloud Run documentation
3. Check service logs: `gcloud run logs read SERVICE_NAME`
