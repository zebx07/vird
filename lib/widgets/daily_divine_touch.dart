import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/daily_content.dart';
import '../widgets/animated_background.dart';
import 'dart:math' as math;

class DailyDivineTouch extends StatefulWidget {
  final DailyContent content;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;

  const DailyDivineTouch({
    Key? key,
    required this.content,
    this.onTap,
    this.onShare,
    this.onBookmark,
  }) : super(key: key);

  @override
  _DailyDivineTouchState createState() => _DailyDivineTouchState();
}

class _DailyDivineTouchState extends State<DailyDivineTouch>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _revealController;
  late AnimationController _floatingController;
  late AnimationController _shimmerController;

  late Animation<double> _glowAnimation;
  late Animation<double> _revealAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isBookmarked = false;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Glow effect for the divine touch
    _glowController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    // Reveal animation for content
    _revealController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    // Floating animation for subtle movement
    _floatingController = AnimationController(
      duration: Duration(seconds: 6),
      vsync: this,
    );

    // Shimmer effect for special content
    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.elasticOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOutSine,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() async {
    _glowController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);

    await Future.delayed(Duration(milliseconds: 300));
    _revealController.forward();

    // Occasional shimmer effect
    _shimmerController.repeat(reverse: true);
  }

  Color _getTypeColor() {
    switch (widget.content.type.toLowerCase()) {
      case 'ayah':
        return Colors.green.shade600;
      case 'dhikr':
        return Colors.blue.shade600;
      case 'hadith':
        return Colors.purple.shade600;
      case 'dua':
        return Colors.orange.shade600;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.content.type.toLowerCase()) {
      case 'ayah':
        return Icons.menu_book;
      case 'dhikr':
        return Icons.favorite;
      case 'hadith':
        return Icons.format_quote;
      case 'dua':
        return Icons.pan_tool;
      default:
        return Icons.star;
    }
  }

  String _getTimeOfDayGreeting() {
    switch (widget.content.timeOfDay.toLowerCase()) {
      case 'morning':
        return 'صباح الخير';
      case 'afternoon':
        return 'نهارك سعيد';
      case 'evening':
        return 'مساء الخير';
      case 'night':
        return 'ليلة مباركة';
      default:
        return 'بركة الله';
    }
  }

  String _getTypeDescription() {
    switch (widget.content.type.toLowerCase()) {
      case 'ayah':
        return 'Verse from the Holy Quran';
      case 'dhikr':
        return 'Remembrance of Allah';
      case 'hadith':
        return 'Saying of Prophet Muhammad ﷺ';
      case 'dua':
        return 'Supplication to Allah';
      default:
        return 'Islamic Content';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _getTypeColor();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _glowAnimation,
          _revealAnimation,
          _floatingAnimation,
          _shimmerAnimation,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: FadeTransition(
              opacity: _revealAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (widget.onTap != null) {
                        widget.onTap!();
                      } else {
                        setState(() {
                          _showDetails = !_showDetails;
                        });
                      }
                    },
                    child: Stack(
                      children: [
                        // Background with animated glow
                        _buildAnimatedBackground(theme, typeColor),

                        // Main content
                        _buildMainContent(theme, typeColor),

                        // Shimmer overlay
                        _buildShimmerOverlay(),

                        // Action buttons
                        _buildActionButtons(theme, typeColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground(ThemeData theme, Color typeColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
            color: typeColor.withOpacity(_glowAnimation.value * 0.3),
            blurRadius: 20 + (_glowAnimation.value * 10),
            spreadRadius: 2 + (_glowAnimation.value * 3),
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: typeColor.withOpacity(_glowAnimation.value * 0.3),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, Color typeColor) {
    return Container(
      padding: EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(theme, typeColor),
          SizedBox(height: 24),
          _buildArabicText(theme),
          SizedBox(height: 20),
          _buildTranslation(theme),
          if (_showDetails) ...[
            SizedBox(height: 16),
            _buildTypeDescription(theme, typeColor),
          ],
          SizedBox(height: 16),
          _buildSource(theme, typeColor),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color typeColor) {
    return Column(
      children: [
        // Time of day greeting
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                typeColor.withOpacity(0.1),
                typeColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: typeColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _getTimeOfDayGreeting(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: typeColor,
              fontFamily: 'Amiri',
            ),
          ),
        ),

        SizedBox(height: 12),

        // Content type badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(_glowAnimation.value * 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: typeColor.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTypeIcon(),
                size: 16,
                color: typeColor,
              ),
              SizedBox(width: 8),
              Text(
                widget.content.type.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: typeColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArabicText(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.primaryColor.withOpacity(0.03),
            theme.primaryColor.withOpacity(0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Text(
        widget.content.arabicText,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w500,
          height: 2.0,
          color: theme.textTheme.bodyLarge?.color,
          fontFamily: 'Amiri',
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
    );
  }

  Widget _buildTranslation(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        widget.content.translation,
        style: TextStyle(
          fontSize: 17,
          fontStyle: FontStyle.italic,
          height: 1.6,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTypeDescription(ThemeData theme, Color typeColor) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: typeColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: typeColor,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _getTypeDescription(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: typeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSource(ThemeData theme, Color typeColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.content.source,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: typeColor,
        ),
      ),
    );
  }

  Widget _buildShimmerOverlay() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                  end: Alignment(0.0 + _shimmerAnimation.value, 0.0),
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, Color typeColor) {
    return Positioned(
      top: 12,
      right: 12,
      child: Row(
        children: [
          _buildActionButton(
            icon: _showDetails ? Icons.visibility_off : Icons.info_outline,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _showDetails = !_showDetails;
              });
            },
            theme: theme,
            color: typeColor,
          ),

          SizedBox(width: 8),

          _buildActionButton(
            icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              if (widget.onBookmark != null) {
                widget.onBookmark!();
              }
            },
            theme: theme,
            color: typeColor,
          ),

          SizedBox(width: 8),

          _buildActionButton(
            icon: Icons.share,
            onTap: () {
              HapticFeedback.lightImpact();
              if (widget.onShare != null) {
                widget.onShare!();
              }
            },
            theme: theme,
            color: typeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _revealController.dispose();
    _floatingController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }
}