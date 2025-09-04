import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';

/// Revolutionary NFC tutorial dialog with interactive animations
/// Provides world-class onboarding experience for NFC functionality
class NfcTutorialDialog extends StatefulWidget {
  const NfcTutorialDialog({
    super.key,
    required this.onStartNfc,
    this.isFirstTime = false,
  });

  final VoidCallback onStartNfc;
  final bool isFirstTime;

  @override
  State<NfcTutorialDialog> createState() => _NfcTutorialDialogState();
}

class _NfcTutorialDialogState extends State<NfcTutorialDialog>
    with TickerProviderStateMixin {
  late AnimationController _phoneController;
  late AnimationController _tagController;
  late AnimationController _wavesController;
  late AnimationController _pulseController;
  
  late Animation<double> _phoneAnimation;
  late Animation<double> _tagAnimation;
  late Animation<double> _wavesAnimation;
  late Animation<double> _pulseAnimation;
  
  PageController? _pageController;
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.isFirstTime) {
      _pageController = PageController();
    }
    
    // Start continuous animations
    _startContinuousAnimations();
  }

  void _setupAnimations() {
    _phoneController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _tagController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _wavesController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _phoneAnimation = Tween<double>(
      begin: 0.0,
      end: -20.0,
    ).animate(CurvedAnimation(
      parent: _phoneController,
      curve: Curves.easeInOut,
    ));

    _tagAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _tagController,
      curve: Curves.easeInOut,
    ));

    _wavesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _wavesController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startContinuousAnimations() {
    _phoneController.repeat(reverse: true);
    _tagController.repeat(reverse: true);
    _wavesController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _tagController.dispose();
    _wavesController.dispose();
    _pulseController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: ResponsiveHelper.getCardWidth(context),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: widget.isFirstTime ? _buildOnboardingContent() : _buildQuickTutorial(),
      ),
    );
  }

  Widget _buildOnboardingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
        
        // Page content
        SizedBox(
          height: 400,
          child: PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
              HapticFeedback.selectionClick();
            },
            children: [
              _buildPage1(),
              _buildPage2(),
              _buildPage3(),
            ],
          ),
        ),
        
        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: () {
                    _pageController!.previousPage(
                      duration: AppConstants.animationDuration,
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Anterior'),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_currentPage < _totalPages - 1) {
                    _pageController!.nextPage(
                      duration: AppConstants.animationDuration,
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.of(context).pop();
                    widget.onStartNfc();
                  }
                },
                child: Text(_currentPage == _totalPages - 1 ? 'Começar' : 'Próximo'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTutorial() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Aproximar Tag NFC',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          
          _buildAnimatedNfcDemo(),
          
          const SizedBox(height: AppConstants.largePadding),
          
          Text(
            'Posicione a tag NFC próxima ao topo traseiro do seu dispositivo',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppConstants.largePadding),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onStartNfc();
                  },
                  child: const Text('Iniciar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nfc,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppConstants.largePadding),
          
          Text(
            'Bem-vindo ao NFCGuard!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          Text(
            'Esta app permite gravar dados seguros em tags NFC de forma simples e intuitiva.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Como funciona',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppConstants.largePadding),
          
          _buildAnimatedNfcDemo(),
          
          const SizedBox(height: AppConstants.largePadding),
          
          Text(
            'Aproxime a tag NFC do topo traseiro do seu dispositivo. O sensor NFC ficará ativo quando estiver próximo o suficiente.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.security,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                Text(
                  'Segurança',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.smallPadding),
                
                Text(
                  'Seus códigos são únicos e protegidos. Cada código só pode ser usado uma vez, garantindo máxima segurança.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.largePadding),
          
          Text(
            'Pronto para começar?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedNfcDemo() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // NFC waves animation
          AnimatedBuilder(
            animation: _wavesAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(200, 200),
                painter: NfcWavesPainter(
                  progress: _wavesAnimation.value,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              );
            },
          ),
          
          // Phone animation
          AnimatedBuilder(
            animation: _phoneAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _phoneAnimation.value),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 60,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.smartphone,
                          size: 30,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          
          // Tag animation
          AnimatedBuilder(
            animation: _tagAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 80 + _tagAnimation.value),
                child: Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Custom painter for NFC waves animation
class NfcWavesPainter extends CustomPainter {
  final double progress;
  final Color color;

  NfcWavesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw multiple expanding circles
    for (int i = 0; i < 3; i++) {
      final delay = i * 0.3;
      final waveProgress = ((progress + delay) % 1.0);
      final radius = maxRadius * waveProgress;
      final opacity = (1.0 - waveProgress);
      
      paint.color = color.withValues(alpha: color.a * opacity);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}