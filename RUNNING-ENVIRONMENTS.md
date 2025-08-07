# EduCore LMS - Running Environments Summary

## All Environments Status

All 5 environments are now running simultaneously with unique ports and containers:

### Environment Access URLs

| Environment | Web App URL | Nginx URL | Database Port | Status |
|-------------|-------------|-----------|---------------|--------|
| **Development** | http://localhost:8004 | http://localhost:8081 | 5440 | ✅ Running |
| **Sandbox** | http://localhost:8001 | - | 5433 | ✅ Running |
| **QA** | http://localhost:8002 | - | 5434 | ✅ Running |
| **UAT** | http://localhost:8003 | http://localhost:8080 | 5435 | ✅ Running |
| **Production** | http://localhost:8005 | http://localhost:8090 (HTTPS: 8443) | Internal | ✅ Running |

### Container Details

#### Web Application Containers
- `educore_lms_web` (Development) - Port 8004
- `educore_lms_web-sandbox` (Sandbox) - Port 8001
- `educore_lms_web-qa` (QA) - Port 8002
- `educore_lms_web-uat` (UAT) - Port 8003
- `educore_lms_web-prod` (Production) - Port 8005

#### Database Containers
- `educore-dev-db-1` (Development) - Port 5440
- `educore-sandbox-db-1` (Sandbox) - Port 5433
- `educore-qa-db-1` (QA) - Port 5434
- `educore-uat-db-1` (UAT) - Port 5435
- `educore-prod-db-1` (Production) - Internal only

#### Nginx/Load Balancer Containers
- `educore-dev-nginx-1` (Development) - Port 8081
- `educore-uat-nginx-1` (UAT) - Port 8080
- `educore-prod-nginx-1` (Production) - Ports 8090 (HTTP), 8443 (HTTPS)

### Docker Desktop Visibility

✅ **All environments are now visible in Docker Desktop with their respective ports exposed!**

Each environment runs as a separate Docker Compose project:
- `educore-dev` (Development)
- `educore-sandbox` (Sandbox)
- `educore-qa` (QA)
- `educore-uat` (UAT)
- `educore-prod` (Production)

### Quick Commands

**Start all environments:**
```powershell
.\start-all-environments.ps1
```

**Stop all environments:**
```bash
docker stop $(docker ps -q)
```

**View running containers:**
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---
*Generated on: $(Get-Date)*