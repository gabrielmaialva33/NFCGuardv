import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/services/sync_service.dart';

part 'sync_provider.g.dart';

enum SyncStatus { idle, syncing, success, error }

@riverpod
class SyncNotifier extends _$SyncNotifier {
  final _syncService = SyncService.instance;

  @override
  AsyncValue<SyncStatus> build() {
    _initializeSync();
    return const AsyncValue.data(SyncStatus.idle);
  }

  /// Initialize automatic sync when app starts
  Future<void> _initializeSync() async {
    try {
      // Schedule automatic sync on app start
      await _syncService.scheduleAutoSync();
    } catch (e) {
      // Silent fail on initialization
    }
  }

  /// Perform full synchronization
  Future<void> performFullSync() async {
    try {
      state = const AsyncValue.data(SyncStatus.syncing);
      
      final success = await _syncService.performFullSync();
      
      if (success) {
        state = const AsyncValue.data(SyncStatus.success);
      } else {
        state = const AsyncValue.data(SyncStatus.error);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Sync only local data to Supabase
  Future<void> syncToCloud() async {
    try {
      state = const AsyncValue.data(SyncStatus.syncing);
      
      await _syncService.syncLocalToSupabase();
      state = const AsyncValue.data(SyncStatus.success);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Sync only Supabase data to local
  Future<void> syncFromCloud() async {
    try {
      state = const AsyncValue.data(SyncStatus.syncing);
      
      await _syncService.syncSupabaseToLocal();
      state = const AsyncValue.data(SyncStatus.success);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Export user data
  Future<String?> exportData() async {
    try {
      return await _syncService.exportUserData();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  /// Import user data
  Future<bool> importData(String jsonData) async {
    try {
      state = const AsyncValue.data(SyncStatus.syncing);
      
      final success = await _syncService.importUserData(jsonData);
      
      if (success) {
        state = const AsyncValue.data(SyncStatus.success);
      } else {
        state = const AsyncValue.data(SyncStatus.error);
      }
      
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Get sync status information
  Future<Map<String, dynamic>> getSyncStatus() async {
    return await _syncService.getSyncStatus();
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final localStats = await _syncService.getLocalStats();
      final cloudStats = await _syncService.getSupabaseStats();
      
      return {
        'local': localStats,
        'cloud': cloudStats,
      };
    } catch (e) {
      return {
        'local': {},
        'cloud': {},
        'error': e.toString(),
      };
    }
  }

  /// Check connection status
  Future<bool> checkConnection() async {
    return await _syncService.checkConnection();
  }

  /// Reset sync status
  void resetStatus() {
    state = const AsyncValue.data(SyncStatus.idle);
  }
}