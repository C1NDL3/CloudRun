data "google_compute_network" "vpc" {
  project = var.project_id
  name    = var.vpc_name
}

resource "google_compute_router" "router" {
  name    = "${var.vpc_name}-router-${var.region}"
  project = var.project_id
  region  = var.region
  network = data.google_compute_network.vpc.id
  bgp { asn = 64514 }
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  project                            = var.project_id
  region                             = var.region
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ALL"
  }
}