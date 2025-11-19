#!/bin/bash
#
# Setup Workload Identity Federation for GitHub Actions
# This script configures secure authentication between GitHub Actions and GCP
# without using service account keys.
#

set -e

# Configuration
PROJECT_ID="hybrid-dolphin-478706-q8"
GITHUB_REPO="anup-az/billing-consumer-service"
SERVICE_ACCOUNT_NAME="github-actions-deployer"
WORKLOAD_IDENTITY_POOL="github-actions-pool"
WORKLOAD_IDENTITY_PROVIDER="github-actions-provider"
REGION="asia-south1"

echo "=========================================="
echo "Setting up Workload Identity Federation"
echo "=========================================="
echo ""
echo "Project ID: $PROJECT_ID"
echo "GitHub Repo: $GITHUB_REPO"
echo "Service Account: $SERVICE_ACCOUNT_NAME"
echo ""

# Enable required APIs
echo "📦 Enabling required GCP APIs..."
gcloud services enable iamcredentials.googleapis.com \
  --project="${PROJECT_ID}"
gcloud services enable cloudresourcemanager.googleapis.com \
  --project="${PROJECT_ID}"
gcloud services enable sts.googleapis.com \
  --project="${PROJECT_ID}"

echo "✅ APIs enabled"
echo ""

# Create service account for GitHub Actions
echo "👤 Creating service account for GitHub Actions..."
if gcloud iam service-accounts describe "${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${PROJECT_ID}" &>/dev/null; then
  echo "⚠️  Service account already exists, skipping creation"
else
  gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
    --display-name="GitHub Actions Deployer" \
    --description="Service account for GitHub Actions to deploy to GCP" \
    --project="${PROJECT_ID}"
  echo "✅ Service account created"
fi
echo ""

# Grant necessary permissions to service account
echo "🔐 Granting permissions to service account..."
ROLES=(
  "roles/run.admin"
  "roles/storage.admin"
  "roles/artifactregistry.admin"
  "roles/iam.serviceAccountUser"
  "roles/cloudsql.client"
  "roles/secretmanager.admin"
  "roles/compute.networkUser"
)

for ROLE in "${ROLES[@]}"; do
  echo "  Adding role: $ROLE"
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="${ROLE}" \
    --condition=None \
    --quiet
done
echo "✅ Permissions granted"
echo ""

# Create Workload Identity Pool
echo "🌊 Creating Workload Identity Pool..."
if gcloud iam workload-identity-pools describe "${WORKLOAD_IDENTITY_POOL}" \
  --location="global" \
  --project="${PROJECT_ID}" &>/dev/null; then
  echo "⚠️  Workload Identity Pool already exists, skipping creation"
else
  gcloud iam workload-identity-pools create "${WORKLOAD_IDENTITY_POOL}" \
    --location="global" \
    --display-name="GitHub Actions Pool" \
    --description="Workload Identity Pool for GitHub Actions" \
    --project="${PROJECT_ID}"
  echo "✅ Workload Identity Pool created"
fi
echo ""

# Create Workload Identity Provider
echo "🔌 Creating Workload Identity Provider..."
if gcloud iam workload-identity-pools providers describe "${WORKLOAD_IDENTITY_PROVIDER}" \
  --workload-identity-pool="${WORKLOAD_IDENTITY_POOL}" \
  --location="global" \
  --project="${PROJECT_ID}" &>/dev/null; then
  echo "⚠️  Workload Identity Provider already exists, skipping creation"
else
  gcloud iam workload-identity-pools providers create-oidc "${WORKLOAD_IDENTITY_PROVIDER}" \
    --workload-identity-pool="${WORKLOAD_IDENTITY_POOL}" \
    --location="global" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
    --attribute-condition="assertion.repository_owner == '${GITHUB_REPO%%/*}'" \
    --project="${PROJECT_ID}"
  echo "✅ Workload Identity Provider created"
fi
echo ""

# Allow GitHub Actions to impersonate the service account
echo "🔗 Binding service account to Workload Identity..."
gcloud iam service-accounts add-iam-policy-binding \
  "${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')/locations/global/workloadIdentityPools/${WORKLOAD_IDENTITY_POOL}/attribute.repository/${GITHUB_REPO}" \
  --project="${PROJECT_ID}"
echo "✅ Service account bound to Workload Identity"
echo ""

# Get the Workload Identity Provider resource name
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')
WORKLOAD_IDENTITY_PROVIDER_FULL="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WORKLOAD_IDENTITY_POOL}/providers/${WORKLOAD_IDENTITY_PROVIDER}"

echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "📋 Add these secrets to your GitHub repository:"
echo ""
echo "Secret Name: GCP_WORKLOAD_IDENTITY_PROVIDER"
echo "Secret Value:"
echo "${WORKLOAD_IDENTITY_PROVIDER_FULL}"
echo ""
echo "Secret Name: GCP_SERVICE_ACCOUNT_EMAIL"
echo "Secret Value:"
echo "${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
echo ""
echo "Secret Name: GCP_PROJECT_ID"
echo "Secret Value:"
echo "${PROJECT_ID}"
echo ""
echo "🔗 Add secrets at: https://github.com/${GITHUB_REPO}/settings/secrets/actions"
echo ""

