# Cloud Storage bucket for listing images
resource "google_storage_bucket" "listing_images" {
  name          = var.storage_bucket_name
  location      = local.storage_location
  storage_class = "STANDARD"

  uniform_bucket_level_access = true

  # No CORS configuration (doesn't exist in GCP)
  # No lifecycle rules (doesn't exist in GCP)
}

# Bucket IAM - public read, toggled by var.listing_images_public.
# Bucket uses uniform bucket-level access, so this IAM binding (not object ACLs)
# is the correct way to expose objects publicly. Removing the binding (set the
# var back to false) re-locks the bucket immediately.
resource "google_storage_bucket_iam_member" "public_read" {
  count  = var.listing_images_public ? 1 : 0
  bucket = google_storage_bucket.listing_images.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
