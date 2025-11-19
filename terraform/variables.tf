variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "hybrid-dolphin-478706-q8"
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "asia-south1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "db_name" {
  description = "Cloud SQL database name"
  type        = string
  default     = "billing_consumer"
}

variable "db_username" {
  description = "Cloud SQL database username"
  type        = string
  default     = "billing_consumer_app"
}

variable "cloud_sql_connection_name" {
  description = "Cloud SQL connection name (project:region:instance)"
  type        = string
  default     = "hybrid-dolphin-478706-q8:asia-south1:lc-billing-app"
}

variable "allow_public_access" {
  description = "Allow public access to the Cloud Run service"
  type        = bool
  default     = true
}

variable "vpc_connector_name" {
  description = "VPC connector name for private Cloud SQL access"
  type        = string
  default     = ""
}

