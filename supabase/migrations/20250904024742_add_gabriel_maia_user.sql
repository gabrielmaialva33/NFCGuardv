-- Migration: Add Gabriel Maia test user setup
-- This migration ensures the database is ready for the Gabriel Maia test user

-- Ensure users table exists with all necessary columns
DO $$ 
BEGIN
    -- Check if users table exists, create if not
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users') THEN
        CREATE TABLE users (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            email TEXT UNIQUE NOT NULL,
            full_name TEXT NOT NULL,
            cpf TEXT UNIQUE NOT NULL,
            phone TEXT,
            birth_date DATE,
            gender TEXT,
            cep TEXT,
            street TEXT,
            number_address TEXT,
            complement TEXT,
            neighborhood TEXT,
            city TEXT,
            state TEXT,
            user_code TEXT UNIQUE NOT NULL,
            trial_mode BOOLEAN DEFAULT false,
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW()
        );
    END IF;
END $$;

-- Ensure used_codes table exists
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'used_codes') THEN
        CREATE TABLE used_codes (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            code TEXT UNIQUE NOT NULL,
            used_by UUID REFERENCES users(id),
            used_at TIMESTAMPTZ DEFAULT NOW(),
            dataset_number INTEGER
        );
    END IF;
END $$;

-- Ensure nfc_logs table exists
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'nfc_logs') THEN
        CREATE TABLE nfc_logs (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES users(id),
            operation_type TEXT NOT NULL,
            code_used TEXT,
            dataset_number INTEGER,
            success BOOLEAN DEFAULT false,
            error_message TEXT,
            created_at TIMESTAMPTZ DEFAULT NOW()
        );
    END IF;
END $$;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_cpf ON users(cpf);
CREATE INDEX IF NOT EXISTS idx_users_user_code ON users(user_code);
CREATE INDEX IF NOT EXISTS idx_used_codes_code ON used_codes(code);
CREATE INDEX IF NOT EXISTS idx_nfc_logs_user_id ON nfc_logs(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE used_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE nfc_logs ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for users table
CREATE POLICY IF NOT EXISTS "Users can view their own data" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY IF NOT EXISTS "Users can update their own data" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Create RLS policies for used_codes table
CREATE POLICY IF NOT EXISTS "Users can view used codes" ON used_codes
    FOR SELECT USING (true);

CREATE POLICY IF NOT EXISTS "System can insert used codes" ON used_codes
    FOR INSERT WITH CHECK (true);

-- Create RLS policies for nfc_logs table
CREATE POLICY IF NOT EXISTS "Users can view their own logs" ON nfc_logs
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "System can insert logs" ON nfc_logs
    FOR INSERT WITH CHECK (true);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for users table
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to generate unique user code
CREATE OR REPLACE FUNCTION generate_user_code()
RETURNS TEXT AS $$
DECLARE
    new_code TEXT;
    code_exists BOOLEAN;
BEGIN
    LOOP
        -- Generate 8-digit random code
        new_code := LPAD(FLOOR(RANDOM() * 100000000)::TEXT, 8, '0');
        
        -- Check if code already exists
        SELECT EXISTS(
            SELECT 1 FROM users WHERE user_code = new_code
            UNION
            SELECT 1 FROM used_codes WHERE code = new_code
        ) INTO code_exists;
        
        -- Exit loop if code is unique
        EXIT WHEN NOT code_exists;
    END LOOP;
    
    RETURN new_code;
END;
$$ LANGUAGE plpgsql;