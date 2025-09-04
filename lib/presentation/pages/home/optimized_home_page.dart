import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/nfc_data_button.dart';
import '../../widgets/optimized_button.dart';
import '../auth/login_page.dart';

/// Optimized HomePage following Flutter 2025 performance best practices
class OptimizedHomePage extends ConsumerWidget {
  const OptimizedHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: ResponsiveHelper.safeAreaWrapper(
        authState.when(
          data: (user) => user != null
              ? _buildMainContent(context, ref, user)
              : const _ErrorMessage(message: 'Usuário não encontrado'),
          loading: () => const _LoadingIndicator(),
          error: (error, _) => _ErrorMessage(message: error.toString()),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(
        AppConstants.appName,
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              _logout(context, ref);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'logout',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: AppConstants.smallPadding),
                  Text('Sair'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, WidgetRef ref, UserEntity user) {
    return ResponsiveHelper.responsiveLayout(
      context: context,
      mobile: _buildMobileLayout(context, ref, user),
      tablet: _buildTabletLayout(context, ref, user),
      desktop: _buildDesktopLayout(context, ref, user),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, UserEntity user) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeCard(context, user),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildNfcButtonsGrid(context, ref),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildProtectionButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref, UserEntity user) {
    return Center(
      child: SizedBox(
        width: ResponsiveHelper.getResponsiveWidth(context, tablet: 0.8),
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePadding(context),
          child: Column(
            children: [
              _buildWelcomeCard(context, user),
              const SizedBox(height: AppConstants.largePadding),
              _buildNfcButtonsGrid(context, ref),
              const SizedBox(height: AppConstants.largePadding),
              _buildProtectionButtons(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref, UserEntity user) {
    return Center(
      child: SizedBox(
        width: ResponsiveHelper.getResponsiveWidth(context, desktop: 0.7),
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePadding(context),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildWelcomeCard(context, user),
                  ),
                  const SizedBox(width: AppConstants.largePadding),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildNfcButtonsGrid(context, ref),
                        const SizedBox(height: AppConstants.largePadding),
                        _buildProtectionButtons(context, ref),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, UserEntity user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Código: ${user.eightDigitCode}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNfcButtonsGrid(BuildContext context, WidgetRef ref) {
    final columns = ResponsiveHelper.getGridColumns(context);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: ResponsiveHelper.isMobile(context) ? 1.2 : 1.5,
        crossAxisSpacing: AppConstants.smallPadding,
        mainAxisSpacing: AppConstants.smallPadding,
      ),
      itemCount: AppConstants.maxTagDataSets,
      itemBuilder: (context, index) {
        final dataSet = index + 1;
        return NfcDataButton(
          dataSet: dataSet,
          onPressed: () => _showWriteTagDialog(context, ref, dataSet),
        );
      },
    );
  }

  Widget _buildProtectionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OptimizedButton(
            onPressed: () => _showProtectTagDialog(context, ref),
            text: 'Proteger Tag',
            icon: Icons.lock,
            variant: ButtonVariant.secondary,
            fullWidth: true,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: OptimizedButton(
            onPressed: () => _showUnprotectTagDialog(context, ref),
            text: 'Remover Proteção',
            icon: Icons.lock_open,
            variant: ButtonVariant.secondary,
            fullWidth: true,
          ),
        ),
      ],
    );
  }

  void _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _showWriteTagDialog(BuildContext context, WidgetRef ref, int dataSet) {
    // Implementation for write tag dialog with code validation
    // This will be implemented based on existing logic but optimized
  }

  void _showProtectTagDialog(BuildContext context, WidgetRef ref) {
    // Implementation for protect tag dialog
  }

  void _showUnprotectTagDialog(BuildContext context, WidgetRef ref) {
    // Implementation for unprotect tag dialog
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}