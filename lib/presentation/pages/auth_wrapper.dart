import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import 'auth/login_page.dart';
import 'home/home_page.dart';

/// Widget that handles routing based on authentication state
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _hasTimedOut = false;

  @override
  void initState() {
    super.initState();
    // Set a fallback timeout
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && !_hasTimedOut) {
        setState(() {
          _hasTimedOut = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // If we've timed out waiting, show login page
    if (_hasTimedOut) {
      return const LoginPage();
    }

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
      loading: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Verificando autenticação...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  setState(() {
                    _hasTimedOut = true;
                  });
                },
                child: const Text('Pular verificação'),
              ),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) => const LoginPage(),
    );
  }
}
