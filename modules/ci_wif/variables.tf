variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "pool_id" {
  description = "Workload Identity Pool ID"
  type        = string
  default     = "github-pool"
}

variable "provider_id" {
  description = "Workload Identity Provider ID"
  type        = string
  default     = "github-provider"
}

variable "github_repo" {
  description = "Dozwolone repo w formacie owner/repo"
  type        = string
}