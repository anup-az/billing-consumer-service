# ⚡ Quick Deploy Reference

**Goal:** Deploy billing-consumer-service to GCP Cloud Run in ~30 minutes

---

## 🎯 Three Simple Steps

### 1️⃣ **Run Setup Scripts** (10 min)

```bash
cd /Users/az/Documents/billing-consumer-service
./scripts/quick-deploy.sh
```

**Copy the 4 secret values displayed at the end!**

---

### 2️⃣ **Add GitHub Secrets** (5 min)

Go to: https://github.com/anup-az/billing-consumer-service/settings/secrets/actions

Add these 4 new secrets:
- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`
- `GCP_PROJECT_ID`
- `GCP_TERRAFORM_STATE_BUCKET`

---

### 3️⃣ **Deploy via Git** (15 min)

```bash
# Create feature branch
git checkout dev && git pull
git checkout -b feature/gcp-deployment

# Commit deployment config
git add .
git commit -m "feat: Add GCP Cloud Run deployment infrastructure"
git push -u origin feature/gcp-deployment

# Then on GitHub:
# 1. Create PR
# 2. Wait for quality gates
# 3. Merge to 'dev'
# 4. Watch automated deployment! 🚀
```

---

## ✅ Success Indicators

- [ ] Scripts complete without errors
- [ ] 8 total GitHub Secrets configured
- [ ] PR quality gates all pass (green checkmarks)
- [ ] Deployment workflow completes successfully
- [ ] Service URL is displayed in GitHub Actions
- [ ] `curl <SERVICE_URL>/actuator/health` returns `{"status":"UP"}`

---

## 📞 Need Help?

- **Detailed Guide:** `DEPLOYMENT-ACTION-PLAN.md` (step-by-step)
- **Full Docs:** `DEPLOYMENT-GUIDE.md` (comprehensive)
- **Troubleshooting:** Check GitHub Actions logs or Cloud Run logs

---

## 🎉 That's It!

After merge, future deployments are automatic:
**Code change → PR → Merge → Auto-deploy!**

---

**Time Investment:**
- Setup: 10 min (one-time)
- GitHub config: 5 min (one-time)
- First deploy: 15 min
- **Future deploys: ~7 min (automatic!)**

