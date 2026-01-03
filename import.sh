#!/bin/bash

# Terraform Import Script for SwapWithUs GCP Infrastructure
# This script imports existing GCP resources into Terraform state

set -e

PROJECT_ID="swapwithus-project"
REGION="europe-north1"
SERVICE_NAME="swapwithus-backend"
SQL_INSTANCE="swapwithus-db"
BUCKET_NAME="swapwithus-listing-images"
SERVICE_ACCOUNT="swapwithus-backend-service"

echo "========================================="
echo "Importing GCP Resources into Terraform"
echo "========================================="
echo ""

# Initialize Terraform
echo "1. Initializing Terraform..."
terraform init
echo ""

# Import Service Account
echo "2. Importing Service Account..."
terraform import google_service_account.backend_service \
  "projects/${PROJECT_ID}/serviceAccounts/${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" || true
echo ""

# Import IAM Bindings for Backend Service Account
echo "3. Importing IAM Policy Bindings for Backend Service..."
terraform import google_project_iam_member.secret_accessor \
  "${PROJECT_ID} roles/secretmanager.secretAccessor serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" || true

terraform import google_project_iam_member.storage_object_admin \
  "${PROJECT_ID} roles/storage.objectAdmin serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" || true

terraform import google_project_iam_member.cloudsql_client \
  "${PROJECT_ID} roles/cloudsql.client serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" || true

terraform import google_project_iam_member.token_creator \
  "${PROJECT_ID} roles/iam.serviceAccountTokenCreator serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" || true
echo ""

# Import Storage Service Account
echo "3b. Importing Storage Service Account..."
terraform import google_service_account.storage_service \
  "projects/${PROJECT_ID}/serviceAccounts/swapwithus-storage-service@${PROJECT_ID}.iam.gserviceaccount.com" || true

terraform import google_project_iam_member.storage_service_admin \
  "${PROJECT_ID} roles/storage.admin serviceAccount:swapwithus-storage-service@${PROJECT_ID}.iam.gserviceaccount.com" || true
echo ""

# Import Cloud Storage Bucket
echo "4. Importing Cloud Storage Bucket..."
terraform import google_storage_bucket.listing_images "${BUCKET_NAME}" || true
echo ""

# Import Cloud SQL Instance
echo "5. Importing Cloud SQL Instance..."
terraform import google_sql_database_instance.main "${PROJECT_ID}:${SQL_INSTANCE}" || true
echo ""

# Import Database
echo "6. Importing Database..."
terraform import google_sql_database.database "${PROJECT_ID}:${SQL_INSTANCE}:swapwithusDB" || true
echo ""

# Import Database User
echo "7. Importing Database User..."
terraform import google_sql_user.postgres "${PROJECT_ID}/${SQL_INSTANCE}/postgres" || true
echo ""

# Import Secret Manager Secrets
echo "8. Importing Secret Manager Secrets..."
terraform import google_secret_manager_secret.firebase_adminsdk \
  "projects/${PROJECT_ID}/secrets/firebase-adminsdk" || true

terraform import google_secret_manager_secret.database_url \
  "projects/${PROJECT_ID}/secrets/swapwithus_database_url" || true

terraform import google_secret_manager_secret.db_password \
  "projects/${PROJECT_ID}/secrets/swapwithus_db_password" || true

terraform import google_secret_manager_secret.maps_api_key \
  "projects/${PROJECT_ID}/secrets/swapwithus_maps_api_key" || true

terraform import google_secret_manager_secret.cdn_signing_key \
  "projects/${PROJECT_ID}/secrets/google_cloud_cdn_signing_key" || true

terraform import google_secret_manager_secret.cdn_key_name \
  "projects/${PROJECT_ID}/secrets/google_cloud_cdn_key_name" || true

terraform import google_secret_manager_secret.redis_url \
  "projects/${PROJECT_ID}/secrets/redis_url" || true
echo ""

# Import Secret IAM Bindings
echo "9. Importing Secret IAM Bindings..."
terraform import google_secret_manager_secret_iam_member.firebase_access \
  "projects/${PROJECT_ID}/secrets/firebase-adminsdk roles/secretmanager.secretAccessor serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" || true

terraform import google_secret_manager_secret_iam_member.database_url_access \
  "projects/${PROJECT_ID}/secrets/swapwithus_database_url roles/secretmanager.secretAccessor serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" || true

terraform import google_secret_manager_secret_iam_member.db_password_access \
  "projects/${PROJECT_ID}/secrets/swapwithus_db_password roles/secretmanager.secretAccessor serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" || true

terraform import google_secret_manager_secret_iam_member.maps_api_key_access \
  "projects/${PROJECT_ID}/secrets/swapwithus_maps_api_key roles/secretmanager.secretAccessor serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" || true

terraform import google_secret_manager_secret_iam_member.cdn_signing_key_access \
  "projects/${PROJECT_ID}/secrets/google_cloud_cdn_signing_key roles/secretmanager.secretAccessor serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" || true

terraform import google_secret_manager_secret_iam_member.cdn_key_name_access \
  "projects/${PROJECT_ID}/secrets/google_cloud_cdn_key_name roles/secretmanager.secretAccessor serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" || true

terraform import google_secret_manager_secret_iam_member.redis_url_access \
  "projects/${PROJECT_ID}/secrets/redis_url roles/secretmanager.secretAccessor serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" || true
echo ""

# Import Cloud Run Service
echo "10. Importing Cloud Run Service..."
terraform import google_cloud_run_v2_service.backend \
  "projects/${PROJECT_ID}/locations/${REGION}/services/${SERVICE_NAME}" || true
echo ""

# Import Cloud Run IAM
echo "11. Importing Cloud Run IAM..."
terraform import google_cloud_run_v2_service_iam_member.public_access \
  "projects/${PROJECT_ID}/locations/${REGION}/services/${SERVICE_NAME} roles/run.invoker allUsers" || true
echo ""

# Import CDN/Load Balancer Resources
echo "12. Importing CDN Backend Bucket..."
terraform import google_compute_backend_bucket.images \
  "swapwithus-images-backend" || true
echo ""

echo "13. Importing Load Balancer URL Map..."
terraform import google_compute_url_map.images_lb \
  "swapwithus-images-lb" || true
echo ""

echo "14. Importing HTTP Target Proxy..."
terraform import google_compute_target_http_proxy.images_lb \
  "swapwithus-images-lb-proxy" || true
echo ""

echo "15. Importing Global Forwarding Rule..."
terraform import google_compute_global_forwarding_rule.images_lb \
  "swapwithus-images-lb-rule" || true
echo ""

echo "========================================="
echo "Import Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Run 'terraform plan' to see if there are any differences"
echo "2. Review and adjust the Terraform configuration if needed"
echo "3. Run 'terraform apply' to sync any remaining changes"
echo ""
echo "Note: You may need to manually adjust some resource configurations"
echo "      to match your existing infrastructure exactly."
