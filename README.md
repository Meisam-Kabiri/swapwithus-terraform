# SwapWithUs Terraform Infrastructure

This directory contains Terraform configuration for managing SwapWithUs GCP infrastructure.

## Overview

This Terraform configuration manages:
- Cloud Run service (swapwithus-backend)
- Cloud SQL PostgreSQL instance
- Cloud Storage bucket (listing images)
- Secret Manager secrets
- Service accounts and IAM bindings
- Load balancer and CDN 

## Prerequisites

1. **Install Terraform**
   ```bash
   # macOS
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform

   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
   unzip terraform_1.6.6_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

2. **Authenticate with GCP**
   ```bash
   gcloud auth application-default login
   gcloud config set project swapwithus-project
   ```

3. **Enable Required APIs**
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable run.googleapis.com
   gcloud services enable sqladmin.googleapis.com
   gcloud services enable secretmanager.googleapis.com
   gcloud services enable storage.googleapis.com
   gcloud services enable iam.googleapis.com
   ```

## Initial Setup - Import Existing Resources

Since you already have infrastructure deployed, you need to import it into Terraform state:

### Step 1: Initialize Terraform

```bash
cd terraform
terraform init
```

### Step 2: Run the Import Script

```bash
./import.sh
```

This script will import all existing GCP resources into Terraform state. It may show some errors for resources that don't exist or have different naming - that's normal.

### Step 3: Verify the Import

```bash
terraform plan
```

Review the output carefully. Terraform will show:
- **Green (+)**: Resources that will be created
- **Red (-)**: Resources that will be destroyed
- **Yellow (~)**: Resources that will be modified
- **No changes**: Resources that match exactly

**IMPORTANT**: If you see resources being destroyed or modified unexpectedly, STOP and review the configuration.

### Step 4: Adjust Configuration (if needed)

You may need to update the Terraform configuration to match your actual infrastructure:

1. Check your actual Cloud SQL tier:
   ```bash
   gcloud sql instances describe swapwithus-db --format="value(settings.tier)"
   ```
   Update `sql_tier` in `terraform.tfvars` if different.

2. Check actual resource configurations and update the `.tf` files accordingly.

### Step 5: Apply Changes (when ready)

Only after reviewing `terraform plan` output:

```bash
terraform apply
```

## File Structure

```
terraform/
├── versions.tf          # Terraform and provider versions
├── provider.tf          # GCP provider configuration
├── variables.tf         # Variable definitions
├── terraform.tfvars     # Variable values (DO NOT COMMIT)
├── iam.tf              # Service accounts and IAM bindings
├── storage.tf          # Cloud Storage buckets
├── cloud-sql.tf        # Cloud SQL PostgreSQL
├── secrets.tf          # Secret Manager secrets
├── cloud-run.tf        # Cloud Run service
├── outputs.tf          # Output values
├── import.sh           # Import script for existing resources
└── README.md           # This file
```

## Common Operations

### View Current Infrastructure

```bash
terraform show
```

### Update Infrastructure

1. Modify the relevant `.tf` file
2. Review changes:
   ```bash
   terraform plan
   ```
3. Apply changes:
   ```bash
   terraform apply
   ```

### Update Cloud Run Environment Variables

Edit `cloud-run.tf` and modify the `env` blocks, then:

```bash
terraform apply
```

### Update Secrets

Secrets are managed by Terraform structure only, not values. To update secret values:

```bash
echo -n "new_value" | gcloud secrets versions add SECRET_NAME --data-file=-
```

Terraform will detect the new version automatically.

### Destroy Resources (DANGEROUS)

```bash
terraform destroy
```

**WARNING**: This will destroy ALL infrastructure managed by Terraform!

## Managing Cloud Run Deployments

Terraform manages the Cloud Run service configuration, but you can still deploy new container images using:

```bash
# Build new image
gcloud builds submit --tag gcr.io/swapwithus-project/swapwithus-backend

# Update Cloud Run with new image
terraform apply -var="container_image=gcr.io/swapwithus-project/swapwithus-backend:latest"
```

Or continue using your existing deployment script for quick updates.

## State Management

### Local State (Current Setup)

Terraform state is currently stored locally in `terraform.tfstate`.

**IMPORTANT**:
- Never commit `terraform.tfstate` to git
- Back up this file regularly
- Don't delete this file - it tracks your infrastructure

### Remote State (Recommended for Teams)

For production and team collaboration, use GCS backend:

1. Create a state bucket:
   ```bash
   gsutil mb -p swapwithus-project -l europe-north1 gs://swapwithus-terraform-state
   gsutil versioning set on gs://swapwithus-terraform-state
   ```

2. Uncomment the backend block in `versions.tf`:
   ```hcl
   backend "gcs" {
     bucket = "swapwithus-terraform-state"
     prefix = "terraform/state"
   }
   ```

3. Migrate state:
   ```bash
   terraform init -migrate-state
   ```

## Best Practices

1. **Always run `terraform plan` before `apply`**
2. **Never manually modify resources managed by Terraform** - always use Terraform
3. **Use version control** - commit all `.tf` files (but not `.tfvars` or state files)
4. **Review changes carefully** - especially for databases and storage
5. **Enable deletion protection** for critical resources (already enabled for Cloud SQL)
6. **Use remote state** for team collaboration
7. **Tag resources** for cost tracking and organization

## Troubleshooting

### Import Errors

If imports fail, check:
- Resource names match exactly
- You have proper permissions
- Resources exist in the specified project/region

### State Conflicts

If you get state lock errors:
```bash
terraform force-unlock <LOCK_ID>
```

### Configuration Drift

If manual changes were made outside Terraform:
```bash
terraform plan  # Shows drift
terraform apply # Brings infrastructure back to desired state
```

## Additional Resources

- [Terraform GCP Provider Docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [GCP Terraform Modules](https://github.com/terraform-google-modules)

## Support

For issues with:
- **Terraform**: Check [Terraform Documentation](https://www.terraform.io/docs)
- **GCP Resources**: Check [GCP Documentation](https://cloud.google.com/docs)
- **This Configuration**: Review the comments in each `.tf` file
