#!/bin/bash

# Set variables

HOST="192.168.1.125"
PORT="32671"
USER="postgres"
PASSWORD="dd91-58cc-414d-b90"

BACKUP_DIR="/home/backup01/database-backups/bhoganti_databases_dev_shanto"
TIMESTAMP=$(date +"%Y-%m-%d_%H:%M:%S")
BACKUP_FILE="$BACKUP_DIR/backup_all_$TIMESTAMP.sql"

#BACKUP_NAME="$BACKUP_DIR/$(date +\%Y-\%m-\%d_%H-%M)_$DB_NAME.sql"
#LOG_FILE="/home/shanto/backup_error.log"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1286233287135592480/D2eoPQ3ACbiOAqADqYttZ_d5zSKG4znwNmReKEMPDhk_mzg1GOYadz8xt7jy7YmfoiPX"
BACKUP_AGE_DAYS=15
BACKUP_AGE_MINUTES=$((BACKUP_AGE_DAYS * 24 * 60))  # Age of backups to keep in minutes (15 days)


# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"


# Perform the backup for all databases
PGPASSWORD="$PASSWORD" pg_dumpall -h "$HOST" -p "$PORT" -U "$USER" > "$BACKUP_FILE"


# Run pg_dump to create a backup

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILE"

    # Send success message to Discord
    /snap/bin/curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"Bhoganti Dev Backup successful: $TIMESTAMP\"}" \
         $DISCORD_WEBHOOK_URL
else
    echo "Backup failed"

-    # Send failure message to Discord
   /snap/bin/curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"Backup failed for database: Check the log at Log File\"}" \
         $DISCORD_WEBHOOK_URL
    exit 1
fi

# Cleanup old backups (delete backups older than specified minutes)
find "$BACKUP_DIR" -type f -name "*backup_all_*" -mmin +$BACKUP_AGE_MINUTES -exec rm {} \;

# Send message to Discord about old backups deletion
	/snap/bin/curl -H "Content-Type: application/json" \
     	-X POST \
     	-d "{\"content\": \"Backups older than $BACKUP_AGE_DAYS DAYS have been deleted.\"}" \
     	$DISCORD_WEBHOOK_URL

# Echo the cleanup result
echo "Old backups older than $BACKUP_AGE_DAYS days have been deleted."