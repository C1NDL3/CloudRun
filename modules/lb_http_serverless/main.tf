# Serverless NEG (regional)
resource "google_compute_region_network_endpoint_group" "neg" {
  name                  = var.neg_name
  project               = var.project_id
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = var.cloud_run_service_name
  }
}

# Global backend service with logging enabled
resource "google_compute_backend_service" "backend" {
  name                  = var.backend_name
  project               = var.project_id
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 30

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  backend {
    group = google_compute_region_network_endpoint_group.neg.id
  }
}

resource "google_compute_url_map" "url_map" {
  name    = var.url_map_name
  project = var.project_id
  default_service = google_compute_backend_service.backend.id
}

resource "google_compute_target_http_proxy" "proxy" {
  name    = var.target_proxy_name
  project = var.project_id
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_address" "ip" {
  name    = "${var.forwarding_rule_name}-ip"
  project = var.project_id
}

resource "google_compute_global_forwarding_rule" "fr" {
  name       = var.forwarding_rule_name
  project    = var.project_id
  ip_address = google_compute_global_address.ip.address
  port_range = "80"
  target     = google_compute_target_http_proxy.proxy.id
}

output "ip_address" {
  value = google_compute_global_address.ip.address
}