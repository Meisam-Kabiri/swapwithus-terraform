provider "google" {
  project               = var.project_id
  region                = var.region
  credentials           = file("~/.config/gcloud/application_default_credentials.json")
  user_project_override = true
  billing_project       = var.project_id
}

provider "google-beta" {
  project               = var.project_id
  region                = var.region
  credentials           = file("~/.config/gcloud/application_default_credentials.json")
  user_project_override = true
  billing_project       = var.project_id
}



provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

