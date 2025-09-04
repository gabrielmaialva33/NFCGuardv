-- Create users table aligned with UserEntity/UserModel
-- This table stores user profile information that extends Supabase Auth

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