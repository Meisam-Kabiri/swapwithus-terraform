# Cloud SQL PostgreSQL Instance
resource "google_sql_database_instance" "main" {
  name             = var.sql_instance_name
  database_version = "POSTGRES_18"
  region           = local.sql_region

  settings {
    tier              = var.sql_tier
    availability_type = "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = 10

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = false
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled = true
      ssl_mode     = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"

      authorized_networks {
        name  = "home"
        value = "94.252.14.21"
      }

      authorized_networks {
        name  = "home-alt"
        value = "94.252.13.146"
      }

      authorized_networks {
        name  = "home-old"
        value = "94.252.81.64"
      }
    }

    # No maintenance_window configured in GCP
  }

  deletion_protection = true
}

# Database
resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.main.name
}

# Database user
resource "google_sql_user" "postgres" {
  name     = var.db_user
  instance = google_sql_database_instance.main.name
  # Password should be managed via Secret Manager
  # password = var.db_password  # Don't commit passwords!
}
