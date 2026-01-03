# Local values for computed regions
# This allows flexibility if resources are in different regions

locals {
  # Use specific region variables if set, otherwise fall back to default region
  cloud_run_region = var.cloud_run_region != "" ? var.cloud_run_region : var.region
  sql_region       = var.sql_region != "" ? var.sql_region : var.region

  # Storage location - using EU multi-region for better availability
  storage_location = var.storage_location != "" ? var.storage_location : "EU"
}
