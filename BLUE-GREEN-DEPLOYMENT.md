# Blue-Green Deployment Setup for EduCore LMS

This document describes the blue-green deployment setup for the EduCore LMS project, which allows for zero-downtime deployments.

## Overview

Blue-green deployment is a technique that reduces downtime and risk by running two identical production environments called Blue and Green. At any time, only one of the environments is live, with the other serving as a staging environment.

## Files

- `docker-compose.prod.yml` - Blue environment (production)
- `docker-compose.green.yml` - Green environment (staging)
- `blue-green-deploy.ps1` - PowerShell script for managing deployments

## Port Assignments

| Environment | Service | Port |
|-------------|---------|------|
| Blue (Production) | Web App | 8005 |
| Blue (Production) | Database | 5432 |
| Blue (Production) | Nginx | 8090 |
| Blue (Production) | HAProxy | 8005 |
| Green (Staging) | Web App | 8006 |
| Green (Staging) | Database | 5441 |
| Green (Staging) | Nginx | 8091 |
| Green (Staging) | HAProxy | 8007 |

## Quick Start

### 1. Check Current Status

```powershell
.\blue-green-deploy.ps1 -Action status
```

### 2. Deploy to Green Environment

```powershell
# Deploy latest version
.\blue-green-deploy.ps1 -Action deploy-green

# Deploy specific version
.\blue-green-deploy.ps1 -Action deploy-green -ImageTag v1.2.3
```

### 3. Test Green Environment

Once deployed, test the green environment:
- Web App: http://localhost:8006
- Nginx: http://localhost:8091

### 4. Switch Traffic to Green

```powershell
.\blue-green-deploy.ps1 -Action switch-to-green
```

### 5. Cleanup Old Environment

```powershell
.\blue-green-deploy.ps1 -Action cleanup
```

## Manual Deployment Steps

### Deploy Green Environment

```bash
# Set environment variables
export DOCKER_TAG=v1.2.3

# Start green environment
docker-compose -f docker-compose.green.yml up -d

# Check health
curl http://localhost:8006/health/
```

### Switch Traffic

Update your load balancer configuration to point to the green environment:
- From: http://localhost:8005 (blue)
- To: http://localhost:8006 (green)

### Rollback if Needed

```powershell
.\blue-green-deploy.ps1 -Action switch-to-blue
```

## Environment Variables

Both environments use the same environment variables:

- `SECRET_KEY` - Django secret key
- `DB_NAME` - Database name
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password
- `ALLOWED_HOSTS` - Allowed hosts for Django
- `DOCKER_TAG` - Docker image tag to deploy

## Health Checks

Both environments include health checks:
- **Web App**: `http://localhost:PORT/health/`
- **Database**: `pg_isready` command
- **Nginx**: HTTP response check

## Monitoring

Monitor both environments during deployment:

```bash
# Check container status
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.green.yml ps

# Check logs
docker-compose -f docker-compose.green.yml logs -f

# Check resource usage
docker stats
```

## Troubleshooting

### Green Environment Won't Start

1. Check Docker logs:
   ```bash
   docker-compose -f docker-compose.green.yml logs
   ```

2. Verify environment variables:
   ```bash
   docker-compose -f docker-compose.green.yml config
   ```

3. Check port conflicts:
   ```bash
   netstat -tulpn | grep :8006
   ```

### Health Check Failures

1. Wait for startup period (40 seconds)
2. Check application logs
3. Verify database connectivity
4. Test health endpoint manually:
   ```bash
   curl -v http://localhost:8006/health/
   ```

### Database Migration Issues

1. Run migrations manually:
   ```bash
   docker-compose -f docker-compose.green.yml exec web python manage.py migrate
   ```

2. Check database connectivity:
   ```bash
   docker-compose -f docker-compose.green.yml exec db-green pg_isready
   ```

## Best Practices

1. **Always test the green environment** before switching traffic
2. **Monitor both environments** during the switch
3. **Keep the blue environment running** until you're confident in the green deployment
4. **Use specific image tags** instead of `latest` for production deployments
5. **Run database migrations** in the green environment before switching
6. **Have a rollback plan** ready

## CI/CD Integration

Integrate blue-green deployment into your CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
- name: Deploy to Green Environment
  run: |
    .\blue-green-deploy.ps1 -Action deploy-green -ImageTag ${{ github.sha }}
    
- name: Test Green Environment
  run: |
    # Run your test suite against green environment
    curl -f http://localhost:8006/health/
    
- name: Switch to Green
  run: |
    .\blue-green-deploy.ps1 -Action switch-to-green
```

## Security Considerations

- Use Docker secrets for sensitive data
- Ensure both environments use the same security configurations
- Monitor access logs during deployment
- Use HTTPS in production with proper SSL certificates

## Support

For issues with blue-green deployment:

1. Check the deployment logs
2. Verify environment configurations
3. Test individual components
4. Consult the troubleshooting section above