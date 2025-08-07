# EduCore LMS CI/CD Workflows

This directory contains GitHub Actions workflows for the EduCore LMS project, providing comprehensive CI/CD automation including testing, security scanning, building, and deployment.

## 📋 Workflow Overview

### 1. Main CI/CD Pipeline (`ci-cd.yml`)
**Triggers:** Push to main branches, pull requests
**Purpose:** Complete CI/CD pipeline with testing, building, and deployment

**Stages:**
- **Code Quality:** Formatting, linting, type checking
- **Testing:** Unit tests with PostgreSQL service
- **Security:** Trivy vulnerability scanning
- **Build & Push:** Docker images to GitHub Container Registry
- **Deploy:** Multi-environment deployment (Sandbox → QA → UAT → Production)
- **Notification:** Slack/email notifications

### 2. Pull Request Validation (`pr-validation.yml`)
**Triggers:** Pull request events
**Purpose:** Comprehensive PR validation and quality checks

**Features:**
- Draft PR detection
- Title and description validation
- Matrix testing (Python 3.9-3.11, Django 4.1-4.2)
- Performance testing
- Docker build validation
- Dependency security review
- Automated PR comments with results

### 3. Security Monitoring (`security-monitoring.yml`)
**Triggers:** Daily schedule, manual dispatch, security-related file changes
**Purpose:** Continuous security monitoring and vulnerability detection

**Scans:**
- **Python Dependencies:** Safety, Bandit, Semgrep
- **Docker Images:** Trivy vulnerability scanning
- **License Compliance:** pip-licenses
- **Secret Detection:** TruffleHog
- **Infrastructure as Code:** Checkov
- **Automated Issue Creation:** For security alerts

### 4. Deployment Pipeline (`deploy.yml`)
**Triggers:** Branch-based deployment, manual dispatch
**Purpose:** Automated deployment to multiple environments

**Environments:**
- `main` → Production
- `release` → Production
- `releaseTest` → UAT
- `staging` → UAT
- `stagingTest` → QA
- `qa` → Sandbox
- `feature/*` → QA
- `enhancement/*` → QA
- `bugfix/*` → QA
- `hotfix/*` → Production
- Manual → Any environment

**Features:**
- Pre-deployment validation
- Health checks
- Database migrations
- Static file collection
- Rollback on failure
- Deployment notifications

## 🚀 Getting Started

### Prerequisites

1. **Repository Secrets** (Settings → Secrets and variables → Actions):
   ```
   DJANGO_SECRET_KEY          # Django secret key
   DATABASE_URL              # Database connection string
   REDIS_URL                 # Redis connection string
   EMAIL_HOST_PASSWORD       # Email service password
   AWS_ACCESS_KEY_ID         # AWS access key
   AWS_SECRET_ACCESS_KEY     # AWS secret key
   SENTRY_DSN               # Sentry error tracking DSN
   SLACK_WEBHOOK_URL        # Slack notifications (optional)
   ```

2. **Environment Protection Rules** (Settings → Environments):
   - `production`: Require reviewers, deployment branches
   - `uat`: Require reviewers
   - `qa`: Auto-deployment
   - `sandbox`: Auto-deployment

3. **Branch Protection Rules** (Settings → Branches):
   - `main`: Require PR reviews, status checks
   - `develop`: Require status checks

### Repository Setup

1. **Enable GitHub Container Registry:**
   ```bash
   # Packages are automatically published to ghcr.io
   # No additional setup required
   ```

2. **Configure Dependabot:**
   - Dependabot configuration is included (`.github/dependabot.yml`)
   - Automatic dependency updates for Python, Docker, and GitHub Actions
   - Security updates run daily

3. **Security Features:**
   - Enable Dependabot security updates
   - Enable secret scanning
   - Enable code scanning (CodeQL)

## 🔄 Workflow Usage

### Automatic Triggers

| Event | Workflow | Action |
|-------|----------|--------|
| Push to `main` | CI/CD, Deploy | Full pipeline + Production deployment |
| Push to `release` | CI/CD, Deploy | Full pipeline + Production deployment |
| Push to `releaseTest` | CI/CD, Deploy | Full pipeline + UAT deployment |
| Push to `staging` | CI/CD, Deploy | Full pipeline + UAT deployment |
| Push to `stagingTest` | CI/CD, Deploy | Full pipeline + QA deployment |
| Push to `qa` | CI/CD, Deploy | Full pipeline + Sandbox deployment |
| Push to `feature/*` | CI/CD, Deploy | Full pipeline + QA deployment |
| Push to `enhancement/*` | CI/CD, Deploy | Full pipeline + QA deployment |
| Push to `bugfix/*` | CI/CD, Deploy | Full pipeline + QA deployment |
| Push to `hotfix/*` | CI/CD, Deploy | Full pipeline + Production deployment |
| Pull Request | PR Validation | Quality checks and testing |
| Daily 2 AM UTC | Security Monitoring | Security scans |
| Dependency updates | Dependabot | Automated PRs |

### Branch Workflow Guidelines

#### Feature Branches (`feature/*`)
- **Purpose**: New feature development
- **Naming**: `feature/feature-name` (e.g., `feature/user-authentication`)
- **Deployment**: Automatically deploys to QA environment
- **Docker Tag**: `feature-{feature-name}`
- **Workflow**: Create from `qa` → Develop → Test → Merge to `qa`

#### Enhancement Branches (`enhancement/*`)
- **Purpose**: Improvements and optimizations to existing features
- **Naming**: `enhancement/improvement-description` (e.g., `enhancement/performance-optimization`)
- **Deployment**: Automatically deploys to QA environment
- **Docker Tag**: `enhancement-{improvement-description}`
- **Workflow**: Create from `qa` → Enhance → Test → Merge to `stagingTest`

#### Bugfix Branches (`bugfix/*`)
- **Purpose**: Non-critical bug fixes and issue resolution
- **Naming**: `bugfix/issue-description` (e.g., `bugfix/login-issue`)
- **Deployment**: Automatically deploys to QA environment
- **Docker Tag**: `bugfix-{issue-description}`
- **Workflow**: Create from `qa` → Fix → Test → Merge to `qa`

#### Hotfix Branches (`hotfix/*`)
- **Purpose**: Critical production fixes
- **Naming**: `hotfix/fix-description` (e.g., `hotfix/security-patch`)
- **Deployment**: Automatically deploys to Production environment
- **Docker Tag**: `hotfix-{fix-description}`
- **Workflow**: Create from `main` → Fix → Test → Merge to `main` and `qa`

### Branch Promotion Flow

The following promotion flow ensures proper testing and validation before production deployment:

```
feature/* → qa → stagingTest → staging(uat) → releaseTest → release
enhancement/* → qa → stagingTest → staging(uat) → releaseTest → release
bugfix/* → qa → stagingTest → staging(uat) → releaseTest → release
```

**Environment Progression:**
- **QA Environment**: `feature/*`, `enhancement/*`, `bugfix/*`, `stagingTest` branches
- **UAT Environment**: `staging`, `releaseTest` branches  
- **Production Environment**: `main`, `release`, `hotfix/*` branches
- **Sandbox Environment**: `qa` branch (for experimental testing)
- **Development Environment**: Fallback environment for unmatched branches

**Promotion Process:**
1. **QA Testing**: All feature branches (`feature/*`, `enhancement/*`, `bugfix/*`) deploy to QA for initial testing
2. **Staging Test**: Approved changes are promoted to `stagingTest` branch for integration testing
3. **UAT Testing**: Changes move to `staging` branch for user acceptance testing
4. **Release Testing**: Final validation on `releaseTest` branch before production
5. **Production**: Approved releases are deployed from `release` or `main` branch

### Manual Triggers

1. **Manual Deployment:**
   ```
   Actions → Deploy to Environments → Run workflow
   - Choose environment: sandbox/qa/uat/production
   - Optional: Force deployment (skip checks)
   - Optional: Specify Docker tag
   ```

2. **Security Scan:**
   ```
   Actions → Security Monitoring → Run workflow
   ```

3. **Full CI/CD:**
   ```
   Actions → CI/CD Pipeline → Run workflow
   ```

### Branch Strategy

```
main (production)
├── release (production)
├── releaseTest (UAT)
├── staging (UAT)
├── stagingTest (QA)
├── qa (sandbox)
├── feature/* (qa)
│   ├── feature/user-authentication
│   ├── feature/course-management
│   └── feature/payment-integration
├── enhancement/* (QA)
│   ├── enhancement/performance-optimization
│   ├── enhancement/ui-improvements
│   └── enhancement/api-enhancements
├── bugfix/* (qa)
│   ├── bugfix/login-issue
│   ├── bugfix/data-validation
│   └── bugfix/ui-rendering
└── hotfix/* (production)
    ├── hotfix/security-patch
    └── hotfix/critical-bug-fix
```

## 🏗️ Environment Configuration

### Environment URLs
- **Production:** `https://educore.example.com`
- **UAT:** `https://uat.educore.example.com`
- **QA:** `https://qa.educore.example.com`
- **Sandbox:** `https://sandbox.educore.example.com`

### Docker Compose Files
- `docker-compose.prod.yml` - Production
- `docker-compose.uat.yml` - UAT
- `docker-compose.qa.yml` - QA
- `docker-compose.sandbox.yml` - Sandbox

### Environment Variables
Each environment uses specific settings modules:
- Production: `educore_lms.settings.production`
- UAT: `educore_lms.settings.uat`
- QA: `educore_lms.settings.qa`
- Sandbox: `educore_lms.settings.sandbox`

## 🔒 Security Features

### Automated Security Scanning
- **Daily vulnerability scans** for dependencies and Docker images
- **Secret detection** in code and commits
- **License compliance** checking
- **Infrastructure as Code** security validation

### Security Notifications
- Automatic GitHub issues for security alerts
- SARIF upload to GitHub Security tab
- Artifact retention for security reports

### Dependency Management
- **Dependabot** for automated updates
- **Grouped updates** for related packages
- **Security-first updates** with daily checks
- **Version pinning** for critical dependencies

## 📊 Monitoring and Notifications

### Workflow Status
- GitHub Actions dashboard
- Email notifications for failures
- Slack integration (optional)

### Deployment Tracking
- Environment-specific deployment history
- Automatic deployment status updates
- Health check validation

### Artifacts and Reports
- Test coverage reports
- Security scan results
- Performance test results
- License compliance reports

## 🛠️ Troubleshooting

### Common Issues

1. **Deployment Failure:**
   ```bash
   # Check logs in Actions tab
   # Verify environment secrets
   # Check Docker image availability
   ```

2. **Test Failures:**
   ```bash
   # Run tests locally:
   python -m pytest
   
   # Check database connectivity
   # Verify test data setup
   ```

3. **Security Scan Failures:**
   ```bash
   # Review security reports in artifacts
   # Update vulnerable dependencies
   # Check for exposed secrets
   ```

### Manual Rollback

If automatic rollback fails:

1. **Identify last known good deployment:**
   ```bash
   # Check deployment history in Actions
   # Note the successful commit SHA
   ```

2. **Manual deployment:**
   ```bash
   # Use workflow_dispatch with specific tag
   # Or deploy locally with Docker Compose
   ```

### Debug Mode

Enable debug logging by adding to workflow:
```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Django Deployment Guide](https://docs.djangoproject.com/en/stable/howto/deployment/)
- [Security Best Practices](https://docs.github.com/en/actions/security-guides)

## 🤝 Contributing

When modifying workflows:

1. Test changes in a feature branch
2. Use workflow_dispatch for testing
3. Update this documentation
4. Follow security best practices
5. Add appropriate error handling

## 📝 Changelog

### v1.0.0 (Initial Release)
- Complete CI/CD pipeline
- Multi-environment deployment
- Security monitoring
- Dependabot integration
- PR validation workflows