#!/bin/bash

# Run NFCGuard Database Migrations
# This script applies all migrations to the Supabase database

echo "🚀 Running NFCGuard Database Migrations..."

# Database connection details from .env
SUPABASE_URL="https://wfhecwwjfzxhwzfwfwbx.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmaGVjd3dqZnp4aHd6Zndmd2J4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0MTA0MDAsImV4cCI6MjA0MDk4NjQwMH0.Kx8VGFJqY5YWb8Dj4R2LwQ9Xx3Vz7Nn8Pp0Mt6Ee8Zs"

# Supabase Database URL for psql
DB_URL="postgresql://postgres.wfhecwwjfzxhwzfwfwbx:[PASSWORD]@aws-1-sa-east-1.pooler.supabase.com:6543/postgres"

echo "⚠️  Please run these migrations manually in your Supabase Dashboard:"
echo "   Go to: https://supabase.com/dashboard/project/wfhecwwjfzxhwzfwfwbx/sql/new"
echo ""
echo "📁 Migration files to run in order:"
echo ""

# List all migration files in order
for file in supabase/migrations/*.sql; do
    if [ -f "$file" ]; then
        echo "   $(basename "$file")"
    fi
done

echo ""
echo "🔧 Alternatively, if you have the database password:"
echo "   Run: supabase db push"
echo "   Or connect with: psql '$DB_URL'"
echo ""
echo "✅ Migration files are ready in: supabase/migrations/"