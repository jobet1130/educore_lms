#!/bin/bash
echo "💾 Creating comprehensive production backup..."

# Set default values if environment variables are not set
DB_USER=${DB_USER:-postgres}
DB_NAME=${DB_NAME:-educore_db}
PGPASSWORD=${DB_PASSWORD:-weaknaweak27}

# Export password for pg_dump
export PGPASSWORD

# Create backup with timestamp
BACKUP_FILE="/backups/backup_$(date +%Y%m%d_%H%M%S).sql"

echo "Creating backup: $BACKUP_FILE"
pg_dump -h db -U "$DB_USER" -d "$DB_NAME" > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Backup completed successfully: $BACKUP_FILE"
    echo "Cleaning up old backups (older than 7 days)..."
    find /backups -name '*.sql' -mtime +7 -delete
    echo "✅ Cleanup completed"
else
    echo "❌ Backup failed"
    exit 1
fi