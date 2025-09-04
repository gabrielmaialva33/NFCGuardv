-- Add Gabriel Maia test user
-- This migration creates a test user with the specified details
-- Note: The auth user must be created separately in Supabase Auth

-- First, let's create the auth user (this would normally be done through Supabase Auth)
-- For testing purposes, we'll insert directly into auth.users
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