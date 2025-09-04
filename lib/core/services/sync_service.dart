import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../data/datasources/secure_storage_service.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../data/repositories/supabase_nfc_repository.dart';
import 'supabase_service.dart';

class SyncService {
  static SyncService? _instance;

  static SyncService get instance => _instance ??= SyncService._();

  SyncService._();

  final _storageService = SecureStorageService();
  final _authRepository = SupabaseAuthRepository();
  final _nfcRepository = SupabaseNfcRepository();

  /// Full sync: backup local data to Supabase and restore from Supabase
  Future<bool> performFullSync() async {
    try {
      if (!SupabaseService.instance.isAuthenticated) {
        return false;
      }

      // 1. Sync local data to Supabase
      await syncLocalToSupabase();

      // 2. Sync Supabase data to local
      await syncSupabaseToLocal();

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Full sync failed: $e');
      return false;
    }
  }

  /// Upload local data to Supabase
  Future<void> syncLocalToSupabase() async {
    try {
      await _nfcRepository.syncLocalDataToSupabase();
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to sync local to Supabase: $e');
    }
  }

  /// Download Supabase data to local storage
  Future<void> syncSupabaseToLocal() async {
    try {
      await _nfcRepository.syncSupabaseDataToLocal();
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to sync Supabase to local: $e');
    }
  }

  /// Create backup of all user data
  Future<Map<String, dynamic>?> createBackup() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return null;

      // Get user profile
      final userProfile = await _authRepository.getUserProfile(userId);

      // Get all used codes
      final usedCodes = await _nfcRepository.getUserUsedCodes();

      // Get NFC logs
      final nfcLogs = await _nfcRepository.getNfcLogs();

      // Get trial data if exists
      final trialData = await _getTrialDataForBackup();

      final backup = {
        'version': '1.0',
        'created_at': DateTime.now().toIso8601String(),
        'user_id': userId,
        'data': {
          'user_profile': userProfile?.toJson(),
          'used_codes': usedCodes,
          'nfc_logs': nfcLogs,
          'trial_data': trialData,
        },
      };

      return backup;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to create backup: $e');
      return null;
    }
  }

  /// Restore from backup
  Future<bool> restoreFromBackup(Map<String, dynamic> backup) async {
    try {
      if (backup['version'] != '1.0') {
        throw Exception('Unsupported backup version');
      }

      final data = backup['data'] as Map<String, dynamic>;

      // Clear existing local data
      await _storageService.clearStorage();

      // Restore used codes to local storage
      final usedCodes = data['used_codes'] as List<dynamic>? ?? [];
      for (final codeData in usedCodes) {
        await _storageService.addUsedCode(codeData['code']);
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to restore from backup: $e');
      return false;
    }
  }

  /// Export user data to JSON string
  Future<String?> exportUserData() async {
    try {
      final backup = await createBackup();
      if (backup == null) return null;

      return json.encode(backup);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to export user data: $e');
      return null;
    }
  }

  /// Import user data from JSON string
  Future<bool> importUserData(String jsonData) async {
    try {
      final Map<String, dynamic> backup = json.decode(jsonData);
      return await restoreFromBackup(backup);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to import user data: $e');
      return false;
    }
  }

  /// Check connection to Supabase
  Future<bool> checkConnection() async {
    return await SupabaseService.instance.checkConnection();
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final isConnected = await checkConnection();
      final isAuthenticated = SupabaseService.instance.isAuthenticated;
      final lastSyncTime = await _getLastSyncTime();

      return {
        'is_connected': isConnected,
        'is_authenticated': isAuthenticated,
        'last_sync': lastSyncTime,
        'needs_sync': await _needsSync(),
      };
    } catch (e) {
      return {
        'is_connected': false,
        'is_authenticated': false,
        'last_sync': null,
        'needs_sync': false,
        'error': e.toString(),
      };
    }
  }

  /// Get local stats
  Future<Map<String, int>> getLocalStats() async {
    try {
      final usedCodes = await _storageService.getUsedCodes();
      return {'used_codes': usedCodes.length};
    } catch (e) {
      return {'used_codes': 0};
    }
  }

  /// Get Supabase stats
  Future<Map<String, int>> getSupabaseStats() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return {};

      final usedCodes = await _nfcRepository.getUserUsedCodes();
      final nfcLogs = await _nfcRepository.getNfcLogs();

      return {'used_codes': usedCodes.length, 'nfc_logs': nfcLogs.length};
    } catch (e) {
      return {};
    }
  }

  /// Check if sync is needed
  Future<bool> _needsSync() async {
    try {
      final localStats = await getLocalStats();
      final supabaseStats = await getSupabaseStats();

      // If counts don't match, sync is needed
      return localStats['used_codes'] != supabaseStats['used_codes'];
    } catch (e) {
      return false;
    }
  }

  /// Get last sync time
  Future<DateTime?> _getLastSyncTime() async {
    try {
      final lastSyncString = await _storageService.getValue('last_sync_time');
      if (lastSyncString != null) {
        return DateTime.parse(lastSyncString);
      }
    } catch (e) {
      // Ignore error
    }
    return null;
  }

  /// Update last sync time
  Future<void> _updateLastSyncTime() async {
    await _storageService.storeValue(
      'last_sync_time',
      DateTime.now().toIso8601String(),
    );
  }

  /// Get trial data for backup
  Future<Map<String, dynamic>?> _getTrialDataForBackup() async {
    // This would get trial data if we need to back it up
    // For now, return null since trial data is device-specific
    return null;
  }

  /// Schedule automatic sync
  Future<void> scheduleAutoSync() async {
    // This could be implemented with a timer or background task
    // For now, we'll just sync when the app starts
    if (SupabaseService.instance.isAuthenticated) {
      await performFullSync();
      await _updateLastSyncTime();
    }
  }
}
