# EduCore LMS - Multi-Environment Setup

This document describes the multi-environment Docker setup for the EduCore LMS project, including sandbox, QA, UAT, and production environments.

## 🏗️ Environment Overview

| Environment | Purpose | Port | Database Port | Redis Port | Features |
|-------------|---------|------|---------------|------------|-----------|
| **Sandbox** | Development & Experimentation | 8001 | 5433 | 6380 | Debug mode, Hot reload |
| **QA** | Quality Assurance Testing | 8002 | 5434 | 6381 | Test runner, Logging |
| **UAT** | User Acceptance Testing | 8003 | 5435 | 6382 | Nginx, Monitoring |
| **Production** | Live Production System | 80/443 | 5432 | 6379 | SSL, HA, Backups |

## 📁 File Structure

```
educore_lms/
├── docker-compose.yml              # Base development setup
├── docker-compose.sandbox.yml      # Sandbox environment
├── docker-compose.qa.yml           # QA environment
├── docker-compose.uat.yml          # UAT environment
├── docker-compose.prod.yml         # Production environment
├── docker-compose.override.yml     # Development overrides
├── .env.example                    # Environment variables template
├── deploy.sh                       # Deployment script
├── Dockerfile                      # Application container
├── nginx.conf                      # Nginx configuration
└── README-environments.md          # This file
```

## 🚀 Quick Start

### 1. Setup Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit the .env file with your specific values
nano .env
```

### 2. Deploy an Environment

```bash
# Make the deployment script executable
chmod +x deploy.sh

# Deploy sandbox environment
./deploy.sh sandbox up

# Deploy QA environment
./deploy.sh qa up

# Deploy UAT environment
./deploy.sh uat up

# Deploy production environment (requires confirmation)
./deploy.sh prod up
```

### 3. Access Your Environment

- **Sandbox**: http://localhost:8001
- **QA**: http://localhost:8002
- **UAT**: http://localhost:8003 (app) or http://localhost:8080 (nginx)
- **Production**: http://localhost (nginx)

## 🔧 Environment Details

### Sandbox Environment
- **Purpose**: Development and experimental features
- **Configuration**: Debug mode enabled, hot reload
- **Resources**: Limited (0.5 CPU, 512MB RAM)
- **Database**: `sandbox_db` on port 5433
- **Redis**: Database 1 on port 6380

### QA Environment
- **Purpose**: Quality assurance and automated testing
- **Configuration**: Production-like settings with testing tools
- **Resources**: Moderate (1.0 CPU, 1GB RAM)
- **Database**: `qa_db` on port 5434
- **Redis**: Database 2 on port 6381
- **Special Features**: Test runner service, detailed logging

### UAT Environment
- **Purpose**: User acceptance testing
- **Configuration**: Production-like with monitoring
- **Resources**: High (1.5 CPU, 2GB RAM)
- **Database**: `uat_db` on port 5435
- **Redis**: Database 4 on port 6382
- **Special Features**: Nginx reverse proxy, Prometheus monitoring

### Production Environment
- **Purpose**: Live production system
- **Configuration**: High security, SSL, multiple replicas
- **Resources**: Maximum (2.0 CPU, 4GB RAM)
- **Database**: Configurable via environment variables
- **Redis**: Password protected, persistent storage
- **Special Features**: SSL/TLS, load balancing, automated backups

## 📋 Management Commands

### Using the Deployment Script

```bash
# Start an environment
./deploy.sh [environment] up

# Stop an environment
./deploy.sh [environment] down

# Restart an environment
./deploy.sh [environment] restart

# View logs
./deploy.sh [environment] logs

# Create backup
./deploy.sh [environment] backup

# Show access URLs
./deploy.sh [environment] urls

# Show help
./deploy.sh help
```

### Manual Docker Compose Commands

```bash
# Sandbox
docker-compose -f docker-compose.sandbox.yml up -d
docker-compose -f docker-compose.sandbox.yml down

# QA with testing
docker-compose -f docker-compose.qa.yml --profile testing up -d

# UAT with monitoring
docker-compose -f docker-compose.uat.yml --profile monitoring up -d

# Production with high availability
docker-compose -f docker-compose.prod.yml --profile ha up -d

# Production with backups
docker-compose -f docker-compose.prod.yml --profile backup up -d
```

## 🔐 Security Considerations

### Environment Variables
Create environment-specific `.env` files:
- `.env.sandbox`
- `.env.qa`
- `.env.uat`
- `.env.prod`

### Production Security
- Use strong, unique passwords for all services
- Enable SSL/TLS certificates
- Configure proper firewall rules
- Use Docker secrets for sensitive data
- Regular security updates

### Database Security
- Use strong database passwords
- Limit database access to application containers
- Regular backups with encryption
- Monitor database access logs

## 📊 Monitoring and Logging

### QA Environment
- Application logs in `./logs` directory
- Test reports in `./test-reports`
- Health checks for all services

### UAT Environment
- Prometheus metrics on port 9090
- Nginx access logs
- Application performance monitoring

### Production Environment
- Centralized logging with rotation
- Health checks and alerts
- Performance monitoring
- Automated backup verification

## 🔄 CI/CD Integration

### GitLab CI Example
```yaml
stages:
  - test
  - deploy-qa
  - deploy-uat
  - deploy-prod

test:
  stage: test
  script:
    - ./deploy.sh qa up
    - docker-compose -f docker-compose.qa.yml --profile testing run test-runner

deploy-qa:
  stage: deploy-qa
  script:
    - ./deploy.sh qa up
  only:
    - develop

deploy-uat:
  stage: deploy-uat
  script:
    - ./deploy.sh uat up
  only:
    - release/*

deploy-prod:
  stage: deploy-prod
  script:
    - ./deploy.sh prod up
  only:
    - main
  when: manual
```

## 🛠️ Troubleshooting

### Common Issues

1. **Port Conflicts**
   ```bash
   # Check what's using the port
   netstat -tulpn | grep :8001
   
   # Stop conflicting services
   sudo systemctl stop apache2
   ```

2. **Database Connection Issues**
   ```bash
   # Check database logs
   ./deploy.sh [environment] logs
   
   # Restart database service
   docker-compose -f docker-compose.[environment].yml restart db
   ```

3. **Memory Issues**
   ```bash
   # Check Docker resource usage
   docker stats
   
   # Increase Docker memory limits
   # Edit Docker Desktop settings
   ```

### Health Checks

```bash
# Check service health
docker-compose -f docker-compose.[environment].yml ps

# Check application health
curl http://localhost:[port]/health/

# Check database connectivity
docker-compose -f docker-compose.[environment].yml exec db pg_isready
```

## 📚 Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Django Deployment Guide](https://docs.djangoproject.com/en/stable/howto/deployment/)
- [PostgreSQL Docker Guide](https://hub.docker.com/_/postgres)
- [Redis Docker Guide](https://hub.docker.com/_/redis)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)

## 🤝 Contributing

When adding new environments or modifying existing ones:

1. Update the appropriate `docker-compose.[environment].yml` file
2. Update environment variables in `.env.example`
3. Update the deployment script if needed
4. Update this README with new information
5. Test the changes in a development environment first

## 📞 Support

For issues related to the multi-environment setup:

1. Check the troubleshooting section above
2. Review Docker and application logs
3. Consult the team documentation
4. Create an issue in the project repository