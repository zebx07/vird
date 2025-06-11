import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dhikr_session.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

class CompletionDialog extends StatefulWidget {
  final DhikrTemplate dhikrTemplate;
  final DhikrSession session;
  final VoidCallback onReflect;
  final VoidCallback onFinish;
  final VoidCallback? onShare;

  const CompletionDialog({
    Key? key,
    required this.dhikrTemplate,
    required this.session,
    required this.onReflect,
    required this.onFinish,
    this.onShare,
  }) : super(key: key);

  @override
  _CompletionDialogState createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<CompletionDialog>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _celebrationController;
  late AnimationController _statsController;
  late AnimationController _particleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _statsAnimation;

  List<Particle> _particles = [];
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeParticles();
    _startAnimationSequence();

    // Haptic feedback for completion
    HapticFeedback.heavyImpact();
  }

  void _initializeAnimations() {
    _mainAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeInOut,
    ));

    _statsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutBack,
    ));
  }

  void _initializeParticles() {
    _particles = List.generate(15, (index) => Particle(
      position: Offset(
        math.Random().nextDouble(),
        math.Random().nextDouble(),
      ),
      velocity: Offset(
        (math.Random().nextDouble() - 0.5) * 0.02,
        -math.Random().nextDouble() * 0.03 - 0.01,
      ),
      size: math.Random().nextDouble() * 4 + 2,
      color: _getRandomCelebrationColor(),
      life: 1.0,
    ));
  }

  Color _getRandomCelebrationColor() {
    final colors = [
      Colors.amber,
      Colors.orange,
      Theme.of(context).primaryColor,
      Colors.green,
      Colors.blue,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void _startAnimationSequence() async {
    await _mainAnimationController.forward();

    // Start celebration effects
    _celebrationController.forward();
    _particleController.repeat();

    // Show stats after a delay
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _showStats = true;
    });
    _statsController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _mainAnimationController,
          _celebrationController,
          _statsController,
          _particleController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Particle effects
              _buildParticleEffect(),

              // Main dialog
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCelebrationHeader(theme),
                          SizedBox(height: 24),
                          _buildCompletionMessage(theme),
                          SizedBox(height: 24),
                          if (_showStats) _buildSessionStats(theme),
                          if (_showStats) SizedBox(height: 24),
                          _buildBenefits(theme),
                          SizedBox(height: 28),
                          _buildActionButtons(theme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildParticleEffect() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ParticlePainter(
          particles: _particles,
          progress: _particleController.value,
        ),
      ),
    );
  }

  Widget _buildCelebrationHeader(ThemeData theme) {
    return Column(
      children: [
        // Animated celebration icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor.withOpacity(0.2),
                theme.primaryColor.withOpacity(0.1),
              ],
            ),
          ),
          child: AnimatedBuilder(
            animation: _celebrationAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + math.sin(_celebrationAnimation.value * math.pi * 2) * 0.1,
                child: Icon(
                  Icons.check_circle,
                  size: 50,
                  color: theme.primaryColor,
                ),
              );
            },
          ),
        ),

        SizedBox(height: 16),

        // Celebration text with animation
        AnimatedBuilder(
          animation: _celebrationAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + math.sin(_celebrationAnimation.value * math.pi * 4) * 0.05,
              child: Text(
                'مَاشَاءَ اللّٰهُ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryColor,
                  fontFamily: 'Amiri',
                ),
              ),
            );
          },
        ),

        SizedBox(height: 8),

        Text(
          'Masha\'Allah!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionMessage(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Session Completed Successfully',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
                height: 1.4,
              ),
              children: [
                TextSpan(text: 'You completed '),
                TextSpan(
                  text: '${widget.session.actualCount}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                    fontSize: 18,
                  ),
                ),
                TextSpan(text: ' repetitions of\n'),
                TextSpan(
                  text: widget.dhikrTemplate.transliteration,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStats(ThemeData theme) {
    return FadeTransition(
      opacity: _statsAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_statsAnimation),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.access_time,
                  label: 'Duration',
                  value: '${widget.session.durationMinutes}m',
                  theme: theme,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.dividerColor.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.speed,
                  label: 'Rate',
                  value: '${(widget.session.actualCount / widget.session.durationMinutes).toStringAsFixed(1)}/min',
                  theme: theme,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.dividerColor.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.emoji_events,
                  label: 'Progress',
                  value: '${((widget.session.actualCount / widget.session.targetCount) * 100).toInt()}%',
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.primaryColor,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.green.withOpacity(0.05),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Spiritual Benefits',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...widget.dhikrTemplate.benefits.take(3).map((benefit) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onFinish();
                },
                icon: Icon(Icons.home, size: 18),
                label: Text('Finish'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: theme.primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onReflect();
                },
                icon: Icon(Icons.edit_note, size: 18),
                label: Text('Reflect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),

        if (widget.onShare != null) ...[
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onShare!();
              },
              icon: Icon(Icons.share, size: 18),
              label: Text('Share Achievement'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _celebrationController.dispose();
    _statsController.dispose();
    _particleController.dispose();
    super.dispose();
  }
}

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double life;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.life,
  });

  void update(double deltaTime) {
    position = Offset(
      position.dx + velocity.dx * deltaTime,
      position.dy + velocity.dy * deltaTime,
    );

    life -= deltaTime * 0.5;
    if (life <= 0) {
      life = 1.0;
      position = Offset(
        math.Random().nextDouble(),
        1.2,
      );
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.update(0.016); // Assuming 60fps

      paint.color = particle.color.withOpacity(
        (particle.life * 0.7).clamp(0.0, 0.7),
      );

      final position = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );

      canvas.drawCircle(position, particle.size * particle.life, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}