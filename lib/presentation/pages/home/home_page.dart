import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nfc_provider.dart';
import '../auth/login_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: authState.when(
        data: (user) => user != null
            ? _buildMainContent(context, user)
            : const Center(child: Text('Usuário não encontrado')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erro: $error'),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo, ${user.nomeCompleto}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Código único: ${user.codigo8Digitos}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Gravar Tags NFC',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: List.generate(
              AppConstants.maxTagDataSets,
              (index) => _buildNfcButton(
                context,
                'Gravar tag com\ndados ${index + 1}',
                () => _writeNfcTag(context, index + 1),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Gerenciar Tags',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNfcButton(
                  context,
                  'Proteger tag\ncom senha',
                  () => _protectNfcTag(context),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNfcButton(
                  context,
                  'Remover senha\nda tag',
                  () => _removeNfcPassword(context),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNfcButton(
    BuildContext context,
    String text,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        foregroundColor: color != null 
            ? Colors.white 
            : Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nfc,
            size: 32,
            color: color != null 
                ? Colors.white 
                : Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _writeNfcTag(BuildContext context, int dataSet) {
    _showCodeDialog(context, 'Gravar tag com dados $dataSet');
  }

  void _protectNfcTag(BuildContext context) {
    _showCodeDialog(context, 'Proteger tag com senha');
  }

  void _removeNfcPassword(BuildContext context) {
    _showCodeDialog(context, 'Remover senha da tag');
  }

  void _showCodeDialog(BuildContext context, String operation) {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(operation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite seu código de 8 dígitos:'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: const InputDecoration(
                hintText: '00000000',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text;
              if (code.length == 8) {
                Navigator.of(context).pop();
                _processNfcOperation(context, operation, code);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Código deve ter 8 dígitos'),
                  ),
                );
              }
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _processNfcOperation(BuildContext context, String operation, String code) {
    // Por enquanto, apenas mostrar que seria executada a operação NFC
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$operation - Código: $code\n(Funcionalidade NFC será implementada)'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar saída'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}