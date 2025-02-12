#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /rails/tmp/pids/server.pid

# Function to wait for database
wait_for_db() {
  echo "Waiting for database to be ready..."
  while ! pg_isready -h db -p 5432 -q; do
    sleep 1
  done
  echo "Database is ready!"
}

# Wait for services
wait_for_db

# Setup database
echo "Setting up database..."
bundle exec rails db:create db:migrate

# Then exec the container's main process
exec "$@"