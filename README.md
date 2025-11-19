# Billing Consumer Service

Minimal Spring Boot 3 (Java 21) microservice that stores `BillingConsumer` records with mandatory encryption for sensitive fields while keeping the codebase lean.

## Features

- POST + GET REST APIs covering basic CRUD entry points
- AES/GCM field-level encryption for `password`, `medicalHistory`, and `nationalId`
- Database credentials externalised via `config/datasource-secrets.yml` (never committed)
- Ready for future GitHub Actions → AWS App Runner/App Service + Terraform deployment
- Designed with secret-scanning/SonarQube enablement in mind (no hard-coded secrets)

## Tech Stack

- Spring Boot 3.2.x, Java 21
- Spring Data JPA + H2 (swap with managed DB later)
- Lombok for minimal boilerplate

## Getting Started

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

## Security Checklist

- [x] No secrets in source
- [x] Sensitive fields encrypted at rest and in API payloads
- [x] Ready for GitHub Actions secret scanning & SonarQube gates

Happy building!

