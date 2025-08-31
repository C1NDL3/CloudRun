terraform {
  backend "gcs" {
    bucket = "tf-state-devops-gcp-470517"
    prefix = "terraform/state/devops-gcp-470517"
  }
}