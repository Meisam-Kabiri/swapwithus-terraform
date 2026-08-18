# ------------------------------------------------------------------------------
# Cloudflare DNS & Security Management for swapwithus.com
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Managed DNS Records
# ------------------------------------------------------------------------------

# 1. Apex Domain (@ / swapwithus.com)
resource "cloudflare_record" "root" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  content = var.web_app_ip
  type    = "A"
  proxied = true # Orange Cloud 🟠 (Cloudflare CDN, WAF, DDoS Protection)
}


# 2. Subdomain WWW (www.swapwithus.com)
resource "cloudflare_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = var.web_app_ip
  type    = "A"
  proxied = true # Orange Cloud 🟠
}

# 3. Subdomain CDN (cdn.swapwithus.com -> Cloudflare Worker Proxy)
resource "cloudflare_record" "cdn" {
  zone_id = var.cloudflare_zone_id
  name    = "cdn"
  content = var.web_app_ip
  type    = "A"
  proxied = true # Orange Cloud 🟠 (Handled by Cloudflare Worker swapwithus-gcs-proxy)
}


# ------------------------------------------------------------------------------
# Cloudflare Worker: Authenticated Private GCS Proxy
# ------------------------------------------------------------------------------

resource "cloudflare_workers_script" "gcs_proxy" {
  account_id = var.cloudflare_account_id
  name       = "swapwithus-gcs-proxy"
  content    = file("${path.module}/worker.js")
  module     = true
}

# Route cdn.swapwithus.com/* to the Cloudflare Worker
resource "cloudflare_workers_route" "cdn_route" {
  zone_id     = var.cloudflare_zone_id
  pattern     = "cdn.swapwithus.com/*"
  script_name = cloudflare_workers_script.gcs_proxy.name
}

# Environment Secret: GCS HMAC Access Key
resource "cloudflare_workers_secret" "gcs_access_key" {
  account_id  = var.cloudflare_account_id
  name        = "GCS_ACCESS_KEY"
  script_name = cloudflare_workers_script.gcs_proxy.name
  secret_text = google_storage_hmac_key.storage_service_hmac.access_id
}

# Environment Secret: GCS HMAC Secret Key
resource "cloudflare_workers_secret" "gcs_secret_key" {
  account_id  = var.cloudflare_account_id
  name        = "GCS_SECRET_KEY"
  script_name = cloudflare_workers_script.gcs_proxy.name
  secret_text = google_storage_hmac_key.storage_service_hmac.secret
}

# Environment Secret: GCS Bucket Name
resource "cloudflare_workers_secret" "gcs_bucket_name" {
  account_id  = var.cloudflare_account_id
  name        = "GCS_BUCKET_NAME"
  script_name = cloudflare_workers_script.gcs_proxy.name
  secret_text = var.storage_bucket_name
}
