# Backend configuration for dev environment
# Run: terraform init -backend-config=backend.tf

terraform {
  backend "gcs" {
    bucket = "hybrid-dolphin-478706-q8-terraform-state"
    prefix = "billing-consumer/dev"
  }
}

