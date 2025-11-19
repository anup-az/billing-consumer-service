# 🚀 Complete Setup Guide: PR → Quality Gates → Dev Deployment

This guide walks you through the complete workflow from creating a feature branch to deploying on GCP via GitHub Actions.

---

## 📋 Prerequisites

### 1. GitHub Repository Setup
- Repository created: `billing-consumer-service`
- Branch protection rules configured for `dev` and `main`

### 2. Required Accounts & Tools
- **SonarCloud Account** (free for public repos): https://sonarcloud.io
- **Snyk Account** (free tier): https://snyk.io
- **GitGuardian Account** (optional, free tier): https://gitguardian.com
- **GCP Project** with billing enabled
- **gcloud CLI** installed and authenticated

---

## 🔧 One-Time Setup (30 minutes)

### Step 1: SonarCloud Setup

1. **Create SonarCloud Organization**
   - Go to https://sonarcloud.io
   - Sign in with GitHub
   - Click "+" → "Analyze new project"
   - Import `billing-consumer-service`

2. **Generate SonarCloud Token**
   - Profile → My Account → Security → Generate Token
   - Name: `GitHub Actions`
   - Copy the token (you'll need it for GitHub Secrets)

3. **Configure Quality Gate**
   - Project → Administration → Quality Gate
   - Select "Sonar way" (default) or create custom rules
   - Recommended thresholds:
     - Coverage: ≥80%
     - Duplications: ≤3%
     - Maintainability Rating: ≥A
     - Reliability Rating: ≥A
     - Security Rating: ≥A

### Step 2: Snyk Setup

1. **Connect GitHub**
   - Go to https://app.snyk.io
   - Integrations → GitHub → Connect
   - Select `billing-consumer-service`

2. **Generate API Token**
   - Account Settings → General → API Token
   - Copy token for GitHub Secrets

### Step 3: GitGuardian Setup (Optional but Recommended)

1. **Create Account**: https://dashboard.gitguardian.com
2. **Generate API Key**: Settings → API Keys → Create
3. **Configure Monitoring**: Add repository for continuous monitoring

### Step 4: GitHub Secrets Configuration

Go to your repo → **Settings → Secrets and variables → Actions → New repository secret**

Add these secrets:

```
ENCRYPTION_SECRET          = "India@JAN@2026_salt_to_make_it_32chars"
SONAR_TOKEN               = <token from SonarCloud>
SONAR_HOST_URL            = https://sonarcloud.io
SNYK_TOKEN                = <token from Snyk>
GITGUARDIAN_API_KEY       = <token from GitGuardian> (optional)
GCP_PROJECT_ID            = hybrid-dolphin-478706-q8
GCP_SA_KEY                = <service account JSON> (for deployment)
BILLING_DB_URL_DEV        = jdbc:mysql://34.100.183.117:3306/billing_consumer
BILLING_DB_USERNAME_DEV   = billing_consumer_app
BILLING_DB_PASSWORD_DEV   = India@JAN@2026
```

### Step 5: Branch Protection Rules

Go to **Settings → Branches → Add branch protection rule**

**For `dev` branch:**
- ☑ Require a pull request before merging
- ☑ Require approvals: 1
- ☑ Dismiss stale pull request approvals when new commits are pushed
- ☑ Require status checks to pass before merging
  - Select: `Security & Secret Scanning`
  - Select: `SonarQube Analysis`
  - Select: `Dependency Vulnerability Check`
  - Select: `Build & Test Validation`
- ☑ Require conversation resolution before merging
- ☑ Do not allow bypassing the above settings

---

## 🔄 Daily Workflow (PR → Dev Deployment)

### Phase 1: Create Feature Branch

```bash
cd /Users/az/Documents/billing-consumer-service

# Make sure you're on dev and it's up to date
git checkout dev
git pull origin dev

# Create feature branch
git checkout -b ALCBD-001

# Verify you're on the new branch
git branch
```

### Phase 2: Make Your Changes

Example: Add a new endpoint for updating consumers

```bash
# Make code changes in your IDE
# Add files
git add .

# Check what's staged
git status

# Commit with descriptive message
git commit -m "feat(ALCBD-001): Add update endpoint for billing consumers

- Added PUT /api/billing-consumers/{id} endpoint
- Implemented BillingConsumerService.updateConsumer method
- Added validation for update requests
- Updated tests for new functionality"
```

### Phase 3: Push to GitHub

```bash
# Push your branch to GitHub
git push origin ALCBD-001
```

### Phase 4: Create Pull Request

1. **Go to GitHub Repository**
   - You'll see a banner: "ALCBD-001 had recent pushes"
   - Click **"Compare & pull request"**

2. **Fill PR Template**
   - Base: `dev` ← Compare: `ALCBD-001`
   - Title: `feat(ALCBD-001): Add update endpoint for billing consumers`
   - Fill out the template sections:
     - What does this PR do?
     - Why is this change needed?
     - Related Issue(s)
     - Testing approach
   - Add reviewers
   - Click **"Create pull request"**

### Phase 5: Automated Quality Gates Run

**GitHub Actions automatically triggers:**

✅ **Job 1: Security & Secret Scanning** (3-5 min)
- TruffleHog scans for secrets in commits
- GitGuardian checks for exposed credentials
- Trivy scans for vulnerabilities in dependencies

✅ **Job 2: SonarQube Analysis** (5-7 min)
- Static code analysis
- Code smell detection
- Security hotspot identification
- Test coverage measurement
- Quality gate evaluation

✅ **Job 3: Dependency Check** (2-3 min)
- Snyk scans Maven dependencies
- Checks for known CVEs
- Suggests remediation paths

✅ **Job 4: Build & Test Validation** (3-4 min)
- Compiles code with Maven
- Runs unit tests
- Publishes test reports

### Phase 6: Review Results & Fix Issues

**If Quality Gates Fail:**

1. **Check GitHub Actions Tab**
   - Click on the failed job
   - Read error logs

2. **Common Issues & Fixes:**

   **SonarQube Failures:**
   ```bash
   # Fix code smells locally
   # Re-commit
   git add .
   git commit -m "fix: Address SonarQube code smells"
   git push origin ALCBD-001
   # Quality gates re-run automatically
   ```

   **Secret Detected:**
   ```bash
   # Remove secret from code
   # Add to .gitignore if it's a file
   echo "config/datasource-secrets.yml" >> .gitignore
   
   # If secret was committed, rewrite history
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch path/to/secret" \
     --prune-empty --tag-name-filter cat -- --all
   
   git push origin ALCBD-001 --force
   ```

   **Dependency Vulnerability:**
   ```bash
   # Update vulnerable dependency in pom.xml
   # Check Snyk output for suggested version
   mvn versions:use-latest-versions
   git add pom.xml
   git commit -m "fix: Update vulnerable dependencies"
   git push origin ALCBD-001
   ```

3. **View SonarQube Dashboard**
   - Go to https://sonarcloud.io
   - Find your project
   - Review detailed issues, coverage, duplications

### Phase 7: Code Review

1. **Reviewer Actions:**
   - Review code changes
   - Leave comments/suggestions
   - Request changes if needed
   - Approve if satisfied

2. **Author Actions:**
   - Address review comments
   - Make requested changes
   - Re-request review

### Phase 8: Merge to Dev

**Once All Checks Pass:**

1. **Resolve Conflicts** (if any)
   ```bash
   git checkout ALCBD-001
   git fetch origin
   git merge origin/dev
   # Fix conflicts
   git add .
   git commit -m "chore: Resolve merge conflicts"
   git push origin ALCBD-001
   ```

2. **Merge PR**
   - Click **"Squash and merge"** or **"Merge pull request"**
   - Confirm merge
   - Delete branch (optional but recommended)

### Phase 9: GitHub Actions Deploy to Dev

**Automatically Triggered on Merge:**

The `.github/workflows/dev.yml` runs:

```yaml
1. Build Spring Boot Application
   - Maven clean verify
   - Runs tests with H2 database

2. Create Docker Image
   - Build container
   - Tag with commit SHA

3. Push to Artifact Registry
   - Authenticate to GCP
   - Push image

4. Trigger Terraform Deployment
   - Terraform plan
   - Terraform apply (dev workspace)
   - Deploy to Cloud Functions/Cloud Run
```

**Monitor Deployment:**
- Go to **Actions** tab
- Click on the running workflow
- Watch real-time logs

**Verify Deployment:**
```bash
# Get Cloud Function URL from Terraform outputs
gcloud functions describe billing-consumer-service \
  --region=asia-south1 \
  --format="value(serviceConfig.uri)"

# Test endpoint
curl -X POST <FUNCTION_URL>/api/billing-consumers \
  -H "Content-Type: application/json" \
  -d '{"userName":"test","password":"test123",...}'
```

---

## 🛠️ Local Testing Before PR

**Always test locally first:**

```bash
# 1. Run unit tests
mvn clean test

# 2. Run SonarQube locally (optional)
mvn sonar:sonar \
  -Dsonar.token=<YOUR_TOKEN> \
  -Dsonar.host.url=https://sonarcloud.io

# 3. Check for secrets
docker run --rm -v "$PWD:/path" trufflesecurity/trufflehog:latest \
  filesystem /path --only-verified

# 4. Build application
mvn clean package

# 5. Run locally
export ENCRYPTION_SECRET="..."
mvn spring-boot:run
```

---

## 📊 Monitoring & Observability

### SonarCloud Dashboard
- **URL:** https://sonarcloud.io/dashboard?id=summithc_billing-consumer-service
- **Metrics to Watch:**
  - Code Coverage %
  - Technical Debt Ratio
  - Security Vulnerabilities
  - Code Smells

### GitHub Security
- **Dependabot Alerts:** Repo → Security → Dependabot
- **Secret Scanning:** Repo → Security → Secret scanning
- **Code Scanning:** Repo → Security → Code scanning

### GCP Monitoring
```bash
# View Cloud Function logs
gcloud functions logs read billing-consumer-service \
  --region=asia-south1 \
  --limit=50

# View metrics
gcloud monitoring dashboards list
```

---

## 🔒 Security Best Practices

### Never Commit These:
- `config/datasource-secrets.yml` ✅ Already in .gitignore
- `.env` files ✅ Already in .gitignore
- API keys, tokens, passwords
- Service account JSON files

### Use Secrets Manager:
```bash
# Store secret in GCP Secret Manager
echo -n "India@JAN@2026" | gcloud secrets create encryption-secret \
  --data-file=- \
  --replication-policy=automatic

# Grant access to Cloud Function service account
gcloud secrets add-iam-policy-binding encryption-secret \
  --member="serviceAccount:PROJECT_ID@appspot.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

---

## 🐛 Troubleshooting

### GitHub Actions Fails with "ENCRYPTION_SECRET not set"
**Solution:** Add secret to GitHub repo settings

### SonarQube Quality Gate Fails
**Solution:** Check https://sonarcloud.io for specific issues

### Trivy Finds Vulnerabilities
**Solution:** Update dependencies or add to `.trivyignore` with justification

### Merge Blocked by Branch Protection
**Solution:** All status checks must pass; fix failing jobs

### Cloud Function Deployment Fails
**Solution:** Check Terraform logs in GitHub Actions; verify GCP quotas

---

## 📚 Additional Resources

- [SonarQube Rules](https://rules.sonarsource.com/java/)
- [Snyk Vulnerability Database](https://security.snyk.io/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Spring Boot Best Practices](https://docs.spring.io/spring-boot/reference/)

---

## ✅ Checklist: First PR Setup

- [ ] SonarCloud project created
- [ ] Snyk integrated
- [ ] GitHub Secrets configured
- [ ] Branch protection rules enabled
- [ ] PR template committed
- [ ] Workflow files committed
- [ ] Local build passes (`mvn clean verify`)
- [ ] Feature branch created (ALCBD-001)
- [ ] Changes committed
- [ ] PR raised
- [ ] Quality gates passed
- [ ] Code reviewed
- [ ] Merged to dev
- [ ] Deployment successful

---

**Need Help?** Check GitHub Actions logs or SonarCloud dashboard for detailed error messages.

