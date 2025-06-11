import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/daily_divine_touch.dart';
import '../widgets/mood_check_in.dart';
import '../widgets/quick_actions.dart';
import '../widgets/progress_overview.dart';
import '../widgets/surah_recommendations.dart';
import '../providers/app_state_provider.dart';
import '../models/daily_content.dart';
import '../services/content_service.dart';
import '../screens/surah_guide_screen.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late AnimationController _shimmerController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _shimmerAnimation;

  DailyContent? dailyContent;
  bool _isLoading = true;
  ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _loadDailyContent();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  Future<void> _loadDailyContent() async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      final content = await ContentService.getDailyContent();
      setState(() {
        dailyContent = content;
        _isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withOpacity(0.08),
              theme.primaryColor.withOpacity(0.04),
              Colors.transparent,
              theme.scaffoldBackgroundColor,
            ],
            stops: [0.0, 0.2, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundElements(theme, size),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadDailyContent,
                color: theme.primaryColor,
                backgroundColor: theme.cardColor,
                strokeWidth: 3,
                displacement: 60,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEnhancedHeader(theme, size),
                            SizedBox(height: 32),
                            _buildContent(theme),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements(ThemeData theme, Size size) {
    return Positioned.fill(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Positioned(
                top: 100 + _floatingAnimation.value,
                right: 30,
                child: Transform.rotate(
                  angle: _floatingAnimation.value * 0.1,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor.withOpacity(0.1),
                          theme.primaryColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Positioned(
                top: 300 - _floatingAnimation.value,
                left: 20,
                child: Transform.rotate(
                  angle: -_floatingAnimation.value * 0.15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor.withOpacity(0.08),
                          theme.primaryColor.withOpacity(0.03),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          Positioned.fill(
            child: CustomPaint(
              painter: PatternPainter(
                color: theme.primaryColor.withOpacity(0.02),
                offset: _scrollOffset * 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader(ThemeData theme, Size size) {
    final hour = DateTime.now().hour;
    final now = DateTime.now();
    String greeting;
    String timeOfDay;
    String arabicGreeting;
    IconData greetingIcon;
    Color accentColor;

    if (hour < 12) {
      greeting = 'Good Morning';
      arabicGreeting = 'صباح الخير';
      timeOfDay = 'Start your day with gratitude';
      greetingIcon = Icons.wb_sunny_outlined;
      accentColor = Colors.amber;
    } else if (hour < 18) {
      greeting = 'Good Afternoon';
      arabicGreeting = 'مساء الخير';
      timeOfDay = 'Continue with mindfulness';
      greetingIcon = Icons.wb_sunny;
      accentColor = Colors.orange;
    } else {
      greeting = 'Good Evening';
      arabicGreeting = 'مساء الخير';
      timeOfDay = 'Reflect on your blessings';
      greetingIcon = Icons.nights_stay_outlined;
      accentColor = Colors.deepPurple;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.cardColor,
                      theme.cardColor.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.15),
                      blurRadius: 25,
                      spreadRadius: 3,
                      offset: Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.12),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(
                                begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                                end: Alignment(1.0 + _shimmerAnimation.value, 0.0),
                                colors: [
                                  Colors.transparent,
                                  theme.primaryColor.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      accentColor.withOpacity(0.2),
                                      accentColor.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  greetingIcon,
                                  color: accentColor,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      arabicGreeting,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: theme.primaryColor,
                                        height: 1.2,
                                        fontFamily: 'Amiri',
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      greeting,
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: theme.textTheme.bodyLarge?.color,
                                        height: 1.1,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.primaryColor.withOpacity(0.08),
                                  theme.primaryColor.withOpacity(0.04),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.primaryColor.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timeOfDay,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),

                                SizedBox(height: 16),

                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.primaryColor.withOpacity(0.15),
                                            theme.primaryColor.withOpacity(0.08),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: theme.primaryColor,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '${_getMonthName(now.month)} ${now.day}, ${now.year}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Spacer(),

                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Day ${now.difference(DateTime(now.year, 1, 1)).inDays + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: accentColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return _buildEnhancedLoadingState(theme);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            if (dailyContent != null) ...[
              _buildEnhancedSectionCard(
                child: DailyDivineTouch(content: dailyContent!),
                theme: theme,
                index: 0,
              ),
              SizedBox(height: 24),
            ],

            // NEW: Surah Recommendations Widget
            _buildEnhancedSectionCard(
              child: SurahRecommendations(
                onViewAll: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurahGuideScreen(),
                    ),
                  );
                },
              ),
              theme: theme,
              index: 1,
            ),
            SizedBox(height: 24),

            _buildEnhancedSectionCard(
              child: MoodCheckIn(),
              theme: theme,
              index: 2,
            ),
            SizedBox(height: 24),

            _buildEnhancedSectionCard(
              child: QuickActions(),
              theme: theme,
              index: 3,
            ),
            SizedBox(height: 24),

            _buildEnhancedSectionCard(
              child: ProgressOverview(),
              theme: theme,
              index: 4,
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSectionCard({
    required Widget child,
    required ThemeData theme,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, (1 - _fadeAnimation.value) * 50 * (index + 1)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.cardColor,
                    theme.cardColor.withOpacity(0.98),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.transparent,
                              theme.primaryColor.withOpacity(0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                    child,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedLoadingState(ThemeData theme) {
    _shimmerController.repeat();

    return Column(
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(bottom: 24),
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.cardColor,
                    theme.cardColor.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                          end: Alignment(1.0 + _shimmerAnimation.value, 0.0),
                          colors: [
                            Colors.transparent,
                            theme.primaryColor.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading spiritual content...',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class PatternPainter extends CustomPainter {
  final Color color;
  final double offset;

  PatternPainter({required this.color, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final spacing = 40.0;

    for (double x = -spacing + (offset % spacing); x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(PatternPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.color != color;
  }
}
