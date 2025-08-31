variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region1" {
  description = "Primary region (Cloud Run, VPC connector, NAT, one subnet)"
  type        = string
  default     = "europe-central2"
}

variable "region2" {
  description = "Secondary region (second subnet)"
  type        = string
  default     = "europe-west1"
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
  default     = "demo-vpc"
}

variable "subnet1_cidr" {
  description = "CIDR for subnet in region1"
  type        = string
  default     = "10.10.0.0/24"
}

variable "subnet2_cidr" {
  description = "CIDR for subnet in region2"
  type        = string
  default     = "10.20.0.0/24"
}

variable "subnet_connector_cidr" {
  description = "CIDR for dedicated subnet for VPC Connector (must be /28)"
  type        = string
  default     = "10.10.1.0/28"
}

variable "artifact_repo_name" {
  description = "Artifact Registry repository name"
  type        = string
  default     = "hello-repo"
}

variable "artifact_repo_location" {
  description = "Artifact Registry location (region or multi-region)"
  type        = string
  default     = "europe-central2"
}

variable "image_name" {
  description = "Container image (full URL) to deploy on Cloud Run"
  type        = string
  default     = "europe-central2-docker.pkg.dev/devops-gcp-470517/hello-repo/hello-python:3.0"
}

variable "cloud_run_service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "hello-python-svc"
}

variable "labels" {
  description = "Common labels to apply where supported"
  type        = map(string)
  default = {
    project = "static-website"
    owner   = "devops"
    env     = "dev"
  }
}