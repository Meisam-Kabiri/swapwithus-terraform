# ------------------------------------------------------------------------------
# Firebase & Cloud Firestore Management for swapwithus-project
# ------------------------------------------------------------------------------

# 1. Enable Firebase Service on GCP Project
resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id
}

# 2. Provision Cloud Firestore Database
resource "google_firestore_database" "database" {
  provider                    = google-beta
  project                     = var.project_id
  name                        = "firestore-messages-databases"
  location_id                 = var.region
  type                        = "FIRESTORE_NATIVE"
  concurrency_mode            = "PESSIMISTIC"
  app_engine_integration_mode = "DISABLED"
  deletion_policy             = "ABANDON"
}

# 3. Firestore Security Ruleset
resource "google_firebaserules_ruleset" "firestore" {
  project = var.project_id

  source {
    files {
      name    = "firestore.rules"
      content = file("${path.module}/firestore.rules")
    }
  }

  depends_on = [google_firestore_database.database]
}

# 4. Release Ruleset to Cloud Firestore
resource "google_firebaserules_release" "firestore_release" {
  project      = var.project_id
  name         = "cloud.firestore/firestore-messages-databases"
  ruleset_name = google_firebaserules_ruleset.firestore.name
}

# 5. Firebase Auth Authorized Domains Whitelist
resource "google_identity_platform_config" "identity_config" {
  project = var.project_id

  authorized_domains = [
    "localhost",
    "swapwithus-project.firebaseapp.com",
    "swapwithus-project.web.app",
    "swapwithus.com",
    "auth.expo.io",
    "94.252.13.138",
    "www.swapwithus.com",
    "cdn.swapwithus.com"
  ]
}

# 6. Firebase Web App Registration
resource "google_firebase_web_app" "web_app" {
  provider     = google-beta
  project      = var.project_id
  display_name = "swapwithus-web"

  depends_on = [google_firebase_project.default]
}



