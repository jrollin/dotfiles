# Container Security Hardening

## Non-Root User Configuration

```dockerfile
# Security-hardened container
FROM node:18-alpine
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup
WORKDIR /app
COPY --chown=appuser:appgroup package*.json ./
RUN npm ci --only=production
COPY --chown=appuser:appgroup . .
USER 1001
# Drop capabilities, set read-only root filesystem
```

## Secrets Management

### Build-Time Secrets (BuildKit)

```dockerfile
FROM alpine
RUN --mount=type=secret,id=api_key \
    API_KEY=$(cat /run/secrets/api_key) && \
    # Use API_KEY for build process
```

### Runtime Secrets (Docker Compose)

```yaml
services:
  app:
    secrets:
      - db_password
      - api_key

secrets:
  db_password:
    external: true
  api_key:
    file: ./secrets/api_key.txt
```

## Security Focus Areas

| Area | Best Practice |
|------|---------------|
| User | Run as non-root with specific UID/GID |
| Secrets | Use Docker secrets, never ENV vars for sensitive data |
| Base images | Regular updates, minimal attack surface |
| Runtime | Capability restrictions, resource limits |
| Scanning | Regular vulnerability scans with Docker Scout |

## Health Check Strategies

```dockerfile
# Sophisticated health monitoring
COPY health-check.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/health-check.sh
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD ["/usr/local/bin/health-check.sh"]
```

## Common Vulnerabilities

| Symptom | Root Cause | Solution |
|---------|------------|----------|
| Security scan failures | Outdated base images | Regular base updates |
| Exposed secrets | Hardcoded in ENV/layers | Use Docker secrets |
| Root execution | Missing USER directive | Add non-root user |

## Checklist

- [ ] Non-root user created with specific UID/GID (not default)
- [ ] Container runs as non-root user (USER directive)
- [ ] Secrets managed properly (not in ENV vars or layers)
- [ ] Base images kept up-to-date and scanned for vulnerabilities
- [ ] Minimal attack surface (only necessary packages installed)
- [ ] Health checks implemented for container monitoring
