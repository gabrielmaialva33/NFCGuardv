-- Create helper functions for the NFCGuard application

-- ========================================
-- GENERATE UNIQUE 8-DIGIT CODE FUNCTION
-- ========================================

-- Function to generate a unique 8-digit code
-- Ensures no duplicate codes are generated for users
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

-- ========================================
-- CODE VALIDATION FUNCTIONS
-- ========================================

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