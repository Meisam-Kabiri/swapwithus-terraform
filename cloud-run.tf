# -------------------------------
# Cloud Run Service - SwapWithUs Backend
# Fully managed, Cloud Run v2
# -------------------------------

resource "google_cloud_run_v2_service" "backend" {
  name     = var.service_name
  location = local.cloud_run_region

  template {


    service_account = google_service_account.backend_service.email

    # Container definition
    containers {
      image = "gcr.io/${var.project_id}/swapwithus-backend:latest"

      resources {
        limits = {
          memory = var.cloud_run_memory
          cpu    = "1"
        }
      }

      # Environment variables
      env {
        name  = "SWAPWITHUS_PROJECT_ID"
        value = var.project_id
      }

      env {
        name  = "SWAPWITHUS_SQL_REGION"
        value = local.sql_region
      }

      env {
        name  = "SWAPWITHUS_SQL_INSTANCE"
        value = var.sql_instance_name
      }

      env {
        name  = "SWAPWITHUS_DATABASE_NAME"
        value = var.database_name
      }

      env {
        name  = "SWAPWITHUS_DB_USER"
        value = var.db_user
      }

      env {
        name  = "SWAPWITHUS_DB_HOST"
        value = google_sql_database_instance.main.public_ip_address
      }

      env {
        name  = "GOOGLE_CLOUD_STORAGE_BUCKET"
        value = var.storage_bucket_name
      }

      env {
        name  = "FIREBASE_STORAGE_BUCKET"
        value = google_storage_bucket.chat_media.name
      }


      # Secrets
      env {
        name = "SWAPWITHUS_DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.database_url.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "SWAPWITHUS_DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "SWAPWITHUS_MAPS_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.maps_api_key.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "GOOGLE_CLOUD_CDN_SIGNING_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.cdn_signing_key.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "GOOGLE_CLOUD_CDN_KEY_NAME"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.cdn_key_name.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "REDIS_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.redis_url.secret_id
            version = "latest"
          }
        }
      }

      # Volume mounts
      volume_mounts {
        name       = "firebase-adminsdk-tiy-weq"
        mount_path = "/secrets"
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }

    # Volumes
    volumes {
      name = "firebase-adminsdk-tiy-weq"
      secret {
        secret       = google_secret_manager_secret.firebase_adminsdk.secret_id
        default_mode = 0
        items {
          version = "latest"
          path    = "firebase-credentials.json"
        }
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = ["${var.project_id}:${local.sql_region}:${var.sql_instance_name}"]
      }
    }

    # Scaling
    scaling {
      max_instance_count = var.cloud_run_max_instances
    }

    timeout = "${var.cloud_run_timeout}s"
  }

  # Route 100% traffic to latest revision
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [client, client_version]
  }


  depends_on = [
    google_sql_database_instance.main,
    google_secret_manager_secret.firebase_adminsdk,
    google_secret_manager_secret.database_url,
    google_secret_manager_secret.db_password,
    google_secret_manager_secret.maps_api_key,
    google_secret_manager_secret.cdn_signing_key,
    google_secret_manager_secret.cdn_key_name,
    google_secret_manager_secret.redis_url
  ]
}

# -------------------------------
# IAM for public access
# -------------------------------
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloud_run_v2_service.backend.name
  location = google_cloud_run_v2_service.backend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
