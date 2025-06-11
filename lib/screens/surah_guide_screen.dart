import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/surah.dart';
import '../services/surah_service.dart';
import '../screens/surah_reading_screen.dart';

class SurahGuideScreen extends StatefulWidget {
  @override
  _SurahGuideScreenState createState() => _SurahGuideScreenState();
}

class _SurahGuideScreenState extends State<SurahGuideScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int selectedCategoryIndex = 0;
  final List<String> categories = ['Time-Based', 'Day-Based', 'Special Occasions'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  // FIXED: Added navigation method to Surah reading screen
  void _navigateToSurahReading(String surahName) {
    Surah? surah;

    // Find the surah by name
    switch (surahName.toLowerCase()) {
      case 'al-fatihah':
        surah = SurahService.getSurahByNumber(1);
        break;
      case 'yaseen':
      case 'surah yaseen':
        surah = SurahService.getSurahByNumber(36);
        break;
      case 'al-kahf':
      case 'surah al-kahf':
        surah = SurahService.getSurahByNumber(18);
        break;
      case 'al-waqiah':
      case 'surah al-waqiah':
        surah = SurahService.getSurahByNumber(56);
        break;
      case 'al-mulk':
      case 'surah al-mulk':
        surah = SurahService.getSurahByNumber(67);
        break;
      case 'as-sajdah':
      case 'surah as-sajdah':
        surah = SurahService.getSurahByNumber(32);
        break;
      case 'al-jumu\'ah':
      case 'surah al-jumu\'ah':
        surah = SurahService.getSurahByNumber(62);
        break;
      case 'al-ikhlas':
        surah = SurahService.getSurahByNumber(112);
        break;
      case 'al-falaq':
        surah = SurahService.getSurahByNumber(113);
        break;
      case 'an-nas':
        surah = SurahService.getSurahByNumber(114);
        break;
    }

    if (surah != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SurahReadingScreen(surah: surah!),
        ),
      );
    } else {
      // Show error message if Surah not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Surah not available yet. Coming soon!'),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(theme),
                SliverPadding(
                  // FIXED: Reduced padding to prevent overflow
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            _buildCategorySelector(theme),
                            SizedBox(height: 20),
                            _buildContent(theme),
                            SizedBox(height: 20), // Added bottom spacing
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'دليل السور',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
                fontFamily: 'Amiri',
              ),
            ),
            Text(
              'Surah Guide',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 4), // Added margin
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final isSelected = selectedCategoryIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  selectedCategoryIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  gradient: isSelected
                      ? LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                  )
                      : null,
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 11, // Slightly smaller font
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    switch (selectedCategoryIndex) {
      case 0:
        return _buildTimeBasedSurahs(theme);
      case 1:
        return _buildDayBasedSurahs(theme);
      case 2:
        return _buildSpecialOccasionSurahs(theme);
      default:
        return _buildTimeBasedSurahs(theme);
    }
  }

  Widget _buildTimeBasedSurahs(ThemeData theme) {
    final timeBasedSurahs = [
      {
        'time': 'Morning (Fajr - Dhuhr)',
        'icon': Icons.wb_sunny,
        'color': Colors.amber,
        'surahs': [
          {
            'arabic': 'سُورَةُ يٰسٓ',
            'english': 'Surah Yaseen',
            'number': '36',
            'verses': '83 verses',
            'benefit': 'Reading Surah Yaseen in the morning brings Allah\'s blessings and ease for the entire day.',
            'hadith': 'The Prophet (ﷺ) said: "Whoever reads Surah Yaseen in the morning, Allah will fulfill his needs for that day."',
            'source': 'Sunan Ad-Darimi'
          },
          {
            'arabic': 'سُورَةُ الْمُلْكِ',
            'english': 'Surah Al-Mulk',
            'number': '67',
            'verses': '30 verses',
            'benefit': 'Provides protection throughout the day and increases awareness of Allah\'s sovereignty.',
            'hadith': 'The Prophet (ﷺ) said: "There is a surah in the Quran which is only thirty verses. It defended whoever recited it until it puts him into paradise i.e. Surah Al-Mulk."',
            'source': 'Sunan At-Tirmidhi'
          }
        ]
      },
      {
        'time': 'Afternoon (Dhuhr - Maghrib)',
        'icon': Icons.wb_sunny_outlined,
        'color': Colors.orange,
        'surahs': [
          {
            'arabic': 'سُورَةُ الْوَاقِعَةِ',
            'english': 'Surah Al-Waqiah',
            'number': '56',
            'verses': '96 verses',
            'benefit': 'Protects from poverty and increases sustenance. Best read in the afternoon for provision.',
            'hadith': 'Ibn Masud (RA) reported: "Whoever recites Surah Al-Waqiah every night, he will never be afflicted by poverty."',
            'source': 'Sunan Ibn Majah'
          }
        ]
      },
      {
        'time': 'Evening/Night (Maghrib - Fajr)',
        'icon': Icons.nights_stay,
        'color': Colors.deepPurple,
        'surahs': [
          {
            'arabic': 'سُورَةُ الْمُلْكِ',
            'english': 'Surah Al-Mulk',
            'number': '67',
            'verses': '30 verses',
            'benefit': 'Protects from the punishment of the grave and intercedes for its reader.',
            'hadith': 'The Prophet (ﷺ) said: "Surah Al-Mulk is the protector from the torment of the grave."',
            'source': 'Sunan At-Tirmidhi'
          },
          {
            'arabic': 'سُورَةُ السَّجْدَةِ',
            'english': 'Surah As-Sajdah',
            'number': '32',
            'verses': '30 verses',
            'benefit': 'Reading before sleep brings peaceful rest and protection through the night.',
            'hadith': 'The Prophet (ﷺ) used to recite Surah As-Sajdah and Surah Al-Mulk before sleeping.',
            'source': 'Sahih At-Tirmidhi'
          }
        ]
      }
    ];

    return Column(
      children: timeBasedSurahs.map((timeGroup) =>
          _buildTimeGroupCard(theme, timeGroup)).toList(),
    );
  }

  Widget _buildDayBasedSurahs(ThemeData theme) {
    final dayBasedSurahs = [
      {
        'day': 'Friday',
        'arabic': 'يَوْمُ الْجُمُعَةِ',
        'icon': Icons.star,
        'color': Colors.green,
        'surahs': [
          {
            'arabic': 'سُورَةُ الْكَهْفِ',
            'english': 'Surah Al-Kahf',
            'number': '18',
            'verses': '110 verses',
            'benefit': 'Reading on Friday brings light between the two Fridays and protection from Dajjal.',
            'hadith': 'The Prophet (ﷺ) said: "Whoever reads Surah Al-Kahf on Friday, light will shine for him from one Friday to the next."',
            'source': 'Sunan An-Nasa\'i'
          },
          {
            'arabic': 'سُورَةُ الْجُمُعَةِ',
            'english': 'Surah Al-Jumu\'ah',
            'number': '62',
            'verses': '11 verses',
            'benefit': 'Emphasizes the importance of Friday prayer and remembrance of Allah.',
            'hadith': 'It is recommended to recite Surah Al-Jumu\'ah on Friday to remember the significance of this blessed day.',
            'source': 'Islamic Scholars'
          }
        ]
      },
      {
        'day': 'Monday & Thursday',
        'arabic': 'الاثْنَيْنِ وَالْخَمِيسِ',
        'icon': Icons.favorite,
        'color': Colors.pink,
        'surahs': [
          {
            'arabic': 'سُورَةُ يٰسٓ',
            'english': 'Surah Yaseen',
            'number': '36',
            'verses': '83 verses',
            'benefit': 'Extra spiritual benefit on the days the Prophet (ﷺ) used to fast.',
            'hadith': 'The Prophet (ﷺ) said: "Deeds are presented on Monday and Thursday, so I like for my deeds to be presented while I am fasting."',
            'source': 'Sunan At-Tirmidhi'
          }
        ]
      }
    ];

    return Column(
      children: dayBasedSurahs.map((dayGroup) =>
          _buildDayGroupCard(theme, dayGroup)).toList(),
    );
  }

  Widget _buildSpecialOccasionSurahs(ThemeData theme) {
    final specialSurahs = [
      {
        'occasion': 'Before Sleep',
        'icon': Icons.bedtime,
        'color': Colors.indigo,
        'surahs': [
          {
            'arabic': 'سُورَةُ الْمُلْكِ',
            'english': 'Surah Al-Mulk',
            'number': '67',
            'verses': '30 verses',
            'benefit': 'Protects from punishment of the grave and ensures peaceful sleep.',
            'hadith': 'The Prophet (ﷺ) said: "Surah Al-Mulk is the protector from the torment of the grave."',
            'source': 'Sunan At-Tirmidhi'
          }
        ]
      },
      {
        'occasion': 'For Sustenance',
        'icon': Icons.eco,
        'color': Colors.teal,
        'surahs': [
          {
            'arabic': 'سُورَةُ الْوَاقِعَةِ',
            'english': 'Surah Al-Waqiah',
            'number': '56',
            'verses': '96 verses',
            'benefit': 'Protects from poverty and increases provision.',
            'hadith': 'Ibn Masud (RA) said: "Whoever recites Surah Al-Waqiah every night will never be afflicted by poverty."',
            'source': 'Sunan Ibn Majah'
          }
        ]
      },
      {
        'occasion': 'For Healing',
        'icon': Icons.healing,
        'color': Colors.lightGreen,
        'surahs': [
          {
            'arabic': 'سُورَةُ الْفَاتِحَةِ',
            'english': 'Surah Al-Fatihah',
            'number': '1',
            'verses': '7 verses',
            'benefit': 'The greatest healing surah, cure for all ailments.',
            'hadith': 'The Prophet (ﷺ) said: "Al-Fatihah is a cure for every disease."',
            'source': 'Sunan Ad-Darimi'
          }
        ]
      }
    ];

    return Column(
      children: specialSurahs.map((specialGroup) =>
          _buildSpecialGroupCard(theme, specialGroup)).toList(),
    );
  }

  Widget _buildTimeGroupCard(ThemeData theme, Map<String, dynamic> timeGroup) {
    return Container(
      margin: EdgeInsets.only(bottom: 20), // Reduced margin
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: timeGroup['color'].withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: timeGroup['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  timeGroup['color'].withOpacity(0.1),
                  timeGroup['color'].withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: timeGroup['color'].withOpacity(0.2),
                  ),
                  child: Icon(
                    timeGroup['icon'],
                    color: timeGroup['color'],
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded( // Added Expanded to prevent overflow
                  child: Text(
                    timeGroup['time'],
                    style: TextStyle(
                      fontSize: 16, // Slightly smaller
                      fontWeight: FontWeight.w700,
                      color: timeGroup['color'],
                    ),
                  ),
                ),
              ],
            ),
          ),

          ...timeGroup['surahs'].map<Widget>((surah) =>
              _buildSurahCard(theme, surah, timeGroup['color'])).toList(),
        ],
      ),
    );
  }

  Widget _buildDayGroupCard(ThemeData theme, Map<String, dynamic> dayGroup) {
    return Container(
      margin: EdgeInsets.only(bottom: 20), // Reduced margin
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: dayGroup['color'].withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: dayGroup['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  dayGroup['color'].withOpacity(0.1),
                  dayGroup['color'].withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dayGroup['color'].withOpacity(0.2),
                  ),
                  child: Icon(
                    dayGroup['icon'],
                    color: dayGroup['color'],
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayGroup['arabic'],
                        style: TextStyle(
                          fontSize: 14, // Slightly smaller
                          fontWeight: FontWeight.w600,
                          color: dayGroup['color'],
                          fontFamily: 'Amiri',
                        ),
                      ),
                      Text(
                        dayGroup['day'],
                        style: TextStyle(
                          fontSize: 16, // Slightly smaller
                          fontWeight: FontWeight.w700,
                          color: dayGroup['color'],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          ...dayGroup['surahs'].map<Widget>((surah) =>
              _buildSurahCard(theme, surah, dayGroup['color'])).toList(),
        ],
      ),
    );
  }

  Widget _buildSpecialGroupCard(ThemeData theme, Map<String, dynamic> specialGroup) {
    return Container(
      margin: EdgeInsets.only(bottom: 20), // Reduced margin
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: specialGroup['color'].withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: specialGroup['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  specialGroup['color'].withOpacity(0.1),
                  specialGroup['color'].withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: specialGroup['color'].withOpacity(0.2),
                  ),
                  child: Icon(
                    specialGroup['icon'],
                    color: specialGroup['color'],
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded( // Added Expanded to prevent overflow
                  child: Text(
                    specialGroup['occasion'],
                    style: TextStyle(
                      fontSize: 16, // Slightly smaller
                      fontWeight: FontWeight.w700,
                      color: specialGroup['color'],
                    ),
                  ),
                ),
              ],
            ),
          ),

          ...specialGroup['surahs'].map<Widget>((surah) =>
              _buildSurahCard(theme, surah, specialGroup['color'])).toList(),
        ],
      ),
    );
  }

  // FIXED: Added the missing "Read Now" button and proper layout
  Widget _buildSurahCard(ThemeData theme, Map<String, dynamic> surah, Color accentColor) {
    return Container(
      padding: EdgeInsets.all(16), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  surah['number'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah['arabic'],
                      style: TextStyle(
                        fontSize: 18, // Slightly smaller
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge?.color,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    Text(
                      '${surah['english']} • ${surah['verses']}',
                      style: TextStyle(
                        fontSize: 13, // Slightly smaller
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12), // Reduced spacing

          Container(
            padding: EdgeInsets.all(14), // Reduced padding
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: accentColor,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Benefits',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  surah['benefit'],
                  style: TextStyle(
                    fontSize: 13, // Slightly smaller
                    color: theme.textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12), // Reduced spacing

          Container(
            padding: EdgeInsets.all(14), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.1),
                  accentColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: accentColor,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Hadith & Source',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  surah['hadith'],
                  style: TextStyle(
                    fontSize: 13, // Slightly smaller
                    color: theme.textTheme.bodyMedium?.color,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '— ${surah['source']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // FIXED: Added the missing "Read Now" button
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _navigateToSurahReading(surah['english']);
              },
              icon: Icon(Icons.menu_book, size: 16),
              label: Text('Read Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
