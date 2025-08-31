variable "project_id" { type = string }
variable "vpc_name" { type = string }
variable "region1" { type = string }
variable "region2" { type = string }
variable "subnet1_cidr" { type = string }
variable "subnet2_cidr" { type = string }
variable "subnet_connector_cidr" {
  type        = string
  description = "CIDR for dedicated subnet used by VPC Connector (must be /28)"
}