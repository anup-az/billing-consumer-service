#!/bin/bash
#
# Setup GCP Infrastructure
# This script creates the necessary GCP resources for the application
#

set -e

# Configuration
PROJECT_ID="hybrid-dolphin-478706-q8"
REGION="asia-south1"
TERRAFORM_STATE_BUCKET="${PROJECT_ID}-terraform-state"

echo "=========================================="
echo "Setting up GCP Infrastructure"
echo "=========================================="
echo ""
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo ""

# Set the project
gcloud config set project "${PROJECT_ID}"

# Enable required APIs
echo "📦 Enabling required GCP APIs..."
APIS=(
  "cloudfunctions.googleapis.com"
  "cloudbuild.googleapis.com"
  "cloudscheduler.googleapis.com"
  "secretmanager.googleapis.com"
  "sqladmin.googleapis.com"
  "run.googleapis.com"
  "artifactregistry.googleapis.com"
  "compute.googleapis.com"
  "storage.googleapis.com"
  "iam.googleapis.com"
)

for API in "${APIS[@]}"; do
  echo "  Enabling: $API"
  gcloud services enable "$API" --project="${PROJECT_ID}"
done
echo "✅ APIs enabled"
echo ""

# Create Terraform state bucket
echo "🪣 Creating Terraform state bucket..."
if gsutil ls -b "gs://${TERRAFORM_STATE_BUCKET}" &>/dev/null; then
  echo "⚠️  Terraform state bucket already exists, skipping creation"
else
  gsutil mb -p "${PROJECT_ID}" -l "${REGION}" "gs://${TERRAFORM_STATE_BUCKET}"
  gsutil versioning set on "gs://${TERRAFORM_STATE_BUCKET}"
  gsutil uniformbucketlevelaccess set on "gs://${TERRAFORM_STATE_BUCKET}"
  echo "✅ Terraform state bucket created"
fi
echo ""

# Create Artifact Registry repository
echo "📦 Creating Artifact Registry repository..."
REPO_NAME="billing-consumer-repo"
if gcloud artifacts repositories describe "${REPO_NAME}" \
  --location="${REGION}" \
  --project="${PROJECT_ID}" &>/dev/null; then
  echo "⚠️  Artifact Registry repository already exists, skipping creation"
else
  gcloud artifacts repositories create "${REPO_NAME}" \
    --repository-format=docker \
    --location="${REGION}" \
    --description="Docker repository for billing consumer service" \
    --project="${PROJECT_ID}"
  echo "✅ Artifact Registry repository created"
fi
echo ""

# Store secrets in Secret Manager
echo "🔐 Setting up Secret Manager secrets..."

# Encryption secret
ENCRYPTION_SECRET="India@JAN@2026_salt_to_make_it_32chars"
if gcloud secrets describe billing-consumer-encryption-secret \
  --project="${PROJECT_ID}" &>/dev/null; then
  echo "⚠️  Encryption secret already exists"
  read -p "Do you want to update it? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -n "${ENCRYPTION_SECRET}" | gcloud secrets versions add billing-consumer-encryption-secret \
      --data-file=- \
      --project="${PROJECT_ID}"
    echo "✅ Encryption secret updated"
  fi
else
  echo -n "${ENCRYPTION_SECRET}" | gcloud secrets create billing-consumer-encryption-secret \
    --data-file=- \
    --replication-policy="automatic" \
    --project="${PROJECT_ID}"
  echo "✅ Encryption secret created"
fi

# Database password
DB_PASSWORD="India@JAN@2026"
if gcloud secrets describe billing-consumer-db-password \
  --project="${PROJECT_ID}" &>/dev/null; then
  echo "⚠️  Database password secret already exists"
  read -p "Do you want to update it? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -n "${DB_PASSWORD}" | gcloud secrets versions add billing-consumer-db-password \
      --data-file=- \
      --project="${PROJECT_ID}"
    echo "✅ Database password secret updated"
  fi
else
  echo -n "${DB_PASSWORD}" | gcloud secrets create billing-consumer-db-password \
    --data-file=- \
    --replication-policy="automatic" \
    --project="${PROJECT_ID}"
  echo "✅ Database password secret created"
fi
echo ""

echo "=========================================="
echo "✅ Infrastructure Setup Complete!"
echo "=========================================="
echo ""
echo "📋 Summary:"
echo "  • Terraform state bucket: gs://${TERRAFORM_STATE_BUCKET}"
echo "  • Artifact Registry: ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}"
echo "  • Secret Manager secrets created"
echo ""
echo "📋 Add these secrets to your GitHub repository:"
echo ""
echo "Secret Name: GCP_TERRAFORM_STATE_BUCKET"
echo "Secret Value: ${TERRAFORM_STATE_BUCKET}"
echo ""
echo "🔗 Add secrets at: https://github.com/anup-az/billing-consumer-service/settings/secrets/actions"
echo ""
echo "Next steps:"
echo "  1. Run: ./scripts/setup-workload-identity.sh"
echo "  2. Add all GitHub Secrets"
echo "  3. Push code to 'dev' branch to trigger deployment"
echo ""

