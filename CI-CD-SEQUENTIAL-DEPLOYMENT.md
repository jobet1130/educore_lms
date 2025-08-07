# Sequential CI/CD Deployment Flow

## Overview
The CI/CD pipeline has been updated to implement a sequential deployment flow: **Development → QA → UAT → Production**.

## Deployment Flow

### 1. Development Environment
- **Trigger**: All branches (main, staging, feature/*, bugfix/*, etc.)
- **Dependencies**: `[build, determine-environment]`
- **Condition**: `needs.determine-environment.outputs.environment == 'development'`
- **URL**: https://dev.educore-lms.com
- **Note**: 'release' branch triggers production deployment flow, 'main' branch uses 'main' Docker tag

### 2. QA Environment
- **Trigger**: After successful Development deployment
- **Dependencies**: `[build, determine-environment, deploy-development]`
- **Condition**: `needs.deploy-development.result == 'success'`
- **URL**: http://qa.educore-lms.com

### 3. UAT Environment
- **Trigger**: After successful QA deployment
- **Dependencies**: `[build, determine-environment, deploy-qa]`
- **Condition**: `needs.deploy-qa.result == 'success'`
- **URL**: http://uat.educore-lms.com

### 4. Production Environment
- **Trigger**: After successful UAT deployment
- **Dependencies**: `[build, determine-environment, deploy-uat]`
- **Condition**: `needs.deploy-uat.result == 'success'`
- **URL**: https://educore-lms.com
- **Features**: Blue-green deployment with rollback capability

## Key Changes Made

### 1. Environment Determination
- All branches now map to `development` environment initially
- Sequential progression through QA → UAT → Production
- **release** branch: Uses `latest` Docker tag (production deployment flow)
- **main** branch: Uses `main` Docker tag
- Other branches: Maintain specific Docker tags for tracking

### 2. Job Dependencies
- **deploy-qa**: Depends on successful `deploy-development`
- **deploy-uat**: Depends on successful `deploy-qa`
- **deploy-production**: Depends on successful `deploy-uat`

### 3. Disabled Jobs
- **deploy-sandbox**: Disabled (not part of sequential flow)

## Deployment Process

1. **Code Push**: Developer pushes to any branch
2. **Build & Test**: Code is built and tested
3. **Development**: Automatic deployment to Development environment
4. **QA**: Automatic deployment to QA after Development success
5. **UAT**: Automatic deployment to UAT after QA success
6. **Production**: Automatic deployment to Production after UAT success

## Benefits

- **Quality Assurance**: Each environment validates the deployment
- **Risk Mitigation**: Issues caught early in the pipeline
- **Consistent Flow**: Predictable deployment progression
- **Rollback Safety**: Blue-green deployment in production
- **Automated Testing**: Each stage includes appropriate tests

## Monitoring

- Health checks at each deployment stage
- Automatic rollback on production deployment failure
- Notification system for deployment status
- Environment-specific logging and monitoring

## Usage

The pipeline automatically triggers on push events to any branch and follows the sequential deployment flow. Manual intervention is only required for:

- Production environment approval (if configured)
- Rollback decisions
- Emergency hotfixes

## Files Modified

- `.github/workflows/ci-cd.yml`: Updated deployment dependencies and conditions
- `docker-compose.green.yml`: Blue-green deployment configuration
- `blue-green-deploy.ps1`: Deployment management script