import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wisdom.dart';
import 'dart:math' as math;

class DidYouKnowPopup extends StatefulWidget {
  final Wisdom wisdom;
  final VoidCallback onClose;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onNext;

  const DidYouKnowPopup({
    Key? key,
    required this.wisdom,
    required this.onClose,
    this.onShare,
    this.onBookmark,
    this.onNext,
  }) : super(key: key);

  @override
  _DidYouKnowPopupState createState() => _DidYouKnowPopupState();
}

class _DidYouKnowPopupState extends State<DidYouKnowPopup>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _revealController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _revealAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  List<WisdomParticle> _particles = [];
  bool _isBookmarked = false;
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeParticles();
    _startAnimationSequence();

    // Haptic feedback for popup appearance
    HapticFeedback.mediumImpact();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _revealController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: Duration(milliseconds: 4000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOutSine,
    ));

    _revealAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    ));
  }

  void _initializeParticles() {
    _particles = List.generate(12, (index) => WisdomParticle(
      position: Offset(
        math.Random().nextDouble(),
        math.Random().nextDouble(),
      ),
      velocity: Offset(
        (math.Random().nextDouble() - 0.5) * 0.01,
        (math.Random().nextDouble() - 0.5) * 0.01,
      ),
      size: math.Random().nextDouble() * 3 + 1,
      opacity: math.Random().nextDouble() * 0.4 + 0.2,
      phase: math.Random().nextDouble() * 2 * math.pi,
      color: _getWisdomColor(),
    ));
  }

  Color _getWisdomColor() {
    final colors = [
      Colors.amber.shade300,
      Colors.orange.shade300,
      Theme.of(context).primaryColor.withOpacity(0.6),
      Colors.green.shade300,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void _startAnimationSequence() async {
    _scaleController.forward();
    _glowController.repeat(reverse: true);
    _particleController.repeat();
    _pulseController.repeat(reverse: true);

    await Future.delayed(Duration(milliseconds: 400));
    _revealController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _glowAnimation,
              _revealAnimation,
              _particleAnimation,
              _pulseAnimation,
            ]),
            builder: (context, child) {
              return Stack(
                children: [
                  // Particle effects background
                  _buildParticleEffect(),

                  // Main dialog
                  _buildMainDialog(theme),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildParticleEffect() {
    return Positioned.fill(
      child: CustomPaint(
        painter: WisdomParticlePainter(
          particles: _particles,
          progress: _particleAnimation.value,
        ),
      ),
    );
  }

  Widget _buildMainDialog(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(20),
      constraints: BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            theme.cardColor.withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(
              0.2 + (_glowAnimation.value * 0.2),
            ),
            blurRadius: 30 + (_glowAnimation.value * 20),
            spreadRadius: 5,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            _buildContent(theme),
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          // Animated wisdom icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor.withOpacity(0.2),
                        theme.primaryColor.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.lightbulb,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
              );
            },
          ),

          SizedBox(width: 16),

          // Title section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل تعلم؟',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                    fontFamily: 'Amiri',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Did You Know?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Close button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onClose();
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Arabic text with enhanced styling
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.primaryColor.withOpacity(0.05),
                      theme.primaryColor.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.wisdom.arabicText,
                  style: TextStyle(
                    fontSize: 24,
                    height: 2.0,
                    fontFamily: 'Amiri',
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: theme.primaryColor.withOpacity(0.1),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),

              SizedBox(height: 20),

              // Translation with reveal animation
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _showTranslation = !_showTranslation;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _showTranslation
                        ? theme.scaffoldBackgroundColor.withOpacity(0.5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (!_showTranslation)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 16,
                              color: theme.primaryColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tap to reveal translation',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                      if (_showTranslation) ...[
                        Text(
                          widget.wisdom.translation,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.wisdom.source,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Action buttons row
          Row(
            children: [
              if (widget.onBookmark != null)
                Expanded(
                  child: _buildActionButton(
                    icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    label: _isBookmarked ? 'Saved' : 'Save',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isBookmarked = !_isBookmarked;
                      });
                      widget.onBookmark!();
                    },
                    theme: theme,
                    isPrimary: false,
                  ),
                ),

              if (widget.onBookmark != null) SizedBox(width: 12),

              if (widget.onShare != null)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onShare!();
                    },
                    theme: theme,
                    isPrimary: false,
                  ),
                ),

              if (widget.onShare != null) SizedBox(width: 12),

              if (widget.onNext != null)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.arrow_forward,
                    label: 'Next',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onNext!();
                    },
                    theme: theme,
                    isPrimary: false,
                  ),
                ),
            ],
          ),

          SizedBox(height: 16),

          // Main action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onClose();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'الحمد لله',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Amiri',
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '• Alhamdulillah',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isPrimary
              ? theme.primaryColor
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary
                  ? Colors.white
                  : theme.primaryColor,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? Colors.white
                    : theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _revealController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

class WisdomParticle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  double phase;
  Color color;

  WisdomParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.phase,
    required this.color,
  });

  void update(double time) {
    position = Offset(
      (position.dx + velocity.dx + math.sin(time * 2 + phase) * 0.001) % 1.0,
      (position.dy + velocity.dy + math.cos(time * 1.5 + phase) * 0.001) % 1.0,
    );

    opacity = (math.sin(time * 3 + phase) * 0.2 + 0.3).clamp(0.1, 0.5);
  }
}

class WisdomParticlePainter extends CustomPainter {
  final List<WisdomParticle> particles;
  final double progress;

  WisdomParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.update(progress * 10);

      paint.color = particle.color.withOpacity(particle.opacity);

      final position = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );

      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(WisdomParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}