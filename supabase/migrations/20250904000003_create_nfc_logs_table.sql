-- Create NFC operation logs table
-- Tracks all NFC read/write operations performed by users

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