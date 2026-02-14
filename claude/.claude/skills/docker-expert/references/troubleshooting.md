# Docker Troubleshooting Guide

## Common Issue Diagnostics

### Build Performance Issues

**Symptoms**: Slow builds (10+ minutes), frequent cache invalidation

**Root causes**:
- Poor layer ordering
- Large build context
- No caching strategy

**Solutions**:
- Multi-stage builds
- .dockerignore optimization
- Dependency caching with `--mount=type=cache`

### Security Vulnerabilities

**Symptoms**: Security scan failures, exposed secrets, root execution

**Root causes**:
- Outdated base images
- Hardcoded secrets
- Default user

**Solutions**:
- Regular base updates
- Docker secrets management
- Non-root user configuration

### Image Size Problems

**Symptoms**: Images over 1GB, deployment slowness

**Root causes**:
- Unnecessary files included
- Build tools in production
- Poor base image selection

**Solutions**:
- Distroless images
- Multi-stage optimization
- Selective artifact copying

### Networking Issues

**Symptoms**: Service communication failures, DNS resolution errors

**Root causes**:
- Missing networks
- Port conflicts
- Service naming issues

**Solutions**:
- Custom networks
- Health checks
- Proper service discovery

### Development Workflow Problems

**Symptoms**: Hot reload failures, debugging difficulties, slow iteration

**Root causes**:
- Volume mounting issues
- Port configuration problems
- Environment mismatch

**Solutions**:
- Development-specific targets
- Proper volume strategy
- Debug configuration

## Diagnostic Commands

```bash
# Docker environment detection
docker --version 2>/dev/null || echo "No Docker installed"
docker info | grep -E "Server Version|Storage Driver|Container Runtime" 2>/dev/null
docker context ls 2>/dev/null | head -3

# Project structure analysis
find . -name "Dockerfile*" -type f | head -10
find . -name "*compose*.yml" -o -name "*compose*.yaml" -type f | head -5
find . -name ".dockerignore" -type f | head -3

# Container status if running
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null | head -10
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null | head -10
```

## Validation Commands

```bash
# Build and security validation
docker build --no-cache -t test-build . 2>/dev/null && echo "Build successful"
docker history test-build --no-trunc 2>/dev/null | head -5
docker scout quickview test-build 2>/dev/null || echo "No Docker Scout"

# Runtime validation
docker run --rm -d --name validation-test test-build 2>/dev/null
docker exec validation-test ps aux 2>/dev/null | head -3
docker stop validation-test 2>/dev/null

# Compose validation
docker-compose config 2>/dev/null && echo "Compose config valid"
```

## When to Recommend Other Experts

| Issue | Recommend |
|-------|-----------|
| Kubernetes orchestration | kubernetes-expert |
| CI/CD pipeline issues | github-actions-expert |
| Database containerization | database-expert |
| Application-specific optimization | Language experts |
| Infrastructure automation | devops-expert |
