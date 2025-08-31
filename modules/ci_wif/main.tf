data "google_project" "this" {
  project_id = var.project_id
}

# 1) Workload Identity Pool
resource "google_iam_workload_identity_pool" "pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "GitHub Actions Pool"
  description               = "WIF dla GitHub Actions z repo ograniczeniem"
}

# 2) Provider dla GitHub OIDC
resource "google_iam_workload_identity_pool_provider" "provider" {
  project                           = var.project_id
  workload_identity_pool_id         = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                      = "GitHub Actions OIDC"
  description                       = "Provider dla token.actions.githubusercontent.com"
  attribute_condition               = "attribute.repository==\"${var.github_repo}\""
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  attribute_mapping = {
    "google.subject"   = "assertion.sub"
    "attribute.actor"  = "assertion.actor"
    "attribute.repository"= "assertion.repository" 
    "attribute.ref"    = "assertion.ref"
    "attribute.sha"    = "assertion.sha"
    "attribute.workflow" = "assertion.workflow"
  }
}

# 3) Dwa konta serwisowe: plan i apply
resource "google_service_account" "sa_plan" {
  project      = var.project_id
  account_id   = "gha-tf-plan"
  display_name = "GitHub Actions - Terraform PLAN"
}

resource "google_service_account" "sa_apply" {
  project      = var.project_id
  account_id   = "gha-tf-apply"
  display_name = "GitHub Actions - Terraform APPLY/DESTROY"
}

# 4) Powiązania WIF -> SA (Workload Identity User)
# Pozwala podmiotom z providera (ograniczonym do repo) podszywać się pod SA.
resource "google_service_account_iam_member" "wif_plan" {
  service_account_id = google_service_account.sa_plan.name
  role               = "roles/iam.workloadIdentityUser"
  # ograniczenie do repo przez ścieżkę principalSet + attribute.repository
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/attribute.repository/${var.github_repo}"
}

resource "google_service_account_iam_member" "wif_apply" {
  service_account_id = google_service_account.sa_apply.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/attribute.repository/${var.github_repo}"
}

# Przydatne outputy do użycia w GitHub Actions
output "workload_identity_provider" {
  value       = "projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.provider.workload_identity_pool_provider_id}"
  description = "Wartość do pola 'workload_identity_provider' w github actions auth"
}

output "sa_plan_email" {
  value = google_service_account.sa_plan.email
}

output "sa_apply_email" {
  value = google_service_account.sa_apply.email
}



################## ci_roles


#################################
# Role dla gha-tf-plan (tylko read-only)
#################################
resource "google_project_iam_member" "plan_viewer" {
  project = var.project_id
  role    = "roles/viewer" # globalny viewer (może listować zasoby)
  member  = "serviceAccount:${google_service_account.sa_plan.email}"
}

# dodatkowo dostęp do Artifact Registry (żeby TF mógł odczytać repo obrazów)
resource "google_project_iam_member" "plan_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.sa_plan.email}"
}

#################################
# Role dla gha-tf-apply (pełne prawa na używane usługi)
#################################
# Artifact Registry – tworzenie/zarządzanie repo + push/pull obrazów
resource "google_project_iam_member" "apply_artifact_admin" {
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.sa_apply.email}"
}

# Cloud Run – tworzenie i zarządzanie usługami
resource "google_project_iam_member" "apply_cloudrun_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.sa_apply.email}"
}

# Networking – VPC, Serverless VPC Connector, Cloud NAT
resource "google_project_iam_member" "apply_network_admin" {
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.sa_apply.email}"
}

# IAM – potrzebne do nadawania invokerów/rol w Cloud Run (minimally: roles/iam.serviceAccountUser)
resource "google_project_iam_member" "apply_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.sa_apply.email}"
}

# Logging – tworzenie bucketów i sinków (retencja logów)
resource "google_project_iam_member" "apply_logging_admin" {
  project = var.project_id
  role    = "roles/logging.configWriter"
  member  = "serviceAccount:${google_service_account.sa_apply.email}"
}
