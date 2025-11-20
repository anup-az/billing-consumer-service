# Billing Consumer Service

Production-ready Spring Boot 3 (Java 21) microservice for managing `BillingConsumer` records with enterprise-grade security and validation.

## Features

- REST APIs for consumer management (POST, GET endpoints)
- AES/GCM field-level encryption for `password`, `medicalHistory`, and `nationalId`
- **3-Level Validation System** (Pre-commit hooks, TruffleHog, SonarQube)
- Database credentials externalized via environment variables and secret management
- Comprehensive GitHub Actions CI/CD with quality gates
- Production-ready code standards enforced automatically

## Tech Stack

- Spring Boot 3.2.x, Java 21
- Spring Data JPA + H2 (swap with managed DB later)
- Lombok for minimal boilerplate

## Quick Start

### 1. Run the Application

```bash
./mvnw spring-boot:run
# or
mvn spring-boot:run
```

### Required secrets / env vars

| Variable | Purpose | Where to store |
| -------- | ------- | -------------- |
| `ENCRYPTION_SECRET` | 32+ char passphrase used for AES key derivation | GitHub Actions secret + AWS Secrets Manager |
| `BILLING_DB_URL` | JDBC URL for the managed billing database (RDS, Aurora, etc.) | GitHub Actions secret + AWS Secrets Manager |
| `BILLING_DB_USERNAME` / `BILLING_DB_PASSWORD` | DB credentials (prod) | GitHub Actions secret + AWS Secrets Manager |

Local developers can `cp config/datasource-secrets.template.yml config/datasource-secrets.yml` and export env vars.

### Sample cURL

```bash
curl -X POST http://localhost:8080/api/billing-consumers \
  -H "Content-Type: application/json" \
  -d '{
    "userName":"alice",
    "password":"S3cure!",
    "medicalHistory":"diabetes type 1",
    "age":32,
    "department":"cardiology",
    "contactEmail":"alice@example.com",
    "insuranceProvider":"PrimeHealth",
    "nationalId":"ABC123456"
  }'

curl http://localhost:8080/api/billing-consumers/1
```

> GET responses surface encrypted strings so sensitive data never leaves the service in plain text. Clients can decrypt with the shared secret if required.

## Design Notes

- **Encryption:** AES/GCM with per-record IV. The key is derived from `ENCRYPTION_SECRET` using SHA-256. Update the key via secret manager rotation without code change.
- **Minimal APIs:** Requirement was 1 POST + 1 GET. Service layer is ready for more CRUD endpoints when needed.
- **Secret Hygiene:** All credentials/secrets loaded via environment variables or the optional `config/datasource-secrets.yml`, keeping scanners (TruffleHog/SonarQube) happy.
- **Next steps (future):**
  - Add GitHub Actions workflow (build/test/scan/deploy).
  - Provision AWS infra via Terraform (App Runner / ECS / RDS).
  - Enable SonarQube + secret scanning actions once repo is live.

## Project Layout

```
src/
 └─ main/java/com/summithc/billing
     ├─ controller
     ├─ dto
     ├─ entity
     ├─ repository
     ├─ service
     └─ crypto
config/
 └─ datasource-secrets.template.yml
```

## Testing

Add unit tests as business rules grow. For now you can validate manually:

```bash
mvn test
```

## Validation (3 Layers)

1. **Cursor IDE** - `.cursorrules` (real-time code suggestions)
2. **Git Commit** - `.hooks/pre-commit` (validates before commit)
3. **GitHub PR** - TruffleHog + Trivy + SonarQube

**Commit format:** `type(scope): description`  
Example: `feat(billing): add consumer API`

## GitHub Actions

- **CI (dev):** `.github/workflows/dev.yml` - Build & test on dev branch
- **PR Validation:** `.github/workflows/pr-validation.yml` - TruffleHog, Trivy, SonarQube, Build & Test

All PRs must pass quality gates before merge.

Happy building! 🚀

