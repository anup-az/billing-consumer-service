# Deployment Guide: GCP Cloud Run with Terraform

This guide will walk you through deploying the Billing Consumer Service to Google Cloud Platform using:
- **Terraform** for infrastructure as code
- **GitHub Actions** for CI/CD
- **Workload Identity Federation** for secure authentication
- **Cloud Run** (Gen2) for serverless deployment
- **GCP Secret Manager** for secrets management

---

## 📋 Prerequisites

Before starting, ensure you have:

1. ✅ **GCP Account** with billing enabled
2. ✅ **Project ID**: `hybrid-dolphin-478706-q8`
3. ✅ **GitHub Repository**: `anup-az/billing-consumer-service`
4. ✅ **Local tools installed**:
   - `gcloud` CLI ([Install](https://cloud.google.com/sdk/docs/install))
   - `terraform` ([Install](https://developer.hashicorp.com/terraform/downloads))
   - `git`

5. ✅ **Cloud SQL instance** already configured:
   - Instance: `lc-billing-app`
   - Database: `billing_consumer`
   - User: `billing_consumer_app`
   - Connection: `hybrid-dolphin-478706-q8:asia-south1:lc-billing-app`

---

## 🚀 Step-by-Step Deployment

### **Step 1: Authenticate to GCP**

```bash
# Login to GCP
gcloud auth login

# Set your project
gcloud config set project hybrid-dolphin-478706-q8

# Verify your configuration
gcloud config list
```

---

### **Step 2: Run Infrastructure Setup Script**

This script will:
- Enable required GCP APIs
- Create Artifact Registry for Docker images
- Create Terraform state bucket
- Set up Secret Manager secrets

```bash
cd /Users/az/Documents/billing-consumer-service

# Make script executable
chmod +x scripts/setup-gcp-infrastructure.sh

# Run the setup
./scripts/setup-gcp-infrastructure.sh
```

**Expected Output:**
```
✅ Infrastructure Setup Complete!
Terraform state bucket: gs://hybrid-dolphin-478706-q8-terraform-state
Artifact Registry: asia-south1-docker.pkg.dev/hybrid-dolphin-478706-q8/billing-consumer-repo
```

---

### **Step 3: Configure Workload Identity Federation**

This sets up secure authentication between GitHub Actions and GCP (no service account keys needed!)

```bash
# Make script executable
chmod +x scripts/setup-workload-identity.sh

# Run the setup
./scripts/setup-workload-identity.sh
```

**Expected Output:**
The script will output 3 values to add as GitHub Secrets:
- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`
- `GCP_PROJECT_ID`

**Copy these values!** You'll need them in the next step.

---

### **Step 4: Add GitHub Secrets**

Go to: https://github.com/anup-az/billing-consumer-service/settings/secrets/actions

Click **"New repository secret"** and add each of these:

#### **From Workload Identity Setup:**
1. **Name:** `GCP_WORKLOAD_IDENTITY_PROVIDER`
   **Value:** `projects/123456789/locations/global/workloadIdentityPools/github-actions-pool/providers/github-actions-provider`
   *(Use the value from script output)*

2. **Name:** `GCP_SERVICE_ACCOUNT_EMAIL`
   **Value:** `github-actions-deployer@hybrid-dolphin-478706-q8.iam.gserviceaccount.com`

3. **Name:** `GCP_PROJECT_ID`
   **Value:** `hybrid-dolphin-478706-q8`

4. **Name:** `GCP_TERRAFORM_STATE_BUCKET`
   **Value:** `hybrid-dolphin-478706-q8-terraform-state`

#### **Application Secrets (Already Added):**
5. **Name:** `ENCRYPTION_SECRET`
   **Value:** `India@JAN@2026_salt_to_make_it_32chars`

6. **Name:** `SONAR_TOKEN` *(Already configured)*

7. **Name:** `SONAR_HOST_URL` *(Already configured)*

8. **Name:** `SNYK_TOKEN` *(Already configured)*

---

### **Step 5: Create a Feature Branch and Push**

Now let's create a branch with the deployment configuration:

```bash
cd /Users/az/Documents/billing-consumer-service

# Create a new branch for deployment setup
git checkout dev
git pull origin dev
git checkout -b feature/deployment-setup

# Stage all new files
git add .

# Commit the changes
git commit -m "feat: Add GCP Cloud Run deployment with Terraform

- Add Terraform configuration for Cloud Run deployment
- Add Dockerfile for containerization
- Add GitHub Actions workflow for automated deployment
- Add setup scripts for Workload Identity Federation
- Add Cloud SQL Socket Factory for secure DB connections
- Add Spring Boot Actuator for health checks"

# Push to GitHub
git push -u origin feature/deployment-setup
```

---

### **Step 6: Create a Pull Request**

1. Go to: https://github.com/anup-az/billing-consumer-service/pulls
2. Click **"New pull request"**
3. Base: `dev` ← Compare: `feature/deployment-setup`
4. Title: `Add GCP Cloud Run deployment infrastructure`
5. Fill out the PR template checklist
6. Click **"Create pull request"**

Wait for all quality gates to pass, then **merge the PR**.

---

### **Step 7: Deploy to Dev Environment**

Once the PR is merged to `dev`, the deployment will automatically trigger!

**Monitor the deployment:**
1. Go to: https://github.com/anup-az/billing-consumer-service/actions
2. Click on the latest **"Deploy to GCP Dev Environment"** workflow
3. Watch the progress:
   - ✅ Build & Push Docker Image
   - ✅ Deploy with Terraform
   - ✅ Health Check

**Expected Duration:** 5-8 minutes

---

### **Step 8: Verify Deployment**

Once deployment completes:

```bash
# Get the service URL from Terraform output
cd terraform
terraform init -backend-config="bucket=hybrid-dolphin-478706-q8-terraform-state" \
               -backend-config="prefix=billing-consumer/dev"
terraform output service_url
```

**Test the deployed service:**

```bash
# Health check
curl https://YOUR-SERVICE-URL/actuator/health

# Create a billing consumer
curl -X POST https://YOUR-SERVICE-URL/api/billing-consumers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "address": "123 Main St"
  }'

# Get all billing consumers
curl https://YOUR-SERVICE-URL/api/billing-consumers
```

---

## 🔧 Manual Terraform Deployment (Optional)

If you want to deploy manually instead of using GitHub Actions:

```bash
cd terraform

# Initialize Terraform
terraform init \
  -backend-config="bucket=hybrid-dolphin-478706-q8-terraform-state" \
  -backend-config="prefix=billing-consumer/dev"

# Plan the deployment
terraform plan \
  -var="project_id=hybrid-dolphin-478706-q8" \
  -var="region=asia-south1" \
  -var="environment=dev" \
  -var="image_tag=latest"

# Apply the configuration
terraform apply \
  -var="project_id=hybrid-dolphin-478706-q8" \
  -var="region=asia-south1" \
  -var="environment=dev" \
  -var="image_tag=latest"
```

---

## 🔍 Troubleshooting

### **Error: "Permission denied" when pushing Docker image**

**Solution:** Ensure the service account has `roles/artifactregistry.admin`

```bash
gcloud projects add-iam-policy-binding hybrid-dolphin-478706-q8 \
  --member="serviceAccount:github-actions-deployer@hybrid-dolphin-478706-q8.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.admin"
```

### **Error: "Cloud SQL connection failed"**

**Solution:** Ensure the Cloud Run service account has Cloud SQL Client role

```bash
gcloud projects add-iam-policy-binding hybrid-dolphin-478706-q8 \
  --member="serviceAccount:billing-consumer-fn-sa@hybrid-dolphin-478706-q8.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"
```

### **Error: "Secret not found"**

**Solution:** Manually create the secret:

```bash
# Encryption secret
echo -n "India@JAN@2026_salt_to_make_it_32chars" | \
  gcloud secrets create billing-consumer-encryption-secret \
  --data-file=- \
  --replication-policy="automatic"

# Database password
echo -n "India@JAN@2026" | \
  gcloud secrets create billing-consumer-db-password \
  --data-file=- \
  --replication-policy="automatic"
```

### **Error: "Terraform state locked"**

**Solution:** Force unlock (only if you're sure no other process is running)

```bash
cd terraform
terraform force-unlock <LOCK_ID>
```

---

## 📊 Monitoring & Logs

### **View Application Logs**

```bash
# Stream logs from Cloud Run
gcloud run services logs read billing-consumer-service-dev \
  --region=asia-south1 \
  --limit=50 \
  --format=json

# Or use Cloud Console
# https://console.cloud.google.com/run
```

### **View Metrics**

```bash
# Open Cloud Run metrics dashboard
gcloud run services describe billing-consumer-service-dev \
  --region=asia-south1 \
  --platform=managed
```

---

## 🔄 Updating the Deployment

To update the application:

1. Make your code changes
2. Commit and push to a feature branch
3. Create a PR to `dev`
4. Once merged, deployment automatically triggers
5. GitHub Actions builds a new image and deploys via Terraform

---

## 🧹 Cleanup (Destroy Resources)

To remove all deployed resources:

```bash
cd terraform

terraform destroy \
  -var="project_id=hybrid-dolphin-478706-q8" \
  -var="region=asia-south1" \
  -var="environment=dev"
```

---

## 📚 Additional Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Cloud SQL Socket Factory](https://github.com/GoogleCloudPlatform/cloud-sql-jdbc-socket-factory)

---

## 🎉 Success Criteria

Your deployment is successful when:

- ✅ Docker image is pushed to Artifact Registry
- ✅ Cloud Run service is deployed
- ✅ Health check endpoint returns `{"status":"UP"}`
- ✅ CRUD operations work via API
- ✅ Database connections are successful
- ✅ Secrets are loaded from Secret Manager
- ✅ All quality gates pass in CI/CD

---

**Need Help?** Check the logs in GitHub Actions or Cloud Run for detailed error messages.

