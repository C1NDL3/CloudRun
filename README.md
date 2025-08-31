# Hello World on Cloud Run via Terraform (VPC, Connector, NAT, HTTP LB, Logs)

## Repo structure
- backend.tf / versions.tf / providers.tf / variables.tf / locals.tf / main.tf / outputs.tf
- modules/
  - project_services
  - network
  - vpc_connector
  - cloud_nat
  - artifact_registry
  - cloud_run
  - lb_http_serverless
- env/dev.tfvars
- app/ (Flask + Dockerfile)

## Prerequisites
- Terraform >= 1.6
- gcloud CLI zalogowany do projektu
- GCS bucket na state: `gs://<TF_STATE_BUCKET>` (utwórz jednorazowo: `gcloud storage buckets create gs://<TF_STATE_BUCKET> --location=<REGION1>`)

## Init & plan/apply
```bash
terraform init -upgrade
terraform fmt
terraform validate
terraform plan -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars -auto-approve
