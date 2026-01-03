# Service Account for Cloud Run
# Step 1: Create the Service Account (just the identity)
# ────────────────────────────────────────────────

resource "google_service_account" "backend_service" {
  account_id   = "swapwithus-backend-service"
  display_name = "SwapWithUs Backend Service Account"
  description  = "Service account for SwapWithUs backend Cloud Run service"
}

# Step 2: Attach Permissions (separate resources)
# ────────────────────────────────────────────────
# IAM Policy Bindings
resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.backend_service.email}"
}

resource "google_project_iam_member" "storage_object_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.backend_service.email}"
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend_service.email}"
}

resource "google_project_iam_member" "token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.backend_service.email}"
}

# Storage service account (used for CDN signed URLs and local development)
resource "google_service_account" "storage_service" {
  account_id   = "swapwithus-storage-service"
  display_name = "swapwithus-storage-service"
  description  = "Service account for storage operations and CDN signed URLs"
}

resource "google_project_iam_member" "storage_service_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.storage_service.email}"
}
