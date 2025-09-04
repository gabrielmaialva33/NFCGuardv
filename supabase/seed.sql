-- Seed data for NFCGuard application

-- Insert some sample data for development (optional)
-- This file can be used to populate the database with initial test data

-- Example: Insert some reserved codes that should not be used
INSERT INTO used_codes (code, used_at) VALUES 
('00000000', NOW()),
('11111111', NOW()),
('22222222', NOW()),
('33333333', NOW()),
('44444444', NOW()),
('55555555', NOW()),
('66666666', NOW()),
('77777777', NOW()),
('88888888', NOW()),
('99999999', NOW()),
('12345678', NOW()),
('87654321', NOW())
ON CONFLICT (code) DO NOTHING;

-- Add some Brazilian states for reference (optional)
-- You can extend this with a states table if needed for validation