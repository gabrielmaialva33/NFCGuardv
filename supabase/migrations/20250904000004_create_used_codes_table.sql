-- Create used codes tracking table
-- Prevents reuse of 8-digit codes and tracks dataset assignments

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