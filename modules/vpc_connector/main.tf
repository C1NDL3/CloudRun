resource "google_vpc_access_connector" "connector" {
  project = var.project_id
  name    = var.name
  region  = var.region
  
  subnet {
    name = split("/", var.subnet)[length(split("/", var.subnet)) - 1]
  }


  min_throughput = 200 # Mbps
  max_throughput = 300 # Mbps
}

output "connector_id" {
  value = google_vpc_access_connector.connector.id
}