resource "google_cloud_run_v2_service" "svc" {
  name     = var.service_name
  location = var.region
  labels   = var.labels

  deletion_protection = var.deletion_protection

  template {
    # WŁĄCZA "CPU Always allocated" (wyłącza throttling CPU w bezczynności)
    annotations = {
      "run.googleapis.com/cpu-throttling" = "false"
    }

    scaling {
      min_instance_count = 1
      max_instance_count = 3
    }

    vpc_access {
      connector = var.vpc_connector
      egress    = "ALL_TRAFFIC"
    }

    containers {
      image = var.image

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      env {
        name  = "TZ"
        value = "UTC"
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = "INGRESS_TRAFFIC_ALL"
}

resource "google_cloud_run_v2_service_iam_member" "invoker" {
  name     = google_cloud_run_v2_service.svc.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "url" {
  value = google_cloud_run_v2_service.svc.uri
}
