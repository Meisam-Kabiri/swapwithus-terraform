# CDN for Cloud Storage Images
# Backend bucket that serves images from Cloud Storage with CDN enabled

resource "google_compute_backend_bucket" "images" {
  name        = "swapwithus-images-backend"
  bucket_name = google_storage_bucket.listing_images.name
  enable_cdn  = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 86400
    max_ttl           = 86400
    client_ttl        = 3600
    negative_caching  = true
    request_coalescing = true
    serve_while_stale = 86400

    signed_url_cache_max_age_sec = 86400
  }
}

# URL map for the load balancer
resource "google_compute_url_map" "images_lb" {
  name            = "swapwithus-images-lb"
  default_service = google_compute_backend_bucket.images.id
}

# HTTP target proxy (actual name in GCP)
resource "google_compute_target_http_proxy" "images_lb" {
  name    = "swapwithus-images-http-proxy"
  url_map = google_compute_url_map.images_lb.id
}

# HTTP forwarding rule (actual name in GCP)
resource "google_compute_global_forwarding_rule" "images_http_rule" {
  name       = "swapwithus-images-http-rule"
  target     = google_compute_target_http_proxy.images_lb.id
  port_range = "80"
}

# HTTPS target proxy (exists in GCP)
resource "google_compute_target_https_proxy" "images_lb" {
  name             = "swapwithus-images-lb-target-proxy"
  url_map          = google_compute_url_map.images_lb.id
  ssl_certificates = ["https://www.googleapis.com/compute/v1/projects/swapwithus-project/global/sslCertificates/ssl-certificate-cdn-swapwithus"]
}

# HTTPS forwarding rule (exists in GCP)
resource "google_compute_global_forwarding_rule" "images_https_rule" {
  name        = "https-frontend"
  target      = google_compute_target_https_proxy.images_lb.id
  port_range  = "443-443"
  ip_protocol = "TCP"
  ip_version  = "IPV4"
}

# Optional: Reserve a static IP for the load balancer
# Uncomment if you want to manage the IP address
# resource "google_compute_global_address" "images_lb" {
#   name = "swapwithus-images-lb-ip"
# }
