#!/bin/sh

# Ensure the database file exists and has correct permissions
if [ -f "/app/data/apps.db" ]; then
  echo "Database file exists, checking permissions..."
  # Change ownership to appuser if it's not already
  if ! stat -c '%U' /app/data/apps.db | grep -q "appuser"; then
    echo "Changing ownership of database file to appuser..."
    chown appuser:appgroup /app/data/apps.db
  fi
else
  echo "Database file does not exist, it will be created by the application"
fi

# Switch to appuser and execute the main command
exec su -s /bin/sh appuser -c "$*"
