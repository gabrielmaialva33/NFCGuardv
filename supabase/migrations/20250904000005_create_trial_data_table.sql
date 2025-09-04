-- Create trial data table for managing app trial periods
-- Tracks device installations and trial period limitations

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