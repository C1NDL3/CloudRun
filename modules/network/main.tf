resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "Demo VPC for Cloud Run + NAT"
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet1" {
  name                     = "${var.vpc_name}-subnet-${var.region1}"
  project                  = var.project_id
  ip_cidr_range            = var.subnet1_cidr
  region                   = var.region1
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  purpose                  = "PRIVATE"
  role                     = "ACTIVE"
  stack_type               = "IPV4_ONLY"
}

# NOWY subnet dedykowany dla VPC Connectora (/28!)
resource "google_compute_subnetwork" "subnet_connector" {
  name                     = "${var.vpc_name}-connector-${var.region1}"
  project                  = var.project_id
  ip_cidr_range            = var.subnet_connector_cidr
  region                   = var.region1
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  stack_type               = "IPV4_ONLY"
}

resource "google_compute_subnetwork" "subnet2" {
  name                     = "${var.vpc_name}-subnet-${var.region2}"
  project                  = var.project_id
  ip_cidr_range            = var.subnet2_cidr
  region                   = var.region2
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  purpose                  = "PRIVATE"
  role                     = "ACTIVE"
  stack_type               = "IPV4_ONLY"
}

output "vpc_self_link" {
  value = google_compute_network.vpc.self_link
}

output "subnet1_self_link" {
  value = google_compute_subnetwork.subnet1.self_link
}

output "subnet2_self_link" {
  value = google_compute_subnetwork.subnet2.self_link
}


output "subnet_connector_self_link" {
  value = google_compute_subnetwork.subnet_connector.self_link
}