# Secret Manager Secrets
# Note: Secret values are not managed by Terraform for security
# Only the secret resources are managed, values should be updated manually or via CI/CD

resource "google_secret_manager_secret" "firebase_adminsdk" {
  secret_id = "firebase-adminsdk"

  replication {
    auto {}
  }
}

# Generates the private Firebase Admin SDK credentials JSON key for swapwithus-backend-service
resource "google_service_account_key" "backend_admin_key" {
  service_account_id = google_service_account.backend_service.name
}

resource "google_secret_manager_secret_version" "firebase_adminsdk_version" {
  secret      = google_secret_manager_secret.firebase_adminsdk.id
  secret_data = base64decode(google_service_account_key.backend_admin_key.private_key)
}




resource "google_secret_manager_secret" "database_url" {
  secret_id = "swapwithus_database_url"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "swapwithus_db_password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "maps_api_key" {
  secret_id = "swapwithus_maps_api_key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "cdn_signing_key" {
  secret_id = "google_cloud_cdn_signing_key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "cdn_key_name" {
  secret_id = "google_cloud_cdn_key_name"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "redis_url" {
  secret_id = "redis_url"

  replication {
    auto {}
  }
}

# NOTE: Secret access is granted at PROJECT level via:
# google_project_iam_member.secret_accessor in iam.tf
# Individual per-secret IAM bindings don't exist in GCP
