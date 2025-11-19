# Deployment Scripts

This directory contains scripts to help you set up and deploy the Billing Consumer Service to GCP.

## 🚀 Quick Start

Run all setup steps in one command:

```bash
chmod +x scripts/*.sh
./scripts/quick-deploy.sh
```

## 📋 Individual Scripts

### 1. `setup-gcp-infrastructure.sh`

Sets up the core GCP infrastructure:
- Enables required APIs
- Creates Artifact Registry
- Creates Terraform state bucket
- Configures Secret Manager

**Usage:**
```bash
./scripts/setup-gcp-infrastructure.sh
```

### 2. `setup-workload-identity.sh`

Configures Workload Identity Federation for secure GitHub Actions authentication:
- Creates Workload Identity Pool
- Creates OIDC Provider
- Creates service account
- Grants necessary permissions

**Usage:**
```bash
./scripts/setup-workload-identity.sh
```

### 3. `quick-deploy.sh`

Runs both setup scripts in sequence and provides next steps.

**Usage:**
```bash
./scripts/quick-deploy.sh
```

## 📝 Prerequisites

Before running these scripts:

1. Install `gcloud` CLI
2. Authenticate: `gcloud auth login`
3. Set project: `gcloud config set project hybrid-dolphin-478706-q8`
4. Have necessary GCP permissions (Owner or Editor role)

## 🔐 GitHub Secrets

After running the scripts, add these secrets to your GitHub repository:

### From `setup-workload-identity.sh`:
- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`
- `GCP_PROJECT_ID`

### From `setup-gcp-infrastructure.sh`:
- `GCP_TERRAFORM_STATE_BUCKET`

### Existing Application Secrets:
- `ENCRYPTION_SECRET`
- `SONAR_TOKEN`
- `SONAR_HOST_URL`
- `SNYK_TOKEN`

## 📚 Documentation

For detailed deployment instructions, see: [DEPLOYMENT-GUIDE.md](../DEPLOYMENT-GUIDE.md)

