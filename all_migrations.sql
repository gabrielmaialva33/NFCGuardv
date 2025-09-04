-- ========================================
-- NFCGuard Database Setup - All Migrations
-- Run this file in your Supabase SQL Editor
-- ========================================

-- Migration 1: Enable Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Migration 2: Create Users Table
CREATE TABLE public.users (
  -- Primary key linked to auth.users
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- User profile data (aligned with UserEntity)
  full_name TEXT NOT NULL,
  cpf TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  birth_date DATE NOT NULL,
  gender TEXT NOT NULL CHECK (gender IN ('masculino', 'feminino', 'outro')),
  
  -- Address data (aligned with UserEntity field names)
  zip_code TEXT NOT NULL,
  address TEXT NOT NULL,
  neighborhood TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  
  -- 8-digit unique code for NFC operations
  eight_digit_code TEXT UNIQUE NOT NULL,
  
  -- Status flags
  is_active BOOLEAN DEFAULT true NOT NULL,
  trial_mode BOOLEAN DEFAULT false NOT NULL
);

-- Add indexes for performance
CREATE INDEX idx_users_cpf ON public.users(cpf);
CREATE INDEX idx_users_eight_digit_code ON public.users(eight_digit_code);
CREATE INDEX idx_users_email ON public.users(email);

-- Create function for automatic updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add trigger to automatically update updated_at
CREATE TRIGGER handle_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Migration 3: Create NFC Logs Table
CREATE TABLE public.nfc_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- Operation details
  operation_type TEXT NOT NULL CHECK (operation_type IN ('write', 'read', 'protect', 'unprotect')),
  code_used TEXT NOT NULL,
  dataset_number INTEGER,
  
  -- Operation result
  success BOOLEAN NOT NULL,
  error_message TEXT,
  
  -- Device and NFC tag information
  device_fingerprint TEXT,
  tag_uid TEXT,
  tag_type TEXT,
  data_written TEXT
);

-- Add indexes for performance
CREATE INDEX idx_nfc_logs_user_id ON public.nfc_logs(user_id);
CREATE INDEX idx_nfc_logs_created_at ON public.nfc_logs(created_at);
CREATE INDEX idx_nfc_logs_operation_type ON public.nfc_logs(operation_type);
CREATE INDEX idx_nfc_logs_code_used ON public.nfc_logs(code_used);

-- Migration 4: Create Used Codes Table
CREATE TABLE public.used_codes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- Code tracking
  code TEXT NOT NULL,
  dataset_number INTEGER,
  used_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- Ensure a user can't reuse the same code
  UNIQUE(user_id, code)
);

-- Add indexes for performance
CREATE INDEX idx_used_codes_user_id ON public.used_codes(user_id);
CREATE INDEX idx_used_codes_code ON public.used_codes(code);
CREATE INDEX idx_used_codes_used_at ON public.used_codes(used_at);

-- Migration 5: Create Trial Data Table
CREATE TABLE public.trial_data (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- Device and trial information
  device_fingerprint TEXT NOT NULL,
  installation_date TIMESTAMP WITH TIME ZONE NOT NULL,
  last_check TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  trial_days INTEGER DEFAULT 3 NOT NULL,
  
  -- Ensure one trial per user per device
  UNIQUE(user_id, device_fingerprint)
);

-- Add indexes for performance
CREATE INDEX idx_trial_data_user_id ON public.trial_data(user_id);
CREATE INDEX idx_trial_data_device_fingerprint ON public.trial_data(device_fingerprint);
CREATE INDEX idx_trial_data_installation_date ON public.trial_data(installation_date);

-- Migration 6: Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nfc_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.used_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trial_data ENABLE ROW LEVEL SECURITY;

-- Migration 7: Create RLS Policies
-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile (during registration)
CREATE POLICY "Users can insert own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Users can view their own NFC operation logs
CREATE POLICY "Users can view own NFC logs" ON public.nfc_logs
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own NFC operation logs
CREATE POLICY "Users can insert own NFC logs" ON public.nfc_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can view their own used codes
CREATE POLICY "Users can view own used codes" ON public.used_codes
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own used codes
CREATE POLICY "Users can insert own used codes" ON public.used_codes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can view their own trial data
CREATE POLICY "Users can view own trial data" ON public.trial_data
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own trial data
CREATE POLICY "Users can insert own trial data" ON public.trial_data
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own trial data
CREATE POLICY "Users can update own trial data" ON public.trial_data
  FOR UPDATE USING (auth.uid() = user_id);

-- Migration 8: Create Helper Functions
-- Function to generate a unique 8-digit code
CREATE OR REPLACE FUNCTION generate_eight_digit_code()
RETURNS TEXT AS $$
DECLARE
  code TEXT;
  exists_check INTEGER;
BEGIN
  LOOP
    -- Generate 8-digit code (padded with leading zeros)
    code := LPAD(FLOOR(RANDOM() * 100000000)::TEXT, 8, '0');
    
    -- Check if code already exists in users table
    SELECT COUNT(*) INTO exists_check FROM public.users WHERE eight_digit_code = code;
    
    -- Exit loop if code is unique
    EXIT WHEN exists_check = 0;
  END LOOP;
  
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Function to check if a code is already used by a user
CREATE OR REPLACE FUNCTION is_code_used_by_user(user_id UUID, code TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  code_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO code_count 
  FROM public.used_codes 
  WHERE used_codes.user_id = is_code_used_by_user.user_id 
    AND used_codes.code = is_code_used_by_user.code;
  
  RETURN code_count > 0;
END;
$$ LANGUAGE plpgsql;

-- Migration 9: Create Health Check Table
CREATE TABLE public.health_check (
  id SERIAL PRIMARY KEY,
  status TEXT DEFAULT 'ok' NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Insert initial health check record
INSERT INTO public.health_check (status) VALUES ('ok');

-- Enable RLS for health check table
ALTER TABLE public.health_check ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read health check (for connection testing)
CREATE POLICY "Anyone can read health check" ON public.health_check 
  FOR SELECT USING (true);

-- Migration 10: Add Gabriel Maia Test User
-- Note: You may need to create the auth user separately
-- First, let's create the auth user (this would normally be done through Supabase Auth)
INSERT INTO auth.users (
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'authenticated',
  'authenticated',
  'gabriel.maia@test.com',
  crypt('123456', gen_salt('bf')), -- Password: 123456
  NOW(),
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

-- Now create the user profile
INSERT INTO public.users (
  id,
  full_name,
  cpf,
  email,
  phone,
  birth_date,
  gender,
  zip_code,
  address,
  neighborhood,
  city,
  state,
  eight_digit_code,
  trial_mode,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Gabriel Maia',
  '38738734869',
  'gabriel.maia@test.com',
  '15999123456',
  '1999-02-23',
  'masculino',
  '18300270',
  'R. Bernardino de Campos, 809',
  'Centro',
  'Capão Bonito',
  'SP',
  '69550617',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Add Gabriel's code to used codes to prevent reuse
INSERT INTO public.used_codes (
  user_id,
  code,
  used_at
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '69550617',
  NOW()
) ON CONFLICT (user_id, code) DO NOTHING;

-- ========================================
-- SETUP COMPLETE! 🎉
-- ========================================