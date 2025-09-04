-- Enable Row Level Security (RLS) for all tables
-- Ensures users can only access their own data

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nfc_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.used_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trial_data ENABLE ROW LEVEL SECURITY;