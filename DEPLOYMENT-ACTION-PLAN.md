# 🚀 Deployment Action Plan

## Overview

This document provides a **step-by-step checklist** to deploy the Billing Consumer Service to Google Cloud Platform using Terraform and GitHub Actions.

**Total Time Required:** ~30-45 minutes

---

## ✅ Pre-Deployment Checklist

Before starting, verify you have:

- [ ] GCP Project: `hybrid-dolphin-478706-q8`
- [ ] GitHub Repository: `anup-az/billing-consumer-service`
- [ ] `gcloud` CLI installed and authenticated
- [ ] Cloud SQL instance running: `lc-billing-app`
- [ ] GitHub account with admin access to the repository
- [ ] Merged PR with CI/CD quality gates passing

---

## 📋 Deployment Steps

### **Phase 1: Local Setup (10 minutes)**

#### Step 1.1: Authenticate to GCP
```bash
# Login to GCP
gcloud auth login

# Set your project
gcloud config set project hybrid-dolphin-478706-q8

# Verify authentication
gcloud config list
```

**✅ Success Criteria:** You see your project ID and account email

---

#### Step 1.2: Run GCP Infrastructure Setup
```bash
cd /Users/az/Documents/billing-consumer-service

# Make scripts executable (already done, but just to be safe)
chmod +x scripts/*.sh

# Run infrastructure setup
./scripts/setup-gcp-infrastructure.sh
```

**What this does:**
- Enables 9 required GCP APIs
- Creates Artifact Registry repository
- Creates Terraform state bucket
- Creates Secret Manager secrets

**✅ Success Criteria:** 
```
✅ Infrastructure Setup Complete!
Terraform state bucket: gs://hybrid-dolphin-478706-q8-terraform-state
```

**⏱️ Duration:** 3-5 minutes

---

#### Step 1.3: Configure Workload Identity Federation
```bash
# Run Workload Identity setup
./scripts/setup-workload-identity.sh
```

**What this does:**
- Creates Workload Identity Pool
- Creates OIDC Provider for GitHub
- Creates service account `github-actions-deployer`
- Grants necessary IAM roles

**✅ Success Criteria:**
```
✅ Setup Complete!
📋 Add these secrets to your GitHub repository:

Secret Name: GCP_WORKLOAD_IDENTITY_PROVIDER
Secret Value: projects/123456789/locations/global/...

Secret Name: GCP_SERVICE_ACCOUNT_EMAIL
Secret Value: github-actions-deployer@...
```

**⚠️ IMPORTANT:** Copy these 3 values! You'll need them in the next phase.

**⏱️ Duration:** 2-3 minutes

---

### **Phase 2: GitHub Configuration (5 minutes)**

#### Step 2.1: Add GitHub Secrets

Go to: https://github.com/anup-az/billing-consumer-service/settings/secrets/actions

Click **"New repository secret"** for each:

| Secret Name | Value | Source |
|------------|-------|--------|
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | `projects/.../workloadIdentityPools/...` | Script output |
| `GCP_SERVICE_ACCOUNT_EMAIL` | `github-actions-deployer@...` | Script output |
| `GCP_PROJECT_ID` | `hybrid-dolphin-478706-q8` | Your project |
| `GCP_TERRAFORM_STATE_BUCKET` | `hybrid-dolphin-478706-q8-terraform-state` | Script output |

**Existing Secrets (verify these exist):**
- [x] `ENCRYPTION_SECRET`
- [x] `SONAR_TOKEN`
- [x] `SONAR_HOST_URL`
- [x] `SNYK_TOKEN`

**✅ Success Criteria:** 8 total secrets in GitHub

---

### **Phase 3: Deploy Configuration to GitHub (5 minutes)**

#### Step 3.1: Create Feature Branch
```bash
cd /Users/az/Documents/billing-consumer-service

# Ensure you're on latest dev
git checkout dev
git pull origin dev

# Create deployment feature branch
git checkout -b feature/gcp-deployment
```

---

#### Step 3.2: Stage and Commit Changes
```bash
# Check what's new
git status

# Add all deployment files
git add \
  Dockerfile \
  .dockerignore \
  .gitignore \
  pom.xml \
  terraform/ \
  scripts/ \
  .github/workflows/deploy-dev.yml \
  DEPLOYMENT-GUIDE.md \
  DEPLOYMENT-ACTION-PLAN.md

# Commit with descriptive message
git commit -m "feat: Add GCP Cloud Run deployment infrastructure

- Add Terraform configuration for Cloud Run (Gen2)
- Add Dockerfile with multi-stage build for optimal image size
- Add GitHub Actions workflow for automated deployment
- Add Workload Identity Federation for secure GCP auth
- Add Cloud SQL Socket Factory for managed database connections
- Add Spring Boot Actuator for health monitoring
- Add deployment scripts and comprehensive documentation

This enables:
- Automated CI/CD pipeline from dev branch to GCP
- Infrastructure as Code via Terraform
- Secure secret management via GCP Secret Manager
- Serverless deployment with auto-scaling
- Zero-downtime deployments"
```

---

#### Step 3.3: Push to GitHub
```bash
git push -u origin feature/gcp-deployment
```

**✅ Success Criteria:**
```
remote: Create a pull request for 'feature/gcp-deployment' on GitHub by visiting:
remote:   https://github.com/anup-az/billing-consumer-service/pull/new/feature/gcp-deployment
```

---

### **Phase 4: Pull Request & Merge (10 minutes)**

#### Step 4.1: Create Pull Request

1. Go to: https://github.com/anup-az/billing-consumer-service/pulls
2. Click **"New pull request"**
3. Base: `dev` ← Compare: `feature/gcp-deployment`
4. Title: `Add GCP Cloud Run deployment infrastructure`
5. Description:
   ```
   ## Summary
   This PR adds complete deployment infrastructure for GCP Cloud Run.

   ## Changes
   - ✅ Terraform configuration for Cloud Run service
   - ✅ Dockerfile for containerization
   - ✅ GitHub Actions deployment workflow
   - ✅ Workload Identity Federation setup
   - ✅ Cloud SQL integration
   - ✅ Secret Manager integration
   - ✅ Comprehensive documentation

   ## Testing
   - [ ] Local Docker build tested
   - [ ] Terraform plan validated
   - [ ] GCP infrastructure created
   - [ ] All GitHub Secrets configured

   ## Deployment
   After merge, deployment to dev will automatically trigger.
   ```
6. Check all applicable items in PR template
7. Click **"Create pull request"**

---

#### Step 4.2: Wait for Quality Gates

Monitor these checks:
- ✅ Security & Secret Scanning
- ✅ SonarQube Analysis
- ✅ Dependency Vulnerability Check
- ✅ Build & Test Validation

**⏱️ Duration:** 3-5 minutes

---

#### Step 4.3: Merge Pull Request

Once all checks pass:
1. Click **"Merge pull request"**
2. Click **"Confirm merge"**
3. **Delete branch** `feature/gcp-deployment`

**✅ Success Criteria:** "Pull request successfully merged and closed"

---

### **Phase 5: Automated Deployment (10 minutes)**

#### Step 5.1: Monitor Deployment

1. Go to: https://github.com/anup-az/billing-consumer-service/actions
2. Click on **"Deploy to GCP Dev Environment"** workflow (should be running)
3. Watch the progress:
   - 🔄 **Build & Push Docker Image** (3-4 min)
     - Build JAR
     - Authenticate to GCP
     - Build Docker image
     - Push to Artifact Registry
   - 🔄 **Deploy with Terraform** (5-6 min)
     - Terraform init
     - Terraform plan
     - Terraform apply
     - Health check

**⏱️ Duration:** 8-10 minutes

---

#### Step 5.2: Deployment Success

When complete, the workflow summary will show:

```
### 🚀 Deployment Successful!

**Service URL:** https://billing-consumer-service-dev-abc123-uc.a.run.app
**Image Tag:** dev-1a2b3c4-1700000000
**Environment:** dev
```

**✅ Success Criteria:** All jobs show green checkmarks

---

### **Phase 6: Verification & Testing (5 minutes)**

#### Step 6.1: Test Health Endpoint

```bash
# Replace with your actual service URL from deployment output
SERVICE_URL="https://billing-consumer-service-dev-abc123-uc.a.run.app"

# Test health check
curl $SERVICE_URL/actuator/health

# Expected output:
# {"status":"UP"}
```

---

#### Step 6.2: Test CRUD Operations

```bash
# Create a billing consumer
curl -X POST $SERVICE_URL/api/billing-consumers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "+1234567890",
    "address": "123 Test Street"
  }'

# Get all consumers
curl $SERVICE_URL/api/billing-consumers

# Expected: JSON array with the created consumer
# Note: password and phone fields should be encrypted
```

---

#### Step 6.3: Verify Database Connection

```bash
# Check application logs for successful DB connection
gcloud run services logs read billing-consumer-service-dev \
  --region=asia-south1 \
  --limit=50

# Look for:
# ✅ "HikariPool-1 - Start completed"
# ✅ "Started BillingConsumerApplication"
```

---

#### Step 6.4: Verify Secret Manager Integration

```bash
# List secret versions being used
gcloud secrets versions list billing-consumer-encryption-secret
gcloud secrets versions list billing-consumer-db-password

# Verify Cloud Run has access
gcloud run services describe billing-consumer-service-dev \
  --region=asia-south1 \
  --format="get(spec.template.spec.serviceAccountName)"

# Expected: billing-consumer-fn-sa@hybrid-dolphin-478706-q8.iam.gserviceaccount.com
```

**✅ Success Criteria:** All API calls return expected results

---

## 🎉 Deployment Complete!

### What You've Accomplished:

- ✅ **Infrastructure as Code:** Full Terraform configuration
- ✅ **CI/CD Pipeline:** Automated build, test, and deployment
- ✅ **Secure Authentication:** Workload Identity Federation (no keys!)
- ✅ **Secret Management:** GCP Secret Manager integration
- ✅ **Serverless Deployment:** Cloud Run with auto-scaling
- ✅ **Database Integration:** Cloud SQL with Socket Factory
- ✅ **Monitoring:** Health checks and logging
- ✅ **Quality Gates:** SonarQube, Snyk, security scanning

---

## 🔄 Next Deployments

Future updates are automatic:

1. Create feature branch
2. Make code changes
3. Push and create PR to `dev`
4. Wait for quality gates
5. Merge PR
6. **Automatic deployment triggers!**

---

## 📊 Monitoring & Operations

### View Logs
```bash
gcloud run services logs tail billing-consumer-service-dev --region=asia-south1
```

### View Metrics
https://console.cloud.google.com/run/detail/asia-south1/billing-consumer-service-dev/metrics

### View Service Details
```bash
gcloud run services describe billing-consumer-service-dev \
  --region=asia-south1 \
  --format=yaml
```

### Scale Service
```bash
# Update min/max instances via Terraform
cd terraform
terraform apply -var="min_instances=1" -var="max_instances=20"
```

---

## 🆘 Troubleshooting

### Deployment Failed

1. Check GitHub Actions logs
2. Look for specific error in failed job
3. Common issues:
   - Missing GitHub Secret → Add it
   - GCP permission denied → Run setup scripts again
   - Terraform state locked → Force unlock or wait

### Application Not Starting

1. Check Cloud Run logs:
   ```bash
   gcloud run services logs read billing-consumer-service-dev \
     --region=asia-south1 \
     --limit=100
   ```

2. Common issues:
   - Secret not found → Verify Secret Manager
   - DB connection failed → Check Cloud SQL connection string
   - Port binding error → Verify Dockerfile exposes 8080

### Health Check Failing

1. Test locally:
   ```bash
   docker build -t billing-test .
   docker run -p 8080:8080 \
     -e ENCRYPTION_SECRET="..." \
     -e BILLING_DB_URL="..." \
     billing-test
   ```

2. Check actuator endpoint:
   ```bash
   curl localhost:8080/actuator/health
   ```

---

## 📞 Support

- **Documentation:** See `DEPLOYMENT-GUIDE.md` for detailed instructions
- **Scripts:** See `scripts/README.md` for script usage
- **Logs:** Check GitHub Actions and Cloud Run logs
- **GCP Console:** https://console.cloud.google.com/run

---

**Last Updated:** 2025-11-19
**Version:** 1.0.0

