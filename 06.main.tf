module "project_services" {
  source     = "./modules/project_services"
  project_id = var.project_id
}

module "network" {
  source                = "./modules/network"
  project_id            = var.project_id
  vpc_name              = var.vpc_name
  region1               = var.region1
  region2               = var.region2
  subnet1_cidr          = var.subnet1_cidr
  subnet2_cidr          = var.subnet2_cidr
  subnet_connector_cidr = var.subnet_connector_cidr


  depends_on = [module.project_services]
}

module "vpc_connector" {
  source     = "./modules/vpc_connector"
  project_id = var.project_id
  name       = "svc-connector"
  region     = var.region1
  subnet     = module.network.subnet_connector_self_link


  depends_on = [module.network]
}

module "cloud_nat" {
  source     = "./modules/cloud_nat"
  project_id = var.project_id
  region     = var.region1
  vpc_name   = var.vpc_name
  nat_name   = "demo-nat"
  labels     = local.common_labels

  depends_on = [module.network]
}

module "artifact_registry" {
  source     = "./modules/artifact_registry"
  project_id = var.project_id
  location   = var.artifact_repo_location
  repo_name  = var.artifact_repo_name
  labels     = local.common_labels

  depends_on = [module.project_services]
}

module "cloud_run" {
  source        = "./modules/cloud_run"
  project_id    = var.project_id
  region        = var.region1
  service_name  = var.cloud_run_service_name
  image         = var.image_name
  vpc_connector = module.vpc_connector.connector_id

  # NOWE – ustaw na false, żeby pozwolić na destroy/create
  deletion_protection = false

  depends_on = [module.vpc_connector]
}

module "lb_http_serverless" {
  source                 = "./modules/lb_http_serverless"
  project_id             = var.project_id
  region                 = var.region1
  backend_name           = "srvless-backend"
  url_map_name           = "srvless-url-map"
  forwarding_rule_name   = "srvless-fr-http"
  target_proxy_name      = "srvless-http-proxy"
  neg_name               = "srvless-neg"
  cloud_run_service_name = var.cloud_run_service_name


  depends_on = [module.cloud_run]
}

module "logging" {
  source     = "./modules/logging"
  project_id = var.project_id

  depends_on = [module.project_services]
}

module "ci_wif" {
  source      = "./modules/ci_wif"
  project_id  = var.project_id
  github_repo = "C1NDL3/CloudRun"

  depends_on = [module.project_services] # zapewnij, że API są włączone (sts/iam/iamcredentials/logging)
}