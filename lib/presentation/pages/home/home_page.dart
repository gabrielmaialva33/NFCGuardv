import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nfc_provider.dart';
import '../../widgets/trial_counter_widget.dart';
import '../auth/login_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          const TrialCounterWidget(),
          const SizedBox(width: 8),
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
        error: (error, stack) => Center(child: Text('Erro: $error')),
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
                    'Bem-vindo, ${user.fullName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Código único: ${user.eightDigitCode}',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    _showCodeDialog(context, 'Gravar tag com dados $dataSet', (code) {
      _executeNfcWrite(context, code, dataSet);
    });
  }

  void _protectNfcTag(BuildContext context) {
    _showCodeDialog(context, 'Proteger tag com senha', (code) {
      _showPasswordDialog(context, code, true);
    });
  }

  void _removeNfcPassword(BuildContext context) {
    _showCodeDialog(context, 'Remover senha da tag', (code) {
      _showPasswordDialog(context, code, false);
    });
  }

  void _showCodeDialog(
    BuildContext context,
    String operation,
    Function(String) onCodeConfirmed,
  ) {
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
                onCodeConfirmed(code);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código deve ter 8 dígitos')),
                );
              }
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _executeNfcWrite(BuildContext context, String code, int dataSet) async {
    final nfcNotifier = ref.read(nfcProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Primeiro verificar se NFC está disponível
    final isAvailable = await nfcNotifier.isNfcAvailable();
    if (!isAvailable) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('NFC não está disponível neste dispositivo'),
          ),
        );
      }
      return;
    }

    // Mostrar dialog de instrução usando o contexto atual se ainda montado
    if (mounted && context.mounted) {
      _showNfcInstructionDialog(context, 'Aproxime o dispositivo da tag NFC');
    }

    // Executar gravação
    await nfcNotifier.writeTagWithCode(code, dataSet);
  }

  void _showPasswordDialog(
    BuildContext context,
    String code,
    bool isProtecting,
  ) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isProtecting ? 'Proteger Tag' : 'Remover Proteção'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isProtecting
                  ? 'Digite uma senha para proteger a tag:'
                  : 'Digite a senha atual da tag:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Senha',
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
            onPressed: () async {
              final password = passwordController.text;
              if (password.isNotEmpty) {
                Navigator.of(context).pop();
                await _executePasswordOperation(
                  context,
                  code,
                  password,
                  isProtecting,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha é obrigatória')),
                );
              }
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Future<void> _executePasswordOperation(
    BuildContext context,
    String code,
    String password,
    bool isProtecting,
  ) async {
    final nfcNotifier = ref.read(nfcProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final isAvailable = await nfcNotifier.isNfcAvailable();
    if (!isAvailable) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('NFC não está disponível neste dispositivo'),
          ),
        );
      }
      return;
    }

    if (mounted && context.mounted) {
      _showNfcInstructionDialog(context, 'Aproxime o dispositivo da tag NFC');
    }

    if (isProtecting) {
      await nfcNotifier.protectTagWithPassword(code, password);
    } else {
      await nfcNotifier.removeTagPassword(code, password);
    }
  }

  void _showNfcInstructionDialog(BuildContext context, String instruction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final nfcState = ref.watch(nfcProvider);

          return AlertDialog(
            title: Text(instruction),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.nfc,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                nfcState.when(
                  data: (status) {
                    switch (status) {
                      case NfcStatus.scanning:
                        return const Text('Procurando tag NFC...');
                      case NfcStatus.writing:
                        return const Text('Gravando dados na tag...');
                      case NfcStatus.success:
                        return const Text('Operação realizada com sucesso!');
                      case NfcStatus.error:
                        return const Text('Erro na operação NFC');
                      case NfcStatus.unavailable:
                        return const Text('NFC não disponível');
                      default:
                        return const Text('Preparando...');
                    }
                  },
                  loading: () => const Text('Preparando...'),
                  error: (error, _) => Text('Erro: $error'),
                ),
                const SizedBox(height: 16),
                nfcState.when(
                  data: (status) {
                    if (status == NfcStatus.success) {
                      return const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      );
                    } else if (status == NfcStatus.error) {
                      return const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 48,
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) =>
                      const Icon(Icons.error, color: Colors.red, size: 48),
                ),
              ],
            ),
            actions: nfcState.when(
              data: (status) {
                if (status == NfcStatus.success ||
                    status == NfcStatus.error ||
                    status == NfcStatus.unavailable) {
                  return [
                    ElevatedButton(
                      onPressed: () {
                        ref.read(nfcProvider.notifier).resetStatus();
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ];
                }
                return [
                  TextButton(
                    onPressed: () {
                      ref.read(nfcProvider.notifier).stopSession();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancelar'),
                  ),
                ];
              },
              loading: () => [
                TextButton(
                  onPressed: () {
                    ref.read(nfcProvider.notifier).stopSession();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
              ],
              error: (_, __) => [
                ElevatedButton(
                  onPressed: () {
                    ref.read(nfcProvider.notifier).resetStatus();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
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
