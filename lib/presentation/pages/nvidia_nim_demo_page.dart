import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nvidia_nim_provider.dart';
import '../../core/constants/app_constants.dart';

class NvidiaNimDemoPage extends ConsumerStatefulWidget {
  const NvidiaNimDemoPage({super.key});

  @override
  ConsumerState<NvidiaNimDemoPage> createState() => _NvidiaNimDemoPageState();
}

class _NvidiaNimDemoPageState extends ConsumerState<NvidiaNimDemoPage> {
  final _promptController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nimState = ref.watch(nvidiaNimStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NVIDIA NIM Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chat com NVIDIA NIM',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      TextField(
                        controller: _promptController,
                        decoration: const InputDecoration(
                          labelText: 'Digite sua pergunta',
                          hintText: 'Ex: Como gerar códigos seguros para NFC?',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      ElevatedButton(
                        onPressed: () {
                          if (_promptController.text.isNotEmpty) {
                            ref
                                .read(nvidiaNimStateProvider.notifier)
                                .generateResponse(_promptController.text);
                          }
                        },
                        child: const Text('Enviar Pergunta'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analisar Código de Segurança',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Código para analisar',
                          hintText: 'Ex: ABC123XY',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      ElevatedButton(
                        onPressed: () {
                          if (_codeController.text.isNotEmpty) {
                            ref
                                .read(nvidiaNimStateProvider.notifier)
                                .analyzeSecurityCode(_codeController.text);
                          }
                        },
                        child: const Text('Analisar Código'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gerar Código Seguro',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(nvidiaNimStateProvider.notifier)
                              .generateSecureCode(
                                length: AppConstants.codeLength,
                                includeNumbers: true,
                                includeLetters: true,
                                includeSymbols: false,
                              );
                        },
                        child: const Text('Gerar Código de 8 Caracteres'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resposta da IA',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      nimState.when(
                        data: (response) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          ),
                          child: SelectableText(
                            response.isEmpty ? 'Nenhuma resposta ainda...' : response,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          ),
                          child: Text(
                            'Erro: $error',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ),
                      if (!nimState.isLoading) ...[
                        const SizedBox(height: AppConstants.defaultPadding),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(nvidiaNimStateProvider.notifier).reset();
                          },
                          child: const Text('Limpar Resposta'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}