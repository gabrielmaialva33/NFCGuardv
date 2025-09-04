# NFCGuard Supabase Configuration Guide

This guide will help you complete the Supabase setup for the NFCGuard project.

## 🔧 Configuration Steps

### 1. Update Supabase Configuration

Edit `lib/core/config/supabase_config.dart` and replace the placeholder values:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://wfhecwwjfzxhwzfwfwbx.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ACTUAL_ANON_KEY_HERE'; // 👈 Replace this
}
```

**Where to find your anon key:**

1. Go to your Supabase dashboard: https://app.supabase.com/project/wfhecwwjfzxhwzfwfwbx
2. Navigate to Settings → API
3. Copy the `anon public` key

### 2. Apply Database Migrations

Run the migration to create the database schema:

```bash
cd supabase
supabase db push
```

This will create:

- `profiles` table for user data
- `used_codes` table for tracking used NFC codes
- `nfc_operations` table for operation logging
- Row Level Security (RLS) policies
- Necessary indexes and triggers

### 3. Enable Authentication Providers (Optional)

If you want to enable email/password authentication in Supabase dashboard:

1. Go to Authentication → Settings
2. Configure SMTP settings for email confirmations
3. Set site URL to your app's URL

## 🏗️ Architecture Overview

### Database Tables

```sql
-- User profiles with Brazilian-specific fields
profiles (
  id UUID PRIMARY KEY,  -- Links to auth.users
  full_name TEXT,
  cpf TEXT UNIQUE,     -- Brazilian CPF
  email TEXT,
  phone TEXT,
  birth_date TIMESTAMP,
  gender TEXT,
  zip_code TEXT,       -- Brazilian CEP
  address TEXT,
  neighborhood TEXT,
  city TEXT,
  state TEXT,
  eight_digit_code TEXT UNIQUE, -- NFC unique code
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Track used codes to prevent reuse
used_codes (
  id BIGSERIAL PRIMARY KEY,
  code TEXT UNIQUE,
  user_id UUID REFERENCES auth.users,
  used_at TIMESTAMP
);

-- Log all NFC operations for security and analytics
nfc_operations (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users,
  operation_type TEXT, -- 'write', 'protect', 'unprotect'
  code_used TEXT,
  dataset_number INTEGER,
  success BOOLEAN,
  error_message TEXT,
  created_at TIMESTAMP
);
```

### Security Features

- **Row Level Security (RLS)**: Users can only access their own data
- **JWT Authentication**: Secure token-based auth
- **Code uniqueness**: Prevents NFC code reuse across the system
- **Operation logging**: All NFC operations are logged for security

## 🔄 Hybrid Storage Approach

The app uses a hybrid approach:

1. **Primary**: Supabase for cloud storage and real-time sync
2. **Fallback**: Local secure storage for offline access
3. **Sync**: Automatic synchronization when online

### Benefits:

- ✅ Works offline
- ✅ Cloud backup and sync
- ✅ Real-time updates
- ✅ Enhanced security logging
- ✅ Cross-device compatibility

## 🎯 Provider Integration

### Authentication

```dart
// Use the new Supabase-integrated auth provider
final authProvider = SupabaseAuthProvider();

// Sign up
await
authProvider.register
(
fullName: 'João Silva',
cpf: '12345678901',
email: 'joao@example.com',
phone: '11987654321',
birthDate: DateTime(1990, 1, 1),
gender: 'Masculino',
password: 'securePassword123',
);

// Sign in
await authProvider.signIn(
email: 'joao@example.com',
password:
'
securePassword123
'
,
);
```

### NFC Operations

The NFC provider now automatically logs operations to Supabase:

- ✅ Write operations with success/failure
- ✅ Protection operations
- ✅ Code usage tracking
- ✅ Error logging for debugging

## 🔐 Security Considerations

### Environment Variables (Recommended)

For production, consider using environment variables:

```dart
// lib/core/config/supabase_config.dart
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wfhecwwjfzxhwzfwfwbx.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-default-key',
  );
}
```

Then build with:

```bash
flutter build apk --dart-define=SUPABASE_URL=your-url --dart-define=SUPABASE_ANON_KEY=your-key
```

### Data Protection

- Passwords are handled securely by Supabase Auth
- CPF and personal data are encrypted at rest
- All database connections use SSL/TLS
- Row-level security prevents unauthorized access

## 🚀 Testing

### Local Development

1. Start Supabase locally: `supabase start`
2. Access Supabase Studio: http://localhost:54323
3. View email testing: http://localhost:54324

### Production Checklist

- [ ] Update `supabaseAnonKey` with real value
- [ ] Configure SMTP for email notifications
- [ ] Set up proper backup procedures
- [ ] Monitor usage and performance
- [ ] Review security policies

## 📊 Analytics & Monitoring

The app now logs detailed NFC operations:

- Operation success/failure rates
- Most common error types
- User activity patterns
- Code usage statistics

Access this data through:

1. Supabase Dashboard → Database → Tables
2. SQL queries on `nfc_operations` table
3. Built-in analytics in the app (future feature)

## 🔧 Troubleshooting

### Common Issues

**Error: "Invalid API key"**

- Ensure you've updated the `supabaseAnonKey` in the config

**Error: "Table doesn't exist"**

- Run `supabase db push` to apply migrations

**Authentication not working**

- Check if email confirmations are properly configured
- Verify SMTP settings in Supabase dashboard

### Support

For issues specific to this integration:

1. Check the Supabase logs in the dashboard
2. Review Flutter console for error messages
3. Verify network connectivity for API calls

---

The NFCGuard app now has enterprise-grade cloud integration with Supabase! 🎉