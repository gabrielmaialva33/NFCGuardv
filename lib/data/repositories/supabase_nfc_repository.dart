import 'package:flutter/foundation.dart';

import '../../core/config/supabase_config.dart';
import '../../core/services/supabase_service.dart';
import '../datasources/nfc_logging_service.dart';
import '../datasources/secure_storage_service.dart';

class SupabaseNfcRepository {
  final _client = SupabaseService.client;
  final _storageService = SecureStorageService();

  /// Log NFC operation to Supabase
  Future<void> logNfcOperation({
    required NfcOperationType operationType,
    required String codeUsed,
    required int datasetNumber,
    required bool success,
    String? errorMessage,
    String? deviceFingerprint,
    String? tagUid,
    String? tagType,
    String? dataWritten,
  }) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      await _client.from(SupabaseConfig.nfcLogsTable).insert({
        'user_id': userId,
        'operation_type': operationType.name,
        'code_used': codeUsed,
        'dataset_number': datasetNumber,
        'success': success,
        'error_message': errorMessage,
        'device_fingerprint': deviceFingerprint,
        'tag_uid': tagUid,
        'tag_type': tagType,
        'data_written': dataWritten,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log to Supabase: $e');
      }
    }
  }

  /// Add used code to Supabase and local storage
  Future<void> addUsedCode(String code, {int? datasetNumber}) async {
    try {
      // Add to local storage first (for offline support)
      await _storageService.addUsedCode(code);

      // Then sync to Supabase
      final userId = SupabaseService.instance.currentUserId;
      if (userId != null) {
        await _client.from(SupabaseConfig.usedCodesTable).insert({
          'user_id': userId,
          'code': code,
          'dataset_number': datasetNumber,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to sync used code to Supabase: $e');
      }
    }
  }

  /// Check if code is used (check both local and Supabase)
  Future<bool> isCodeUsed(String code) async {
    try {
      // Check local storage first (faster)
      final localResult = await _storageService.isCodeUsed(code);
      if (localResult) return true;

      // Check Supabase if not found locally
      final userId = SupabaseService.instance.currentUserId;
      if (userId != null) {
        final response = await _client
            .from(SupabaseConfig.usedCodesTable)
            .select('id')
            .eq('user_id', userId)
            .eq('code', code)
            .limit(1);

        if (response.isNotEmpty) {
          // Found in Supabase but not local, sync it
          await _storageService.addUsedCode(code);
          return true;
        }
      }

      return false;
    } catch (e) {
      // If Supabase fails, rely on local storage
      return await _storageService.isCodeUsed(code);
    }
  }

  /// Get all used codes for current user
  Future<List<Map<String, dynamic>>> getUserUsedCodes() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return [];

      final response = await _client
          .from(SupabaseConfig.usedCodesTable)
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch used codes from Supabase: $e');
      }
      return [];
    }
  }

  /// Get NFC operation logs
  Future<List<Map<String, dynamic>>> getNfcLogs({
    int? limit,
    String? operationType,
  }) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return [];

      var query = _client
          .from(SupabaseConfig.nfcLogsTable)
          .select('*')
          .eq('user_id', userId);

      if (operationType != null) {
        query = query.eq('operation_type', operationType);
      }

      var orderedQuery = query.order('created_at', ascending: false);

      if (limit != null) {
        orderedQuery = orderedQuery.limit(limit);
      }

      final response = await orderedQuery;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch NFC logs from Supabase: $e');
      }
      return [];
    }
  }

  /// Sync local data to Supabase
  Future<void> syncLocalDataToSupabase() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      // Get local used codes
      final localCodes = await _storageService.getUsedCodes();

      // Check which codes are not in Supabase
      for (final code in localCodes) {
        final existsInSupabase = await _client
            .from(SupabaseConfig.usedCodesTable)
            .select('id')
            .eq('user_id', userId)
            .eq('code', code)
            .limit(1);

        if (existsInSupabase.isEmpty) {
          // Add to Supabase
          await _client.from(SupabaseConfig.usedCodesTable).insert({
            'user_id': userId,
            'code': code,
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to sync local data to Supabase: $e');
      }
    }
  }

  /// Sync Supabase data to local storage
  Future<void> syncSupabaseDataToLocal() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      // Get all used codes from Supabase
      final supabaseCodes = await _client
          .from(SupabaseConfig.usedCodesTable)
          .select('code')
          .eq('user_id', userId);

      // Add each code to local storage
      for (final codeData in supabaseCodes) {
        await _storageService.addUsedCode(codeData['code']);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to sync Supabase data to local: $e');
      }
    }
  }

  /// Store trial data
  Future<void> storeTrialData({
    required String deviceFingerprint,
    required DateTime installationDate,
    int trialDays = 3,
  }) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      await _client.from(SupabaseConfig.trialDataTable).upsert({
        'user_id': userId,
        'device_fingerprint': deviceFingerprint,
        'installation_date': installationDate.toIso8601String(),
        'trial_days': trialDays,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to store trial data: $e');
      }
    }
  }

  /// Get trial data
  Future<Map<String, dynamic>?> getTrialData(String deviceFingerprint) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return null;

      final response = await _client
          .from(SupabaseConfig.trialDataTable)
          .select('*')
          .eq('user_id', userId)
          .eq('device_fingerprint', deviceFingerprint)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Update trial last check
  Future<void> updateTrialLastCheck(String deviceFingerprint) async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      await _client
          .from(SupabaseConfig.trialDataTable)
          .update({'last_check': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .eq('device_fingerprint', deviceFingerprint);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update trial last check: $e');
      }
    }
  }
}
