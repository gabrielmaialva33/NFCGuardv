import 'package:flutter/foundation.dart';

import '../../core/services/supabase_service.dart';

enum NfcOperationType { write, protect, unprotect }

class NfcLoggingService {
  static final _client = SupabaseService.client;

  /// Logs an NFC operation to Supabase for analytics and security
  Future<void> logNfcOperation({
    required NfcOperationType operationType,
    required String codeUsed,
    int? datasetNumber,
    bool success = false,
    String? errorMessage,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          debugPrint('Cannot log NFC operation: user not authenticated');
        }
        return;
      }

      await _client.from('nfc_operations').insert({
        'user_id': user.id,
        'operation_type': operationType.name,
        'code_used': codeUsed,
        'dataset_number': datasetNumber,
        'success': success,
        'error_message': errorMessage,
      });

      if (kDebugMode) {
        debugPrint(
          'NFC operation logged: ${operationType.name} - Success: $success',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error logging NFC operation: $e');
      }
      // Don't throw error to avoid disrupting the main NFC operation
    }
  }

  /// Gets NFC operation history for the current user
  Future<List<Map<String, dynamic>>> getNfcOperationHistory({
    int limit = 50,
    DateTime? since,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      var query = _client
          .from('nfc_operations')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      // Note: Temporarily removing date filter due to API changes
      // TODO: Update when Supabase API is fixed
      // if (since != null) {
      //   query = query.gte('created_at', since.toIso8601String());
      // }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting NFC operation history: $e');
      }
      return [];
    }
  }

  /// Gets operation statistics for the current user
  Future<Map<String, int>> getOperationStatistics() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return {};

      final response = await _client
          .from('nfc_operations')
          .select('operation_type, success')
          .eq('user_id', user.id);

      final operations = List<Map<String, dynamic>>.from(response);

      final stats = <String, int>{};

      for (final op in operations) {
        final type = op['operation_type'] as String;
        final success = op['success'] as bool;

        // Count total operations by type
        stats['total_$type'] = (stats['total_$type'] ?? 0) + 1;

        // Count successful operations by type
        if (success) {
          stats['success_$type'] = (stats['success_$type'] ?? 0) + 1;
        }
      }

      // Calculate overall stats
      stats['total_operations'] = operations.length;
      stats['successful_operations'] = operations
          .where((op) => op['success'])
          .length;

      return stats;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting operation statistics: $e');
      }
      return {};
    }
  }
}
