variable "project_id" {
  type = string
}

locals {
  apis = [
    "compute.googleapis.com",
    "run.googleapis.com",
    "vpcaccess.googleapis.com",
    "artifactregistry.googleapis.com",
    "logging.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}

resource "google_project_service" "enable" {
  for_each           = toset(local.apis)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}