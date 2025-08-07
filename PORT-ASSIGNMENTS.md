# Port Assignments for EduCore LMS Environments

This document outlines the port assignments for each environment to avoid conflicts when running multiple environments simultaneously.

## Port Assignment Summary

| Environment | Web App | PostgreSQL | Redis | Nginx/Load Balancer | Additional Services |
|-------------|---------|------------|-------|-------------------|--------------------|
| **Development** (`docker-compose.yml`) | 8004 | 5440 | 6383 | 8081 | - |
| **Sandbox** (`docker-compose.sandbox.yml`) | 8001 | 5433 | 6380 | - | - |
| **QA** (`docker-compose.qa.yml`) | 8002 | 5434 | 6381 | - | - |
| **UAT** (`docker-compose.uat.yml`) | 8003 | 5435 | 6382 | 8080 | Prometheus: 9090 |
| **Production** (`docker-compose.prod.yml`) | 8005 (HAProxy) | - | - | 8090 (HTTP), 8443 (HTTPS) | - |

## Environment Details

### Development Environment
- **Web Application**: http://localhost:8004
- **PostgreSQL**: localhost:5440
- **Redis**: localhost:6383
- **Nginx**: http://localhost:8081

### Sandbox Environment
- **Web Application**: http://localhost:8001
- **PostgreSQL**: localhost:5433
- **Redis**: localhost:6380

### QA Environment
- **Web Application**: http://localhost:8002
- **PostgreSQL**: localhost:5434
- **Redis**: localhost:6381

### UAT Environment
- **Web Application**: http://localhost:8003
- **PostgreSQL**: localhost:5435
- **Redis**: localhost:6382
- **Nginx**: http://localhost:8080
- **Prometheus**: http://localhost:9090

### Production Environment
- **HAProxy Load Balancer**: http://localhost:8005
- **Nginx HTTP**: http://localhost:8090
- **Nginx HTTPS**: https://localhost:8443

## Usage Notes

1. **No Port Conflicts**: Each environment uses unique external ports, allowing multiple environments to run simultaneously.

2. **Internal Container Ports**: All containers use standard internal ports (8000 for Django, 5432 for PostgreSQL, 6379 for Redis, etc.).

3. **Environment Isolation**: Each environment can be started independently without affecting others.

4. **Production Considerations**: Production environment uses HAProxy for load balancing and supports both HTTP and HTTPS through Nginx.

## Starting Environments

```bash
# Development
docker-compose up -d

# Sandbox
docker-compose -f docker-compose.sandbox.yml up -d

# QA
docker-compose -f docker-compose.qa.yml up -d

# UAT
docker-compose -f docker-compose.uat.yml up -d

# Production
docker-compose -f docker-compose.prod.yml up -d
```

## Port Range Summary

- **Web Applications**: 8001-8005
- **PostgreSQL**: 5433-5440
- **Redis**: 6380-6383
- **HTTP Services**: 8080-8090
- **HTTPS**: 8443
- **Monitoring**: 9090