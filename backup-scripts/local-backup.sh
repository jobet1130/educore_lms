#!/bin/bash

# Local backup script for development/testing
# This script can be used to create backups without requiring production environment variables

set -e

# Default values for local development
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-educore_lms}
DB_USER=${DB_USER:-postgres}
BACKUP_DIR=${BACKUP_DIR:-./backups}

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.sql"

echo "💾 Creating backup: $BACKUP_FILE"
echo "📊 Database: $DB_NAME on $DB_HOST:$DB_PORT"
echo "👤 User: $DB_USER"

# Check if database is accessible
if command -v pg_isready >/dev/null 2>&1; then
    echo "🔍 Checking database connectivity..."
    if ! pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; then
        echo "❌ Database is not accessible. Please ensure:"
        echo "   - Database is running"
        echo "   - Connection parameters are correct"
        echo "   - User has necessary permissions"
        exit 1
    fi
    echo "✅ Database is accessible"
else
    echo "⚠️  pg_isready not found, skipping connectivity check"
fi

# Create backup
if command -v pg_dump >/dev/null 2>&1; then
    echo "📦 Creating database backup..."
    if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" > "$BACKUP_FILE"; then
        echo "✅ Backup created successfully: $BACKUP_FILE"
        echo "📏 Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
    else
        echo "❌ Backup failed"
        rm -f "$BACKUP_FILE"
        exit 1
    fi
else
    echo "❌ pg_dump not found. Please install PostgreSQL client tools."
    exit 1
fi

# Clean up old backups (keep last 7 days)
echo "🧹 Cleaning up old backups..."
find "$BACKUP_DIR" -name "backup_*.sql" -mtime +7 -delete 2>/dev/null || true
echo "✅ Cleanup completed"

echo "🎉 Backup process completed successfully!"