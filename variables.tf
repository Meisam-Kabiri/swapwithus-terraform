variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "europe-north1"
}

variable "cloud_run_region" {
  description = "Cloud Run region (defaults to var.region)"
  type        = string
  default     = ""
}

variable "sql_region" {
  description = "Cloud SQL region (defaults to var.region)"
  type        = string
  default     = ""
}

variable "storage_location" {
  description = "Cloud Storage location (defaults to uppercase var.region)"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "swapwithus-backend"
}

variable "sql_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "swapwithus-db"
}

variable "database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "swapwithusDB"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "postgres"
}

variable "storage_bucket_name" {
  description = "Cloud Storage bucket for listing images"
  type        = string
  default     = "swapwithus-listing-images"
}

variable "service_account_email" {
  description = "Service account email for Cloud Run"
  type        = string
  default     = "swapwithus-backend-service@swapwithus-project.iam.gserviceaccount.com"
}

variable "container_image" {
  description = "Container image for Cloud Run"
  type        = string
  default     = "gcr.io/swapwithus-project/swapwithus-backend"
}

variable "sql_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-f1-micro"  
}

variable "cloud_run_max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10
}

variable "cloud_run_memory" {
  description = "Memory allocation for Cloud Run"
  type        = string
  default     = "512Mi"
}

variable "cloud_run_timeout" {
  description = "Request timeout for Cloud Run"
  type        = number
  default     = 300
}

variable "listing_images_public" {
  description = <<-EOT
    Whether listing images are served publicly (unsigned) instead of via
    time-limited signed CDN URLs. This single switch drives BOTH halves so they
    can never drift:
      * the bucket's allUsers:objectViewer IAM binding (storage.tf), and
      * the backend's IMAGE_URL_MODE env var (cloud-run.tf).
    Default false keeps the current signed-URL behaviour. Set to true to go
    public; set back to false to roll back (re-locks the bucket and re-signs).
  EOT
  type        = bool
  default     = false
}
