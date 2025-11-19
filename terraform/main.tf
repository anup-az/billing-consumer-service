terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  
  backend "gcs" {
    # Backend configuration will be provided via backend config file
    # bucket = "your-terraform-state-bucket"
    # prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
  ])
  
  project = var.project_id
  service = each.value
  
  disable_on_destroy = false
}

# Artifact Registry for storing container images
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "billing-consumer-repo"
  description   = "Docker repository for billing consumer service"
  format        = "DOCKER"
  
  depends_on = [google_project_service.required_apis]
}

# Service Account for Cloud Function
resource "google_service_account" "function_sa" {
  account_id   = "billing-consumer-fn-sa"
  display_name = "Billing Consumer Cloud Function Service Account"
  description  = "Service account used by billing consumer Cloud Function"
}

# Grant Cloud SQL Client role to service account
resource "google_project_iam_member" "function_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Grant Secret Manager Secret Accessor role
resource "google_project_iam_member" "function_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Grant logging permissions
resource "google_project_iam_member" "function_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Secret Manager secrets
resource "google_secret_manager_secret" "encryption_secret" {
  secret_id = "billing-consumer-encryption-secret"
  
  replication {
    auto {}
  }
  
  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "billing-consumer-db-password"
  
  replication {
    auto {}
  }
  
  depends_on = [google_project_service.required_apis]
}

# Cloud Storage bucket for function source code
resource "google_storage_bucket" "function_source" {
  name          = "${var.project_id}-billing-consumer-source"
  location      = var.region
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }
}

# Cloud Run service (Gen2 Cloud Functions use Cloud Run)
resource "google_cloud_run_v2_service" "billing_consumer" {
  name     = "billing-consumer-service-${var.environment}"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"
  
  template {
    service_account = google_service_account.function_sa.email
    
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }
    
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/billing-consumer-service:${var.image_tag}"
      
      ports {
        container_port = 8080
      }
      
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
      
      env {
        name  = "SPRING_PROFILES_ACTIVE"
        value = var.environment
      }
      
      env {
        name  = "BILLING_DB_URL"
        value = "jdbc:mysql:///${var.db_name}?cloudSqlInstance=${var.cloud_sql_connection_name}&socketFactory=com.google.cloud.sql.mysql.SocketFactory&user=${var.db_username}"
      }
      
      env {
        name  = "BILLING_DB_USERNAME"
        value = var.db_username
      }
      
      env {
        name = "BILLING_DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
      
      env {
        name = "ENCRYPTION_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.encryption_secret.secret_id
            version = "latest"
          }
        }
      }
      
      env {
        name  = "BILLING_DB_DRIVER"
        value = "com.mysql.cj.jdbc.Driver"
      }
    }
    
    vpc_access {
      # Uncomment if using VPC connector
      # connector = var.vpc_connector_name
      egress = "PRIVATE_RANGES_ONLY"
    }
  }
  
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
  
  depends_on = [
    google_project_service.required_apis,
    google_artifact_registry_repository.docker_repo
  ]
}

# Make the service publicly accessible (adjust as needed)
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  count = var.allow_public_access ? 1 : 0
  
  location = google_cloud_run_v2_service.billing_consumer.location
  name     = google_cloud_run_v2_service.billing_consumer.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

