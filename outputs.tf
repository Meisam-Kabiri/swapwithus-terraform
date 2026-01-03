output "cloud_run_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.backend.uri
}

output "sql_instance_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = google_sql_database_instance.main.connection_name
}

output "sql_instance_ip" {
  description = "Cloud SQL instance public IP"
  value       = google_sql_database_instance.main.public_ip_address
}

output "storage_bucket_name" {
  description = "Cloud Storage bucket name"
  value       = google_storage_bucket.listing_images.name
}

output "storage_bucket_url" {
  description = "Cloud Storage bucket URL"
  value       = google_storage_bucket.listing_images.url
}

output "service_account_email" {
  description = "Service account email"
  value       = google_service_account.backend_service.email
}
