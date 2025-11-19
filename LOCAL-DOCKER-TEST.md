# 🐳 Local Docker Testing Guide

Before deploying to GCP, you can test the Docker container locally to ensure everything works.

---

## Prerequisites

- Docker installed
- Maven installed
- Local access to Cloud SQL (or H2 for testing)

---

## Option 1: Test with H2 Database (Quickest)

### Step 1: Build the Docker Image

```bash
cd /Users/az/Documents/billing-consumer-service

# Build the image
docker build -t billing-consumer-service:local .
```

**Expected:** Build completes in 3-5 minutes

---

### Step 2: Run the Container (H2 Mode)

```bash
docker run -p 8080:8080 \
  -e ENCRYPTION_SECRET="India@JAN@2026_salt_to_make_it_32chars" \
  -e BILLING_DB_URL="jdbc:h2:mem:billingdb;MODE=LEGACY;DB_CLOSE_DELAY=-1" \
  -e BILLING_DB_DRIVER="org.h2.Driver" \
  -e BILLING_DB_USERNAME="sa" \
  -e BILLING_DB_PASSWORD="" \
  billing-consumer-service:local
```

---

### Step 3: Test the Application

```bash
# Health check
curl http://localhost:8080/actuator/health

# Create a consumer
curl -X POST http://localhost:8080/api/billing-consumers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Docker Test User",
    "email": "docker@example.com",
    "phone": "+9876543210",
    "address": "123 Docker Street"
  }'

# Get all consumers
curl http://localhost:8080/api/billing-consumers
```

---

## Option 2: Test with Cloud SQL (Realistic)

### Step 1: Build the Docker Image

```bash
docker build -t billing-consumer-service:local .
```

---

### Step 2: Run with Cloud SQL Connection

```bash
docker run -p 8080:8080 \
  -e ENCRYPTION_SECRET="India@JAN@2026_salt_to_make_it_32chars" \
  -e BILLING_DB_URL="jdbc:mysql://34.100.183.117:3306/billing_consumer" \
  -e BILLING_DB_DRIVER="com.mysql.cj.jdbc.Driver" \
  -e BILLING_DB_USERNAME="billing_consumer_app" \
  -e BILLING_DB_PASSWORD="India@JAN@2026" \
  billing-consumer-service:local
```

**Note:** This requires Cloud SQL to allow connections from your local IP.

---

## Option 3: Test with Docker Compose (Advanced)

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - ENCRYPTION_SECRET=India@JAN@2026_salt_to_make_it_32chars
      - BILLING_DB_URL=jdbc:h2:mem:billingdb;MODE=LEGACY;DB_CLOSE_DELAY=-1
      - BILLING_DB_DRIVER=org.h2.Driver
      - BILLING_DB_USERNAME=sa
      - BILLING_DB_PASSWORD=
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 40s
```

Then run:

```bash
docker-compose up
```

---

## 🔍 Troubleshooting

### Build Fails

**Error:** `mvn: not found`

**Solution:** Maven is run inside the container, not locally. Ensure Docker has internet access to download dependencies.

---

### Container Exits Immediately

**Check logs:**
```bash
docker logs $(docker ps -lq)
```

**Common causes:**
- Missing required environment variable
- Database connection failed
- Port already in use

---

### Connection Refused

**Check if container is running:**
```bash
docker ps
```

**Check container logs:**
```bash
docker logs <container-id>
```

---

## 🧹 Cleanup

```bash
# Stop all containers
docker stop $(docker ps -q)

# Remove containers
docker rm $(docker ps -aq)

# Remove image
docker rmi billing-consumer-service:local

# Remove all unused images
docker image prune -a
```

---

## ✅ Success Indicators

- [ ] Image builds without errors
- [ ] Container starts successfully
- [ ] Health endpoint returns `{"status":"UP"}`
- [ ] Can create billing consumer via API
- [ ] Can retrieve billing consumers via API
- [ ] Logs show successful database connection
- [ ] No error messages in logs

---

## 📊 Image Size Optimization

Check your image size:

```bash
docker images | grep billing-consumer-service
```

**Expected size:** 350-450 MB

**Tips to reduce size:**
- Multi-stage build (already implemented)
- Use Alpine base images (already implemented)
- Minimize dependencies in pom.xml

---

## 🚀 Ready for GCP?

Once local Docker testing passes, you're ready to deploy to GCP Cloud Run!

Follow: `QUICK-DEPLOY-REFERENCE.md` or `DEPLOYMENT-ACTION-PLAN.md`

---

**Pro Tip:** Local Docker testing catches 90% of deployment issues before they reach GCP!

