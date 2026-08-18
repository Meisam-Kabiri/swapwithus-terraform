provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file("~/.config/gcloud/application_default_credentials.json")
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

