# ==============================================================================
# GitHub Actions CI/CD - Service Account & IAM Permissions
# ==============================================================================

resource "google_service_account" "github_actions" {
  account_id   = "swapwithus-github-actions"
  display_name = "SwapWithUs GitHub Actions Service Account"
  description  = "Dedicated service account for GitHub Actions CI/CD deployment"
}

# ------------------------------------------------------------------------------
# IAM Deployment & Build Permissions
# ------------------------------------------------------------------------------

# 1. Cloud Build Editor (Allows submitting Docker container builds)
resource "google_project_iam_member" "gha_cloudbuild_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# 2. Cloud Run Admin (Allows deploying container revisions to Cloud Run)
resource "google_project_iam_member" "gha_cloudrun_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# 3. Storage Admin (Allows creating & writing to Cloud Build source zip bucket)
resource "google_project_iam_member" "gha_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# 4. Service Usage Consumer (Allows consuming GCP build services and quota)
resource "google_project_iam_member" "gha_service_usage_consumer" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# 5. Service Account User (Allows deploying containers that run as backend-service)
resource "google_project_iam_member" "gha_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# 6. Project Viewer (Allows polling Cloud Build status and streaming logs)
resource "google_project_iam_member" "gha_viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}


