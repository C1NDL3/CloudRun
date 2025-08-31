# 1) Log bucket 14 dni
############################
resource "google_logging_project_bucket_config" "logs_14d" {
  project        = var.project_id
  location       = "global"
  bucket_id      = "app-logs-14d"
  retention_days = 14

  # (opcjonalnie) dla porządku nazwy/logicznego podziału
  description = "Application logs retained for 14 days"
}

############################
# 2) Sink -> kieruje wskazane logi do bucketa 14d
############################
resource "google_logging_project_sink" "to_14d_bucket" {
  project = var.project_id
  name    = "route-app-logs-to-14d"
  # Wysyłka do własnego bucketa Logging
  destination = "logging.googleapis.com/projects/${var.project_id}/locations/global/buckets/${google_logging_project_bucket_config.logs_14d.bucket_id}"

  # FILTR: Cloud Run + Artifact Registry (dopasuj do potrzeb)
  filter = join(" OR ", [
    "resource.type=\"cloud_run_revision\"",
    "resource.type=\"artifactregistry_repository\""
  ])

  # Dla dest=LoggingBucket nie są potrzebne uprawnienia do innego serwisu,
  # ale flagę zostawiamy (tworzy SA sinka, nie szkodzi)
  unique_writer_identity = true
}

############################
# 3) Exclusion w _Default — żeby nie duplikować logów
############################
resource "google_logging_project_exclusion" "exclude_app_from_default" {
  project     = var.project_id
  name        = "exclude-app-logs-from-default"
  description = "Exclude Cloud Run & Artifact Registry app logs from _Default bucket"
  # Ten sam filtr co w sinku — wycina je z _Default
  filter   = google_logging_project_sink.to_14d_bucket.filter
  disabled = false
}