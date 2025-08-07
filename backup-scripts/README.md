# Backup Scripts

This directory contains backup scripts for the EduCore LMS database that can be used locally without requiring production environment variables.

## Available Scripts

### 1. local-backup.sh (Linux/macOS)
Bash script for creating database backups on Unix-like systems.

### 2. local-backup.ps1 (Windows)
PowerShell script for creating database backups on Windows systems.

## Prerequisites

- PostgreSQL client tools (`pg_dump`, `pg_isready`) must be installed
- Database must be running and accessible
- Appropriate database permissions for the user

### Installing PostgreSQL Client Tools

**Windows:**
- Download from: https://www.postgresql.org/download/windows/
- Or install via chocolatey: `choco install postgresql`

**macOS:**
- Install via Homebrew: `brew install postgresql`

**Ubuntu/Debian:**
- Install via apt: `sudo apt-get install postgresql-client`

## Usage

### Basic Usage (Default Values)

**Linux/macOS:**
```bash
# Make script executable
chmod +x backup-scripts/local-backup.sh

# Run backup
./backup-scripts/local-backup.sh
```

**Windows:**
```powershell
# Run backup
.\backup-scripts\local-backup.ps1
```

### Custom Parameters

**Linux/macOS:**
```bash
# Set environment variables
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=my_database
export DB_USER=my_user
export DB_PASSWORD=my_password
export BACKUP_DIR=./my_backups

# Run backup
./backup-scripts/local-backup.sh
```

**Windows:**
```powershell
# Run with custom parameters
.\backup-scripts\local-backup.ps1 -DbHost "localhost" -DbPort "5432" -DbName "my_database" -DbUser "my_user" -BackupDir "./my_backups"

# Or set environment variables
$env:DB_PASSWORD = "my_password"
.\backup-scripts\local-backup.ps1
```

## Default Values

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| DB_HOST | localhost | Database host |
| DB_PORT | 5432 | Database port |
| DB_NAME | educore_lms | Database name |
| DB_USER | postgres | Database user |
| BACKUP_DIR | ./backups | Backup directory |

## Environment-Specific Backups

### Development Environment
```bash
# Default settings work for development
./backup-scripts/local-backup.sh
```

### Sandbox Environment
```bash
export DB_PORT=5433
export DB_NAME=sandbox_db
export DB_USER=sandbox_user
./backup-scripts/local-backup.sh
```

### QA Environment
```bash
export DB_PORT=5434
export DB_NAME=qa_db
export DB_USER=qa_user
./backup-scripts/local-backup.sh
```

### UAT Environment
```bash
export DB_PORT=5435
export DB_NAME=uat_db
export DB_USER=uat_user
./backup-scripts/local-backup.sh
```

## Features

- ✅ **Connectivity Check**: Verifies database accessibility before backup
- 📦 **Timestamped Backups**: Creates backups with timestamp in filename
- 🧹 **Automatic Cleanup**: Removes backups older than 7 days
- 📏 **Size Reporting**: Shows backup file size after creation
- ❌ **Error Handling**: Provides clear error messages and cleanup on failure
- 🎨 **Colored Output**: Uses emojis and colors for better readability

## Backup File Format

Backups are created with the following naming convention:
```
backup_YYYYMMDD_HHMMSS.sql
```

Example: `backup_20250107_143000.sql`

## Troubleshooting

### Common Issues

1. **"pg_dump not found"**
   - Install PostgreSQL client tools (see prerequisites)
   - Ensure PostgreSQL bin directory is in your PATH

2. **"Database is not accessible"**
   - Check if database is running
   - Verify connection parameters (host, port, database name)
   - Ensure user has necessary permissions
   - Check if password is required (set DB_PASSWORD environment variable)

3. **"Permission denied"**
   - Ensure backup directory is writable
   - Check database user permissions

4. **"Backup failed"**
   - Check database logs for errors
   - Verify disk space availability
   - Ensure database is not locked or in use

### Getting Help

For additional help:
1. Check the main project documentation
2. Review Docker Compose logs: `docker-compose logs db`
3. Test database connectivity manually: `pg_isready -h localhost -p 5432 -U postgres`

## Integration with Docker Compose

These scripts can be used alongside the Docker Compose backup service defined in `docker-compose.prod.yml`. The Docker service is designed for automated, continuous backups in production, while these scripts are for manual, on-demand backups during development and testing.