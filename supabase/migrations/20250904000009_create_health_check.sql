-- Create health check table for connection testing
-- This table is used by the app to test database connectivity

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