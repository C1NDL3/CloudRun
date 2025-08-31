resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repo_name
  description   = "Docker images for hello-python"
  format        = "DOCKER"
}

output "repository_url" {
  value = "${var.location}-docker.pkg.dev/${var.project_id}/${var.repo_name}"
}