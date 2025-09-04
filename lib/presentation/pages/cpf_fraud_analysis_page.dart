import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nvidia_nim_provider.dart';
import '../../core/constants/app_constants.dart';

class CpfFraudAnalysisPage extends ConsumerStatefulWidget {
  const CpfFraudAnalysisPage({super.key});

  @override
  ConsumerState<CpfFraudAnalysisPage> createState() => _CpfFraudAnalysisPageState();
}

class _CpfFraudAnalysisPageState extends ConsumerState<CpfFraudAnalysisPage> {
  final _cpfController = TextEditingController();

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  String _formatCpf(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length >= 11) {
      cpf = cpf.substring(0, 11);
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
    }
    return cpf;
  }

  Color _getRecommendationColor(String? recommendation) {
    switch (recommendation?.toUpperCase()) {
      case 'ACEITAR':
        return Colors.green;
      case 'REVISAR':
        return Colors.orange;
      case 'REJEITAR':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getRecommendationIcon(String? recommendation) {
    switch (recommendation?.toUpperCase()) {
      case 'ACEITAR':
        return Icons.check_circle;
      case 'REVISAR':
        return Icons.warning;
      case 'REJEITAR':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cpfState = ref.watch(cpfValidationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise Anti-Fraude CPF'),
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
                        'Validação Inteligente de CPF',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Text(
                        'Utilize AI avançada para detectar fraudes e validar CPFs com alta precisão',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      TextField(
                        controller: _cpfController,
                        decoration: const InputDecoration(
                          labelText: 'Digite o CPF',
                          hintText: '000.000.000-00',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final formatted = _formatCpf(value);
                          if (formatted != value) {
                            _cpfController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: cpfState.isLoading ? null : () {
                                if (_cpfController.text.isNotEmpty) {
                                  ref
                                      .read(cpfValidationStateProvider.notifier)
                                      .validateCpfWithFraud(_cpfController.text);
                                }
                              },
                              icon: cpfState.isLoading 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.security),
                              label: Text(cpfState.isLoading ? 'Analisando...' : 'Analisar CPF'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              _cpfController.clear();
                              ref.read(cpfValidationStateProvider.notifier).reset();
                            },
                            icon: const Icon(Icons.clear),
                            tooltip: 'Limpar',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              cpfState.when(
                data: (result) {
                  if (result == null) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Digite um CPF para começar a análise',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final isValid = result['valido'] as bool? ?? false;
                  final isFraud = result['fraudulento'] as bool? ?? true;
                  final score = result['score_confiabilidade'] as int? ?? 0;
                  final recommendation = result['recomendacao'] as String? ?? 'REJEITAR';
                  final reasons = (result['motivos'] as List<dynamic>?)?.cast<String>() ?? [];
                  final analysis = result['analise_detalhada'] as String? ?? '';

                  return Column(
                    children: [
                      // Status geral
                      Card(
                        color: _getRecommendationColor(recommendation).withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          child: Row(
                            children: [
                              Icon(
                                _getRecommendationIcon(recommendation),
                                size: 48,
                                color: _getRecommendationColor(recommendation),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recommendation.toUpperCase(),
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: _getRecommendationColor(recommendation),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Score de Confiabilidade: $score/100',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Detalhes da validação
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detalhes da Análise',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    isValid ? Icons.check_circle : Icons.cancel,
                                    color: isValid ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isValid ? 'CPF Válido' : 'CPF Inválido',
                                    style: TextStyle(
                                      color: isValid ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    isFraud ? Icons.warning : Icons.verified_user,
                                    color: isFraud ? Colors.red : Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isFraud ? 'Padrão Fraudulento Detectado' : 'Sem Indícios de Fraude',
                                    style: TextStyle(
                                      color: isFraud ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Motivos
                      if (reasons.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.defaultPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Motivos da Análise',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 12),
                                ...reasons.map((reason) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.arrow_right,
                                        size: 20,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          reason,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      // Análise detalhada
                      if (analysis.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.defaultPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Análise Detalhada da AI',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: SelectableText(
                                    analysis,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Analisando CPF com AI...',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                error: (error, stack) => Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error,
                          size: 48,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro na análise: $error',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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