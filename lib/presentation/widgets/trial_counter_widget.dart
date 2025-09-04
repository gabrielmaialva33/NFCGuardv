import 'package:flutter/material.dart';

import '../../core/services/trial_guard_service.dart';

/// Widget that displays remaining trial days in the app header
class TrialCounterWidget extends StatefulWidget {
  const TrialCounterWidget({super.key});

  @override
  State<TrialCounterWidget> createState() => _TrialCounterWidgetState();
}

class _TrialCounterWidgetState extends State<TrialCounterWidget> {
  int _remainingDays = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRemainingDays();
  }

  Future<void> _loadRemainingDays() async {
    try {
      final days = await TrialGuardService.getRemainingDays();
      if (mounted) {
        setState(() {
          _remainingDays = days;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _remainingDays = 0;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if not a trial build or production
    if (_remainingDays >= 999) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 16, color: _getTextColor(context)),
          const SizedBox(width: 4),
          Text(
            _remainingDays > 0
                ? '$_remainingDays ${_remainingDays == 1 ? "dia" : "dias"}'
                : 'Expirado',
            style: TextStyle(
              color: _getTextColor(context),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (_remainingDays <= 0) {
      return Colors.red.withValues(alpha: 0.1);
    } else if (_remainingDays == 1) {
      return Colors.orange.withValues(alpha: 0.1);
    } else {
      return Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.3);
    }
  }

  Color _getTextColor(BuildContext context) {
    if (_remainingDays <= 0) {
      return Colors.red;
    } else if (_remainingDays == 1) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }
}
