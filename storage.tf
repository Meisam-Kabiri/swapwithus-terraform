# Cloud Storage bucket for listing images
resource "google_storage_bucket" "listing_images" {
  name          = var.storage_bucket_name
  location      = local.storage_location
  storage_class = "STANDARD"

  uniform_bucket_level_access = true

  # No CORS configuration (doesn't exist in GCP)
  # No lifecycle rules (doesn't exist in GCP)
}

# Cloud Storage bucket for private chat media in Europe (Finland 🇫🇮)
resource "google_storage_bucket" "chat_media" {
  name          = "swapwithus-chat-media"
  location      = var.region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
}


# Bucket IAM - Allow public read if needed
# resource "google_storage_bucket_iam_member" "public_read" {
#   bucket = google_storage_bucket.listing_images.name
#   role   = "roles/storage.objectViewer"
#   member = "allUsers"
# }
