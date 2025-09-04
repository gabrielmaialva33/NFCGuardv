import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';
import '../providers/nfc_provider.dart';

/// Optimized NFC data button for maximum responsiveness
class NfcDataButton extends ConsumerWidget {
  const NfcDataButton({
    super.key,
    required this.dataSet,
    required this.onPressed,
  });

  final int dataSet;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nfcState = ref.watch(nfcProvider);
    final isLoading = nfcState.isLoading;
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: EdgeInsets.all(ResponsiveHelper.isMobile(context) 
          ? AppConstants.smallPadding 
          : AppConstants.defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          constraints: BoxConstraints(
            minHeight: ResponsiveHelper.isMobile(context) ? 80 : 100,
          ),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.nfc,
                size: ResponsiveHelper.isMobile(context) ? 24 : 32,
                color: isLoading 
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                    : theme.colorScheme.primary,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                'Data Set $dataSet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  color: isLoading 
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                      : null,
                ),
                textAlign: TextAlign.center,
              ),
              if (isLoading) ...[
                const SizedBox(height: AppConstants.smallPadding),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}