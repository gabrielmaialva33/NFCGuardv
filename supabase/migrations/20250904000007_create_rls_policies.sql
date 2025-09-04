-- Create Row Level Security (RLS) policies
-- These policies ensure users can only access their own data

-- ========================================
-- USERS TABLE POLICIES
-- ========================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile (during registration)
CREATE POLICY "Users can insert own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ========================================
-- NFC LOGS TABLE POLICIES
-- ========================================

-- Users can view their own NFC operation logs
CREATE POLICY "Users can view own NFC logs" ON public.nfc_logs
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own NFC operation logs
CREATE POLICY "Users can insert own NFC logs" ON public.nfc_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ========================================
-- USED CODES TABLE POLICIES
-- ========================================

-- Users can view their own used codes
CREATE POLICY "Users can view own used codes" ON public.used_codes
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own used codes
CREATE POLICY "Users can insert own used codes" ON public.used_codes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ========================================
-- TRIAL DATA TABLE POLICIES
-- ========================================

-- Users can view their own trial data
CREATE POLICY "Users can view own trial data" ON public.trial_data
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own trial data
CREATE POLICY "Users can insert own trial data" ON public.trial_data
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own trial data
CREATE POLICY "Users can update own trial data" ON public.trial_data
  FOR UPDATE USING (auth.uid() = user_id);