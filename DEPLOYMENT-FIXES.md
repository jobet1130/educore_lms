# Deployment Pipeline Fixes

## Issue Summary

The deployment pipeline was experiencing failures during database migrations with the error:
```
Error response from daemon: Container e72ae96030b95d78f106386faee15c7cf50c6aa50015e1a286047f402868af37 is restarting, wait until the container is running
Error: Process completed with exit code 1.
```

Additionally, there were warnings about unset environment variables and missing `.env.prod` file.

## Root Causes Identified

### 1. Environment Variable Mismatch
- The `docker-compose.prod.yml` file expected `SECRET_KEY`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, and `ALLOWED_HOSTS`
- The deployment workflow was creating `DJANGO_SECRET_KEY` instead of `SECRET_KEY`
- Missing database-specific environment variables in the `.env.prod` file

### 2. Insufficient Container Startup Time
- The workflow waited only 30 seconds for services to be healthy
- Production containers have a 40-second health check start period
- Database migrations were attempted before containers were fully ready

### 3. Lack of Robust Error Handling
- No retry logic for failed operations
- No specific database connectivity checks
- No container status validation before executing commands

## Fixes Applied

### 1. Fixed Environment Variable Creation

**File:** `.github/workflows/deploy.yml`

**Changes:**
- Changed `DJANGO_SECRET_KEY` to `SECRET_KEY` to match Docker Compose expectations
- Added missing database configuration variables:
  - `DB_NAME`
  - `DB_USER` 
  - `DB_PASSWORD`
  - `DB_HOST=db`
  - `DB_PORT=5432`
- Added security settings:
  - `ALLOWED_HOSTS`
  - `DEBUG=0`
  - `DJANGO_LOG_LEVEL=ERROR`

### 2. Enhanced Container Health Checks

**Changes:**
- Increased initial wait time from 30 to 60 seconds
- Added iterative health check loop (up to 12 attempts, 10 seconds each)
- Added container status validation before proceeding
- Improved logging for debugging container issues

### 3. Added Database Connectivity Verification

**Changes:**
- Added `pg_isready` check before running migrations
- Implemented retry logic for database connectivity (up to 10 attempts)
- Added 5-second delays between connectivity checks

### 4. Implemented Retry Logic for Critical Operations

**Database Migrations:**
- Added retry logic (up to 3 attempts)
- 10-second delay between retry attempts
- Clear success/failure messaging

**Static Files Collection:**
- Added retry logic (up to 3 attempts)
- 5-second delay between retry attempts
- Container status validation before execution

### 5. Enhanced Error Reporting

**Changes:**
- Added container log output when failures occur
- Improved status messages with emojis for better visibility
- Added detailed progress reporting during health checks

## Expected Outcomes

1. **Resolved Environment Variable Issues:**
   - Containers will start successfully with proper configuration
   - No more warnings about unset variables
   - Proper database connectivity

2. **Eliminated Container Restart Errors:**
   - Sufficient time for containers to fully initialize
   - Database connectivity verified before migrations
   - Retry logic handles temporary failures

3. **Improved Deployment Reliability:**
   - Robust error handling and recovery
   - Better visibility into deployment progress
   - Reduced likelihood of deployment failures

## Testing Recommendations

1. **Test the fixed deployment workflow:**
   ```bash
   # Trigger a deployment to production environment
   git push origin main
   ```

2. **Monitor the deployment logs for:**
   - Successful environment file creation
   - Container health check progress
   - Database connectivity verification
   - Successful migration execution

3. **Verify environment variables are properly set:**
   ```bash
   # Check container environment
   docker-compose -f docker-compose.prod.yml exec web env | grep -E "SECRET_KEY|DB_|ALLOWED_HOSTS"
   ```

## Additional Recommendations

1. **Repository Secrets Configuration:**
   Ensure the following secrets are properly configured in GitHub:
   - `DJANGO_SECRET_KEY`
   - `DB_NAME`
   - `DB_USER`
   - `DB_PASSWORD`
   - `ALLOWED_HOSTS`
   - `DATABASE_URL`

2. **Monitoring:**
   - Set up alerts for deployment failures
   - Monitor container health metrics
   - Track deployment success rates

3. **Documentation:**
   - Update deployment runbooks
   - Document troubleshooting procedures
   - Maintain environment variable reference

## Additional Fix: Local Backup Issues

### 4. Fixed Local Environment Variable Warnings

**Problem:** Running backup commands locally caused warnings about unset environment variables and missing `.env.prod` file.

**Root Cause:** The `docker-compose.prod.yml` file required environment variables from `.env.prod` file, which is not committed to the repository for security reasons.

**Solution:**
- Added default values to all environment variables in `docker-compose.prod.yml`
- Made `.env.prod` file optional by commenting out the `env_file` directive
- Created local backup scripts that work without production environment setup

**Changes Made:**
- Updated `docker-compose.prod.yml` to include default values for:
  - `SECRET_KEY` (with development default)
  - `DB_USER`, `DB_PASSWORD`, `DB_NAME` (with postgres defaults)
  - `ALLOWED_HOSTS` (with localhost defaults)
- Created `backup-scripts/` directory with:
  - `local-backup.sh` (Linux/macOS backup script)
  - `local-backup.ps1` (Windows PowerShell backup script)
  - `README.md` (Documentation for backup scripts)

### 5. Fixed Django Settings Module Structure

**Problem:** Performance testing workflow and other CI/CD processes were failing with `ModuleNotFoundError: No module named 'educore_lms.settings.testing'` because the settings was a single file instead of a package structure.

**Root Cause:** The GitHub workflows expected `educore_lms.settings.testing` module but the project only had a single `settings.py` file, not a settings package with separate modules for different environments.

**Solution:**
- Converted single `settings.py` file into a settings package structure
- Created `settings/base.py` with the original settings
- Created `settings/testing.py` with test-specific configurations
- Created `settings/production.py` with production-specific configurations
- Added `settings/__init__.py` to maintain backward compatibility

**Changes Made:**
- Moved `educore_lms/settings.py` to `educore_lms/settings/base.py`
- Created `educore_lms/settings/__init__.py` that imports from base.py
- Created `educore_lms/settings/testing.py` with:
  - SQLite in-memory database for faster tests
  - Simplified password hashers for testing
  - Disabled logging during tests
  - Test-specific cache and email backends
- Created `educore_lms/settings/production.py` with:
  - Enhanced security settings
  - Production logging configuration
  - Redis cache configuration
  - SMTP email configuration

## Files Modified

- `.github/workflows/deploy.yml` - Enhanced deployment workflow with fixes
- `docker-compose.prod.yml` - Added default environment variables and optional .env.prod
- `backup-scripts/local-backup.sh` - New local backup script for Unix systems
- `backup-scripts/local-backup.ps1` - New local backup script for Windows
- `backup-scripts/README.md` - Documentation for backup scripts
- `educore_lms/settings/base.py` - Moved from settings.py, contains base configuration
- `educore_lms/settings/__init__.py` - Package initialization for backward compatibility
- `educore_lms/settings/testing.py` - Test-specific Django settings
- `educore_lms/settings/production.py` - Production-specific Django settings
- `DEPLOYMENT-FIXES.md` - This documentation file

---

*Generated on: $(date)*
*Issue Resolution: Container restart errors, environment variable mismatches, and Django settings module structure*