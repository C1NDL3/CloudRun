provider "google" {
  project = var.project_id
  region  = var.region1
}

provider "google-beta" {
  project = var.project_id
  region  = var.region1
}