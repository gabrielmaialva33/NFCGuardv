import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_provider.dart';
import '../providers/supabase_auth_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Map<String, dynamic>? _syncStatus;
  Map<String, dynamic>? _stats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final syncNotifier = ref.read(syncNotifierProvider.notifier);
      final syncStatus = await syncNotifier.getSyncStatus();
      final stats = await syncNotifier.getStats();
      
      if (mounted) {
        setState(() {
          _syncStatus = syncStatus;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _performSync() async {
    try {
      await ref.read(syncNotifierProvider.notifier).performFullSync();
      _showSnackBar('Sincronização concluída com sucesso!', Colors.green);
      await _loadStatus();
    } catch (e) {
      _showSnackBar('Erro na sincronização: $e', Colors.red);
    }
  }

  Future<void> _exportData() async {
    try {
      final data = await ref.read(syncNotifierProvider.notifier).exportData();
      if (data != null) {
        await Clipboard.setData(ClipboardData(text: data));
        _showSnackBar('Dados exportados para área de transferência!', Colors.green);
      } else {
        _showSnackBar('Falha ao exportar dados', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Erro ao exportar: $e', Colors.red);
    }
  }

  Future<void> _importData() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData?.text == null) {
      _showSnackBar('Nenhum dado na área de transferência', Colors.orange);
      return;
    }

    final confirm = await _showConfirmDialog(
      'Confirmar Importação',
      'Isso substituirá todos os dados locais. Continuar?',
    );

    if (confirm == true) {
      try {
        final success = await ref.read(syncNotifierProvider.notifier)
            .importData(clipboardData!.text!);
        
        if (success) {
          _showSnackBar('Dados importados com sucesso!', Colors.green);
          await _loadStatus();
        } else {
          _showSnackBar('Falha ao importar dados', Colors.red);
        }
      } catch (e) {
        _showSnackBar('Erro ao importar: $e', Colors.red);
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await _showConfirmDialog(
      'Confirmar Logout',
      'Deseja sair da conta? Todos os dados locais serão limpos.',
    );

    if (confirm == true) {
      try {
        await ref.read(supabaseAuthProvider.notifier).logout();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        _showSnackBar('Erro ao sair: $e', Colors.red);
      }
    }
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncNotifierProvider);
    final authState = ref.watch(supabaseAuthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Section
                  _buildUserInfoSection(authState),
                  const SizedBox(height: 24),

                  // Sync Status Section
                  _buildSyncStatusSection(syncState),
                  const SizedBox(height: 24),

                  // Statistics Section
                  _buildStatsSection(),
                  const SizedBox(height: 24),

                  // Actions Section
                  _buildActionsSection(),
                  const SizedBox(height: 24),

                  // Data Management Section
                  _buildDataManagementSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoSection(AsyncValue authState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações da Conta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            authState.when(
              data: (user) => user != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nome: ${user.fullName}'),
                        Text('Email: ${user.email}'),
                        Text('CPF: ${user.cpf}'),
                        Text('Código: ${user.eightDigitCode}'),
                      ],
                    )
                  : const Text('Usuário não autenticado'),
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Erro: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusSection(AsyncValue<SyncStatus> syncState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status da Sincronização',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getSyncIcon(syncState.value ?? SyncStatus.idle),
                  color: _getSyncColor(syncState.value ?? SyncStatus.idle),
                ),
                const SizedBox(width: 8),
                Text(_getSyncStatusText(syncState.value ?? SyncStatus.idle)),
              ],
            ),
            const SizedBox(height: 8),
            if (_syncStatus != null) ...[
              Text('Conectado: ${_syncStatus!['is_connected'] ? 'Sim' : 'Não'}'),
              Text('Autenticado: ${_syncStatus!['is_authenticated'] ? 'Sim' : 'Não'}'),
              if (_syncStatus!['last_sync'] != null)
                Text('Última sincronização: ${_formatDate(_syncStatus!['last_sync'])}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_stats == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_stats!['local']['used_codes'] ?? 0}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('Códigos Locais'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${_stats!['cloud']['used_codes'] ?? 0}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('Códigos na Nuvem'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _performSync,
                icon: const Icon(Icons.sync),
                label: const Text('Sincronizar Agora'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gerenciamento de Dados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportData,
                icon: const Icon(Icons.download),
                label: const Text('Exportar Dados'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _importData,
                icon: const Icon(Icons.upload),
                label: const Text('Importar Dados'),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Sair da Conta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSyncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Icons.sync_disabled;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.success:
        return Icons.sync_alt;
      case SyncStatus.error:
        return Icons.sync_problem;
    }
  }

  Color _getSyncColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Colors.grey;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
    }
  }

  String _getSyncStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Inativo';
      case SyncStatus.syncing:
        return 'Sincronizando...';
      case SyncStatus.success:
        return 'Sincronizado';
      case SyncStatus.error:
        return 'Erro na sincronização';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return 'Data inválida';
    }
  }
}