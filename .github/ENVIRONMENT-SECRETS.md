# Environment Secrets Configuration

This document outlines all the required secrets and environment variables for the EduCore LMS CI/CD workflows across different environments.

## Repository Secrets

These secrets must be configured in your GitHub repository settings under **Settings > Secrets and variables > Actions**.

### Container Registry Secrets

```yaml
# GitHub Container Registry (GHCR)
GHCR_USERNAME: ${{ github.actor }}
GHCR_TOKEN: # GitHub Personal Access Token with packages:write scope

# Alternative: Docker Hub (if using Docker Hub instead)
DOCKER_USERNAME: # Docker Hub username
DOCKER_PASSWORD: # Docker Hub password or access token
```

### AWS Secrets (for backup and deployment)

```yaml
AWS_ACCESS_KEY_ID: # AWS access key for S3 backup operations
AWS_SECRET_ACCESS_KEY: # AWS secret key for S3 backup operations
AWS_REGION: # AWS region (e.g., us-east-1)
AWS_S3_BACKUP_BUCKET: # S3 bucket name for backups (e.g., educore-backups)
```

### Database Secrets

```yaml
# Production Database
PROD_DB_HOST: # Production PostgreSQL host
PROD_DB_PORT: # Production PostgreSQL port (default: 5432)
PROD_DB_NAME: # Production database name
PROD_DB_USER: # Production database username
PROD_DB_PASSWORD: # Production database password

# UAT Database
UAT_DB_HOST: # UAT PostgreSQL host
UAT_DB_PORT: # UAT PostgreSQL port
UAT_DB_NAME: # UAT database name
UAT_DB_USER: # UAT database username
UAT_DB_PASSWORD: # UAT database password

# QA Database
QA_DB_HOST: # QA PostgreSQL host
QA_DB_PORT: # QA PostgreSQL port
QA_DB_NAME: # QA database name
QA_DB_USER: # QA database username
QA_DB_PASSWORD: # QA database password

# Sandbox Database
SANDBOX_DB_HOST: # Sandbox PostgreSQL host
SANDBOX_DB_PORT: # Sandbox PostgreSQL port
SANDBOX_DB_NAME: # Sandbox database name
SANDBOX_DB_USER: # Sandbox database username
SANDBOX_DB_PASSWORD: # Sandbox database password

# Development Database
DEV_DB_HOST: # Development PostgreSQL host
DEV_DB_PORT: # Development PostgreSQL port
DEV_DB_NAME: # Development database name
DEV_DB_USER: # Development database username
DEV_DB_PASSWORD: # Development database password
```

### Application Secrets

```yaml
# Django Secret Keys (different for each environment)
PROD_SECRET_KEY: # Production Django secret key
UAT_SECRET_KEY: # UAT Django secret key
QA_SECRET_KEY: # QA Django secret key
SANDBOX_SECRET_KEY: # Sandbox Django secret key
DEV_SECRET_KEY: # Development Django secret key

# Email Configuration
EMAIL_HOST: # SMTP host (e.g., smtp.gmail.com)
EMAIL_PORT: # SMTP port (e.g., 587)
EMAIL_HOST_USER: # SMTP username
EMAIL_HOST_PASSWORD: # SMTP password or app password
EMAIL_USE_TLS: # true/false

# Redis Configuration
PROD_REDIS_URL: # Production Redis URL
UAT_REDIS_URL: # UAT Redis URL
QA_REDIS_URL: # QA Redis URL
SANDBOX_REDIS_URL: # Sandbox Redis URL
DEV_REDIS_URL: # Development Redis URL
```

### Security and Monitoring

```yaml
# Security Scanning
SNYK_TOKEN: # Snyk token for vulnerability scanning
SONARQUBE_TOKEN: # SonarQube token for code quality analysis
SONARQUBE_HOST_URL: # SonarQube server URL

# Monitoring and Alerting
SLACK_WEBHOOK_URL: # Slack webhook for notifications
DISCORD_WEBHOOK_URL: # Discord webhook for notifications (optional)
TEAMS_WEBHOOK_URL: # Microsoft Teams webhook (optional)

# GitHub Integration
GH_TOKEN: # GitHub token for creating issues and releases
```

### SSL/TLS Certificates

```yaml
# Production SSL
PROD_SSL_CERT: # Production SSL certificate (base64 encoded)
PROD_SSL_KEY: # Production SSL private key (base64 encoded)

# UAT SSL
UAT_SSL_CERT: # UAT SSL certificate (base64 encoded)
UAT_SSL_KEY: # UAT SSL private key (base64 encoded)
```

## Environment-Specific Variables

### Production Environment

```yaml
DJANGO_SETTINGS_MODULE: educore_lms.settings.production
DEBUG: false
ALLOWED_HOSTS: educore.example.com,www.educore.example.com
CORS_ALLOWED_ORIGINS: https://educore.example.com,https://www.educore.example.com
SECURE_SSL_REDIRECT: true
SESSION_COOKIE_SECURE: true
CSRF_COOKIE_SECURE: true
```

### UAT Environment

```yaml
DJANGO_SETTINGS_MODULE: educore_lms.settings.uat
DEBUG: false
ALLOWED_HOSTS: uat.educore.example.com
CORS_ALLOWED_ORIGINS: https://uat.educore.example.com
SECURE_SSL_REDIRECT: true
SESSION_COOKIE_SECURE: true
CSRF_COOKIE_SECURE: true
```

### QA Environment

```yaml
DJANGO_SETTINGS_MODULE: educore_lms.settings.qa
DEBUG: false
ALLOWED_HOSTS: qa.educore.example.com
CORS_ALLOWED_ORIGINS: https://qa.educore.example.com
SECURE_SSL_REDIRECT: true
SESSION_COOKIE_SECURE: true
CSRF_COOKIE_SECURE: true
```

### Sandbox Environment

```yaml
DJANGO_SETTINGS_MODULE: educore_lms.settings.sandbox
DEBUG: true
ALLOWED_HOSTS: sandbox.educore.example.com
CORS_ALLOWED_ORIGINS: https://sandbox.educore.example.com
SECURE_SSL_REDIRECT: false
SESSION_COOKIE_SECURE: false
CSRF_COOKIE_SECURE: false
```

### Development Environment

```yaml
DJANGO_SETTINGS_MODULE: educore_lms.settings.development
DEBUG: true
ALLOWED_HOSTS: dev.educore.example.com,localhost,127.0.0.1
CORS_ALLOWED_ORIGINS: http://localhost:3000,http://127.0.0.1:3000
SECURE_SSL_REDIRECT: false
SESSION_COOKIE_SECURE: false
CSRF_COOKIE_SECURE: false
```

## GitHub Environment Configuration

Create the following environments in your GitHub repository under **Settings > Environments**:

### 1. Production Environment
- **Environment name**: `production`
- **Protection rules**: 
  - Required reviewers: 2
  - Restrict to protected branches: `main`, `release`
- **Environment secrets**: All production-specific secrets listed above

### 2. UAT Environment
- **Environment name**: `uat`
- **Protection rules**: 
  - Required reviewers: 1
  - Restrict to protected branches: `staging`, `releaseTest`
- **Environment secrets**: All UAT-specific secrets listed above

### 3. QA Environment
- **Environment name**: `qa`
- **Protection rules**: 
  - Required reviewers: 1
  - Restrict to protected branches: `stagingTest`, `enhancement/*`
- **Environment secrets**: All QA-specific secrets listed above

### 4. Sandbox Environment
- **Environment name**: `sandbox`
- **Protection rules**: None (for testing)
- **Environment secrets**: All sandbox-specific secrets listed above

### 5. Development Environment
- **Environment name**: `development`
- **Protection rules**: None (for development)
- **Environment secrets**: All development-specific secrets listed above

## Secret Management Best Practices

### 1. Secret Rotation
- Rotate database passwords every 90 days
- Rotate API tokens every 6 months
- Rotate SSL certificates before expiration

### 2. Access Control
- Use least privilege principle
- Separate secrets by environment
- Use different credentials for each environment

### 3. Monitoring
- Monitor secret usage in GitHub Actions logs
- Set up alerts for failed authentication
- Regular audit of secret access

### 4. Backup and Recovery
- Keep encrypted backups of critical secrets
- Document secret recovery procedures
- Test secret restoration process

## Setup Instructions

### 1. Repository Secrets
1. Go to your GitHub repository
2. Navigate to **Settings > Secrets and variables > Actions**
3. Click **New repository secret**
4. Add each secret from the list above

### 2. Environment Secrets
1. Go to **Settings > Environments**
2. Create each environment listed above
3. Configure protection rules as specified
4. Add environment-specific secrets

### 3. Verification
1. Run the CI/CD pipeline on a test branch
2. Check that all secrets are properly resolved
3. Verify deployments work for each environment
4. Test backup and recovery procedures

## Troubleshooting

### Common Issues

1. **Secret not found error**
   - Verify secret name matches exactly (case-sensitive)
   - Check if secret is added to correct environment
   - Ensure environment protection rules allow access

2. **Database connection failed**
   - Verify database credentials are correct
   - Check network connectivity from GitHub Actions
   - Ensure database allows connections from GitHub IPs

3. **Docker registry authentication failed**
   - Verify GHCR_TOKEN has correct permissions
   - Check token expiration date
   - Ensure username matches GitHub actor

### Support

For issues with secret configuration:
1. Check GitHub Actions logs for specific error messages
2. Verify secret values in repository/environment settings
3. Test secrets in a minimal workflow first
4. Contact DevOps team for assistance

---

**Note**: Never commit actual secret values to the repository. This file should only contain the structure and naming conventions for secrets.