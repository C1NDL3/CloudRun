variable "project_id" { type = string }
variable "region" { type = string }
variable "service_name" { type = string }
variable "image" { type = string }
variable "vpc_connector" { type = string }

# NOWE
variable "deletion_protection" {
  description = "Protect Cloud Run service from accidental deletion"
  type        = bool
  default     = false
}