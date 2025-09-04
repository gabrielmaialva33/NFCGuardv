-- NFCGuard Database Schema
-- Initial migration for NFCGuard app

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- User profile data
  full_name TEXT NOT NULL,
  cpf TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  birth_date DATE,
  gender TEXT CHECK (gender IN ('M', 'F', 'Outro')),
  
  -- Address data
  cep TEXT,
  street TEXT,
  number_address TEXT,
  complement TEXT,
  neighborhood TEXT,
  city TEXT,
  state TEXT,
  
  -- User code
  user_code TEXT UNIQUE NOT NULL,
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  trial_mode BOOLEAN DEFAULT false,
  
  PRIMARY KEY (id)
);

-- NFC operation logs
CREATE TABLE public.nfc_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- Operation details
  operation_type TEXT NOT NULL CHECK (operation_type IN ('write', 'read', 'protect', 'unprotect')),
  code_used TEXT NOT NULL,
  dataset_number INTEGER,
  
  -- Result
  success BOOLEAN NOT NULL,
  error_message TEXT,
  
  -- Device info
  device_fingerprint TEXT,
  
  -- NFC data
  tag_uid TEXT,
  tag_type TEXT,
  data_written TEXT
);

-- Used codes tracking
CREATE TABLE public.used_codes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  code TEXT NOT NULL,
  dataset_number INTEGER,
  
  UNIQUE(user_id, code)
);

-- Trial data for security
CREATE TABLE public.trial_data (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  device_fingerprint TEXT NOT NULL,
  installation_date TIMESTAMP WITH TIME ZONE NOT NULL,
  last_check TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  trial_days INTEGER DEFAULT 3,
  
  UNIQUE(user_id, device_fingerprint)
);

-- Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nfc_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.used_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trial_data ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users can only see/edit their own data
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- NFC logs - users can only see their own logs
CREATE POLICY "Users can view own NFC logs" ON public.nfc_logs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own NFC logs" ON public.nfc_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Used codes - users can only see/manage their own codes
CREATE POLICY "Users can view own used codes" ON public.used_codes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own used codes" ON public.used_codes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Trial data - users can only see/manage their own trial data
CREATE POLICY "Users can view own trial data" ON public.trial_data
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own trial data" ON public.trial_data
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own trial data" ON public.trial_data
  FOR UPDATE USING (auth.uid() = user_id);

-- Indexes for better performance
CREATE INDEX idx_users_cpf ON public.users(cpf);
CREATE INDEX idx_users_user_code ON public.users(user_code);
CREATE INDEX idx_users_email ON public.users(email);

CREATE INDEX idx_nfc_logs_user_id ON public.nfc_logs(user_id);
CREATE INDEX idx_nfc_logs_created_at ON public.nfc_logs(created_at);
CREATE INDEX idx_nfc_logs_operation_type ON public.nfc_logs(operation_type);

CREATE INDEX idx_used_codes_user_id ON public.used_codes(user_id);
CREATE INDEX idx_used_codes_code ON public.used_codes(code);

CREATE INDEX idx_trial_data_user_id ON public.trial_data(user_id);
CREATE INDEX idx_trial_data_device_fingerprint ON public.trial_data(device_fingerprint);

-- Functions for updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER handle_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Function to generate user code
CREATE OR REPLACE FUNCTION generate_user_code()
RETURNS TEXT AS $$
DECLARE
  code TEXT;
  exists_check INTEGER;
BEGIN
  LOOP
    -- Generate 8-digit code
    code := LPAD(FLOOR(RANDOM() * 100000000)::TEXT, 8, '0');
    
    -- Check if code already exists
    SELECT COUNT(*) INTO exists_check FROM public.users WHERE user_code = code;
    
    -- Exit loop if code is unique
    EXIT WHEN exists_check = 0;
  END LOOP;
  
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Health check table (for connection testing)
CREATE TABLE public.health_check (
  id SERIAL PRIMARY KEY,
  status TEXT DEFAULT 'ok',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

INSERT INTO public.health_check (status) VALUES ('ok');

-- Grant access to health check for anonymous users
ALTER TABLE public.health_check ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read health check" ON public.health_check FOR SELECT USING (true);