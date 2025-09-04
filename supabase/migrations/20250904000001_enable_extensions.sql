-- Enable required PostgreSQL extensions
-- This migration enables the UUID extension needed for generating UUIDs

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";