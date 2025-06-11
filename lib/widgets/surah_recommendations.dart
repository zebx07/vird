import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SurahRecommendations extends StatefulWidget {
  final VoidCallback? onViewAll;

  const SurahRecommendations({Key? key, this.onViewAll}) : super(key: key);

  @override
  _SurahRecommendationsState createState() => _SurahRecommendationsState();
}

class _SurahRecommendationsState extends State<SurahRecommendations>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final hour = now.hour;
    final dayOfWeek = now.weekday;

    final recommendation = _getCurrentRecommendation(hour, dayOfWeek);

    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, recommendation),
          SizedBox(height: 20),
          _buildCurrentSurah(theme, recommendation),
          SizedBox(height: 20),
          _buildViewAllButton(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Map<String, dynamic> recommendation) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                recommendation['color'].withOpacity(0.2),
                recommendation['color'].withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.menu_book,
            color: recommendation['color'],
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تلاوة مباركة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                  fontFamily: 'Amiri',
                ),
              ),
              Text(
                'Blessed Recitation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSurah(ThemeData theme, Map<String, dynamic> recommendation) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  recommendation['color'].withOpacity(0.15),
                  recommendation['color'].withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: recommendation['color'].withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: recommendation['color'].withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: recommendation['color'].withOpacity(0.2),
                      ),
                      child: Icon(
                        recommendation['icon'],
                        color: recommendation['color'],
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommendation['timeLabel'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: recommendation['color'],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                Text(
                  recommendation['arabicName'],
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge?.color,
                    fontFamily: 'Amiri',
                    height: 1.3,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  recommendation['englishName'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: recommendation['color'],
                  ),
                ),

                SizedBox(height: 16),

                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: recommendation['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recommendation['benefit'],
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewAllButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          if (widget.onViewAll != null) {
            widget.onViewAll!();
          }
        },
        icon: Icon(Icons.library_books, size: 20),
        label: Text('View All Surah Recommendations'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Map<String, dynamic> _getCurrentRecommendation(int hour, int dayOfWeek) {
    // Friday special - Surah Al-Kahf
    if (dayOfWeek == 5) {
      return {
        'arabicName': 'سُورَةُ الْكَهْفِ',
        'englishName': 'Surah Al-Kahf',
        'timeLabel': 'Friday Special',
        'benefit': 'Reading Surah Al-Kahf on Friday brings light between the two Fridays and protection from Dajjal.',
        'color': Colors.green,
        'icon': Icons.star,
      };
    }

    // Time-based recommendations
    if (hour >= 5 && hour < 12) {
      // Morning - Surah Yaseen
      return {
        'arabicName': 'سُورَةُ يٰسٓ',
        'englishName': 'Surah Yaseen',
        'timeLabel': 'Morning Blessing',
        'benefit': 'Reading Surah Yaseen in the morning brings Allah\'s blessings and ease for the entire day.',
        'color': Colors.amber,
        'icon': Icons.wb_sunny,
      };
    } else if (hour >= 12 && hour < 18) {
      // Afternoon - Surah Al-Waqiah
      return {
        'arabicName': 'سُورَةُ الْوَاقِعَةِ',
        'englishName': 'Surah Al-Waqiah',
        'timeLabel': 'Afternoon Provision',
        'benefit': 'Surah Al-Waqiah brings protection from poverty and increases sustenance.',
        'color': Colors.orange,
        'icon': Icons.wb_sunny_outlined,
      };
    } else {
      // Evening/Night - Surah Al-Mulk
      return {
        'arabicName': 'سُورَةُ الْمُلْكِ',
        'englishName': 'Surah Al-Mulk',
        'timeLabel': 'Night Protection',
        'benefit': 'Surah Al-Mulk protects from the punishment of the grave and intercedes for its reader.',
        'color': Colors.deepPurple,
        'icon': Icons.nights_stay,
      };
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
// TODO Implement this library.