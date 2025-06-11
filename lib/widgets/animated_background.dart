import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class AnimatedBackground extends StatefulWidget {
  final AnimationStyle style;
  final bool enableParticles;
  final bool enableGradientShift;
  final double intensity;

  const AnimatedBackground({
    Key? key,
    this.style = AnimationStyle.organic,
    this.enableParticles = true,
    this.enableGradientShift = true,
    this.intensity = 1.0,
  }) : super(key: key);

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

enum AnimationStyle {
  organic,
  geometric,
  flowing,
  spiritual,
  minimal,
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _secondaryController;
  late AnimationController _particleController;
  late AnimationController _gradientController;

  late Animation<double> _primaryAnimation;
  late Animation<double> _secondaryAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _gradientAnimation;

  List<Particle> _particles = [];
  late Ticker _ticker;
  double _time = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeParticles();
    _startTicker();
  }

  void _initializeAnimations() {
    // Primary animation for main shapes
    _primaryController = AnimationController(
      duration: Duration(seconds: _getDurationForStyle()),
      vsync: this,
    )..repeat();

    // Secondary animation for complementary effects
    _secondaryController = AnimationController(
      duration: Duration(seconds: _getDurationForStyle() + 5),
      vsync: this,
    )..repeat(reverse: true);

    // Particle animation
    _particleController = AnimationController(
      duration: Duration(seconds: 30),
      vsync: this,
    )..repeat();

    // Gradient shift animation
    _gradientController = AnimationController(
      duration: Duration(seconds: 45),
      vsync: this,
    )..repeat();

    _primaryAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: _getCurveForStyle(),
    ));

    _secondaryAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _secondaryController,
      curve: Curves.easeInOutSine,
    ));

    _particleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_particleController);

    _gradientAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_gradientController);
  }

  void _initializeParticles() {
    if (!widget.enableParticles) return;

    _particles = List.generate(20, (index) => Particle(
      position: Offset(
        math.Random().nextDouble(),
        math.Random().nextDouble(),
      ),
      velocity: Offset(
        (math.Random().nextDouble() - 0.5) * 0.002,
        (math.Random().nextDouble() - 0.5) * 0.002,
      ),
      size: math.Random().nextDouble() * 3 + 1,
      opacity: math.Random().nextDouble() * 0.3 + 0.1,
      phase: math.Random().nextDouble() * 2 * math.pi,
    ));
  }

  void _startTicker() {
    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
        _updateParticles();
      });
    });
    _ticker.start();
  }

  void _updateParticles() {
    if (!widget.enableParticles) return;

    for (var particle in _particles) {
      particle.update(_time);
    }
  }

  int _getDurationForStyle() {
    switch (widget.style) {
      case AnimationStyle.organic:
        return 20;
      case AnimationStyle.geometric:
        return 15;
      case AnimationStyle.flowing:
        return 25;
      case AnimationStyle.spiritual:
        return 30;
      case AnimationStyle.minimal:
        return 40;
    }
  }

  Curve _getCurveForStyle() {
    switch (widget.style) {
      case AnimationStyle.organic:
        return Curves.easeInOutSine;
      case AnimationStyle.geometric:
        return Curves.linear;
      case AnimationStyle.flowing:
        return Curves.easeInOutCubic;
      case AnimationStyle.spiritual:
        return Curves.easeInOutQuart;
      case AnimationStyle.minimal:
        return Curves.easeInOut;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _primaryAnimation,
        _secondaryAnimation,
        _particleAnimation,
        _gradientAnimation,
      ]),
      builder: (context, child) {
        return CustomPaint(
          painter: EnhancedBackgroundPainter(
            primaryAngle: _primaryAnimation.value,
            secondaryAngle: _secondaryAnimation.value,
            particleProgress: _particleAnimation.value,
            gradientAngle: _gradientAnimation.value,
            time: _time,
            particles: _particles,
            style: widget.style,
            enableParticles: widget.enableParticles,
            enableGradientShift: widget.enableGradientShift,
            intensity: widget.intensity,
            primaryColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
          ),
          child: Container(),
        );
      },
    );
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _particleController.dispose();
    _gradientController.dispose();
    _ticker.dispose();
    super.dispose();
  }
}

class Particle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  double phase;
  double life;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.phase,
    this.life = 1.0,
  });

  void update(double time) {
    // Update position with some organic movement
    position = Offset(
      (position.dx + velocity.dx + math.sin(time * 0.5 + phase) * 0.0001) % 1.0,
      (position.dy + velocity.dy + math.cos(time * 0.3 + phase) * 0.0001) % 1.0,
    );

    // Pulse opacity
    opacity = (math.sin(time * 2 + phase) * 0.1 + 0.2).clamp(0.0, 0.4);
  }
}

class EnhancedBackgroundPainter extends CustomPainter {
  final double primaryAngle;
  final double secondaryAngle;
  final double particleProgress;
  final double gradientAngle;
  final double time;
  final List<Particle> particles;
  final AnimationStyle style;
  final bool enableParticles;
  final bool enableGradientShift;
  final double intensity;
  final Color primaryColor;
  final Color backgroundColor;
  final bool isDarkMode;

  EnhancedBackgroundPainter({
    required this.primaryAngle,
    required this.secondaryAngle,
    required this.particleProgress,
    required this.gradientAngle,
    required this.time,
    required this.particles,
    required this.style,
    required this.enableParticles,
    required this.enableGradientShift,
    required this.intensity,
    required this.primaryColor,
    required this.backgroundColor,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawMainShapes(canvas, size);
    if (enableParticles) _drawParticles(canvas, size);
    _drawOverlay(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    if (!enableGradientShift) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create dynamic gradient based on style
    List<Color> gradientColors = _getGradientColors();

    final gradient = LinearGradient(
      begin: Alignment(
        math.cos(gradientAngle) * 0.5,
        math.sin(gradientAngle) * 0.5,
      ),
      end: Alignment(
        -math.cos(gradientAngle) * 0.5,
        -math.sin(gradientAngle) * 0.5,
      ),
      colors: gradientColors,
      stops: [0.0, 0.3, 0.7, 1.0],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  List<Color> _getGradientColors() {
    final baseOpacity = isDarkMode ? 0.03 : 0.02;

    switch (style) {
      case AnimationStyle.spiritual:
        return [
          primaryColor.withOpacity(baseOpacity),
          primaryColor.withOpacity(baseOpacity * 0.5),
          Colors.amber.withOpacity(baseOpacity * 0.3),
          backgroundColor.withOpacity(0.0),
        ];
      case AnimationStyle.organic:
        return [
          primaryColor.withOpacity(baseOpacity),
          Colors.green.withOpacity(baseOpacity * 0.4),
          Colors.blue.withOpacity(baseOpacity * 0.3),
          backgroundColor.withOpacity(0.0),
        ];
      case AnimationStyle.flowing:
        return [
          primaryColor.withOpacity(baseOpacity),
          primaryColor.withOpacity(baseOpacity * 0.7),
          primaryColor.withOpacity(baseOpacity * 0.4),
          backgroundColor.withOpacity(0.0),
        ];
      default:
        return [
          primaryColor.withOpacity(baseOpacity),
          primaryColor.withOpacity(baseOpacity * 0.5),
          primaryColor.withOpacity(baseOpacity * 0.2),
          backgroundColor.withOpacity(0.0),
        ];
    }
  }

  void _drawMainShapes(Canvas canvas, Size size) {
    switch (style) {
      case AnimationStyle.organic:
        _drawOrganicShapes(canvas, size);
        break;
      case AnimationStyle.geometric:
        _drawGeometricShapes(canvas, size);
        break;
      case AnimationStyle.flowing:
        _drawFlowingShapes(canvas, size);
        break;
      case AnimationStyle.spiritual:
        _drawSpiritualShapes(canvas, size);
        break;
      case AnimationStyle.minimal:
        _drawMinimalShapes(canvas, size);
        break;
    }
  }

  void _drawOrganicShapes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.04 * intensity)
      ..style = PaintingStyle.fill;

    // Multiple organic blobs with different characteristics
    final shapes = [
      _OrganicShape(
        center: Offset(size.width * 0.2, size.height * 0.3),
        baseRadius: size.width * 0.15,
        frequency: 8,
        amplitude: 25,
        angle: primaryAngle,
      ),
      _OrganicShape(
        center: Offset(size.width * 0.8, size.height * 0.7),
        baseRadius: size.width * 0.12,
        frequency: 6,
        amplitude: 20,
        angle: secondaryAngle,
      ),
      _OrganicShape(
        center: Offset(size.width * 0.6, size.height * 0.2),
        baseRadius: size.width * 0.08,
        frequency: 10,
        amplitude: 15,
        angle: primaryAngle * 0.7,
      ),
    ];

    for (final shape in shapes) {
      canvas.drawPath(_createOrganicPath(shape), paint);
    }
  }

  void _drawGeometricShapes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.03 * intensity)
      ..style = PaintingStyle.fill;

    // Rotating geometric patterns
    canvas.save();
    canvas.translate(size.width * 0.3, size.height * 0.4);
    canvas.rotate(primaryAngle * 0.5);

    final hexPath = _createHexagon(size.width * 0.1);
    canvas.drawPath(hexPath, paint);

    canvas.restore();

    canvas.save();
    canvas.translate(size.width * 0.7, size.height * 0.6);
    canvas.rotate(secondaryAngle * 0.3);

    final trianglePath = _createTriangle(size.width * 0.08);
    canvas.drawPath(trianglePath, paint);

    canvas.restore();
  }

  void _drawFlowingShapes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.05 * intensity)
      ..style = PaintingStyle.fill;

    // Flowing wave-like patterns
    final path = Path();

    for (double x = 0; x <= size.width; x += 5) {
      final y1 = size.height * 0.3 +
          math.sin(x * 0.01 + primaryAngle) * 30 * intensity +
          math.sin(x * 0.005 + secondaryAngle) * 50 * intensity;

      if (x == 0) {
        path.moveTo(x, y1);
      } else {
        path.lineTo(x, y1);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawSpiritualShapes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.04 * intensity)
      ..style = PaintingStyle.fill;

    // Islamic geometric patterns inspired shapes
    final center = Offset(size.width * 0.5, size.height * 0.5);

    // Draw rotating star pattern
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(primaryAngle * 0.2);

    final starPath = _createIslamicStar(size.width * 0.1, 8);
    canvas.drawPath(starPath, paint);

    canvas.restore();

    // Draw smaller rotating patterns
    final smallCenters = [
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.8),
      Offset(size.width * 0.1, size.height * 0.7),
      Offset(size.width * 0.9, size.height * 0.3),
    ];

    for (int i = 0; i < smallCenters.length; i++) {
      canvas.save();
      canvas.translate(smallCenters[i].dx, smallCenters[i].dy);
      canvas.rotate(secondaryAngle * (i % 2 == 0 ? 1 : -1) * 0.3);

      final smallStar = _createIslamicStar(size.width * 0.03, 6);
      canvas.drawPath(smallStar, paint);

      canvas.restore();
    }
  }

  void _drawMinimalShapes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.02 * intensity)
      ..style = PaintingStyle.fill;

    // Simple, subtle circles
    final circles = [
      _Circle(
        center: Offset(size.width * 0.3, size.height * 0.4),
        radius: size.width * 0.1 + math.sin(primaryAngle) * 20,
      ),
      _Circle(
        center: Offset(size.width * 0.7, size.height * 0.6),
        radius: size.width * 0.08 + math.cos(secondaryAngle) * 15,
      ),
    ];

    for (final circle in circles) {
      canvas.drawCircle(circle.center, circle.radius, paint);
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      paint.color = primaryColor.withOpacity(particle.opacity * intensity);

      final position = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );

      canvas.drawCircle(position, particle.size, paint);
    }
  }

  void _drawOverlay(Canvas canvas, Size size) {
    // Add subtle noise texture for depth
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.005 * intensity)
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent pattern

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 0.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  Path _createOrganicPath(_OrganicShape shape) {
    final path = Path();

    for (int i = 0; i <= 360; i += 5) {
      final rad = i * math.pi / 180;
      final noise = math.sin(rad * shape.frequency + shape.angle) * shape.amplitude;
      final x = shape.center.dx + (shape.baseRadius + noise) * math.cos(rad);
      final y = shape.center.dy + (shape.baseRadius + noise) * math.sin(rad);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  Path _createHexagon(double radius) {
    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  Path _createTriangle(double radius) {
    final path = Path();

    for (int i = 0; i < 3; i++) {
      final angle = i * 2 * math.pi / 3 - math.pi / 2;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  Path _createIslamicStar(double radius, int points) {
    final path = Path();
    final angleStep = 2 * math.pi / points;

    for (int i = 0; i < points; i++) {
      final angle = i * angleStep - math.pi / 2;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(EnhancedBackgroundPainter oldDelegate) {
    return oldDelegate.primaryAngle != primaryAngle ||
        oldDelegate.secondaryAngle != secondaryAngle ||
        oldDelegate.particleProgress != particleProgress ||
        oldDelegate.gradientAngle != gradientAngle ||
        oldDelegate.time != time ||
        oldDelegate.style != style ||
        oldDelegate.intensity != intensity ||
        oldDelegate.primaryColor != primaryColor;
  }
}

class _OrganicShape {
  final Offset center;
  final double baseRadius;
  final int frequency;
  final double amplitude;
  final double angle;

  _OrganicShape({
    required this.center,
    required this.baseRadius,
    required this.frequency,
    required this.amplitude,
    required this.angle,
  });
}

class _Circle {
  final Offset center;
  final double radius;

  _Circle({
    required this.center,
    required this.radius,
  });
}