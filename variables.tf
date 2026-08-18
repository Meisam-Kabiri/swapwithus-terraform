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

variable "cloudflare_api_token" {
  description = "Cloudflare API Token with DNS edit access"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for swapwithus.com"
  type        = string
  default     = "a8d511407e9dcaf145b121d7a06a2537"
}

variable "domain_name" {
  description = "Domain name managed in Cloudflare"
  type        = string
  default     = "swapwithus.com"
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
  default     = "82a2140ebc2261410ad968e71e1783ce"
}

variable "web_app_ip" {
  description = "Public IP address for the swapwithus web app"
  type        = string
  default     = "216.198.79.1"
}



