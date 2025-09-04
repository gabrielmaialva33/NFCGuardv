-- Enable Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" = 'your-jwt-secret-here';

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL,
    cpf TEXT UNIQUE NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    birth_date TIMESTAMP WITH TIME ZONE,
    gender TEXT,
    zip_code TEXT,
    address TEXT,
    neighborhood TEXT,
    city TEXT,
    state TEXT,
    eight_digit_code TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create used_codes table
CREATE TABLE IF NOT EXISTS used_codes (
    id BIGSERIAL PRIMARY KEY,
    code TEXT NOT NULL,
    user_id UUID REFERENCES auth.users ON DELETE CASCADE,
    used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(code)
);

-- Create nfc_operations table for logging NFC operations
CREATE TABLE IF NOT EXISTS nfc_operations (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
    operation_type TEXT NOT NULL, -- 'write', 'protect', 'unprotect'
    code_used TEXT NOT NULL,
    dataset_number INTEGER,
    success BOOLEAN DEFAULT FALSE,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_profiles_cpf ON profiles(cpf);
CREATE INDEX IF NOT EXISTS idx_profiles_eight_digit_code ON profiles(eight_digit_code);
CREATE INDEX IF NOT EXISTS idx_used_codes_code ON used_codes(code);
CREATE INDEX IF NOT EXISTS idx_used_codes_user_id ON used_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_nfc_operations_user_id ON nfc_operations(user_id);
CREATE INDEX IF NOT EXISTS idx_nfc_operations_created_at ON nfc_operations(created_at);

-- Enable Row Level Security on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE used_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE nfc_operations ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for profiles
CREATE POLICY "Users can view their own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Create RLS policies for used_codes
CREATE POLICY "Users can view their own used codes" ON used_codes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own used codes" ON used_codes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create RLS policies for nfc_operations
CREATE POLICY "Users can view their own NFC operations" ON nfc_operations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own NFC operations" ON nfc_operations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for profiles updated_at
CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create function to handle new user registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, cpf, eight_digit_code)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'cpf', ''),
        COALESCE(NEW.raw_user_meta_data->>'eight_digit_code', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user registration
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();