import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/environment_config.dart';
import 'core/constants/app_constants.dart';
import 'core/services/trial_guard_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/trial_expired_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration from .env file
  await EnvironmentConfig.initialize();

  // Initialize Supabase with secure configuration
  try {
    final supabaseUrl = await EnvironmentConfig.getSupabaseUrl();
    final supabaseKey = await EnvironmentConfig.getSupabaseAnonKey();
    
    if (supabaseUrl != null && supabaseKey != null) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
    }
  } catch (e) {
    // If Supabase initialization fails, continue without it for offline mode
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(const ProviderScope(child: NFCGuardApp()));
}

class NFCGuardApp extends StatelessWidget {
  const NFCGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const TrialGuard(child: SplashPage()),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Widget that checks trial status before allowing app access
class TrialGuard extends StatefulWidget {
  final Widget child;

  const TrialGuard({super.key, required this.child});

  @override
  State<TrialGuard> createState() => _TrialGuardState();
}

class _TrialGuardState extends State<TrialGuard> {
  bool _isLoading = true;
  bool _isTrialActive = false;

  @override
  void initState() {
    super.initState();
    _checkTrialStatus();
  }

  Future<void> _checkTrialStatus() async {
    try {
      final isActive = await TrialGuardService.isTrialActive();
      if (mounted) {
        setState(() {
          _isTrialActive = isActive;
          _isLoading = false;
        });
      }
    } catch (e) {
      // In case of error, be conservative and block access
      if (mounted) {
        setState(() {
          _isTrialActive = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Verificando licença...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isTrialActive) {
      return const TrialExpiredPage();
    }

    return widget.child;
  }
}
