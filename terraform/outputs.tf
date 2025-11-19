output "service_url" {
  description = "URL of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.billing_consumer.uri
}

output "service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.billing_consumer.name
}

output "service_account_email" {
  description = "Email of the service account used by Cloud Run"
  value       = google_service_account.function_sa.email
}

output "artifact_registry_url" {
  description = "URL of the Artifact Registry repository"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}

output "encryption_secret_id" {
  description = "ID of the encryption secret in Secret Manager"
  value       = google_secret_manager_secret.encryption_secret.secret_id
}

output "db_password_secret_id" {
  description = "ID of the database password secret in Secret Manager"
  value       = google_secret_manager_secret.db_password.secret_id
}

