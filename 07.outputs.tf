output "cloud_run_url" {
  description = "Cloud Run default URL"
  value       = module.cloud_run.url
}

output "lb_ip" {
  description = "Global external HTTP LB IP"
  value       = module.lb_http_serverless.ip_address
}

output "lb_http_url" {
  description = "Convenience URL for LB (HTTP)"
  value       = "http://${module.lb_http_serverless.ip_address}"
}