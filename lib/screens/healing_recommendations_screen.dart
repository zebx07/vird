import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mood.dart';

class HealingRecommendationsScreen extends StatefulWidget {
  final Mood mood;

  const HealingRecommendationsScreen({Key? key, required this.mood}) : super(key: key);

  @override
  _HealingRecommendationsScreenState createState() => _HealingRecommendationsScreenState();
}

class _HealingRecommendationsScreenState extends State<HealingRecommendationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  int selectedTabIndex = 0;

  List<Map<String, String>> recommendedDhikr = [];
  List<Map<String, String>> recommendedDuas = [];
  Map<String, String> healingStory = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadHealingContent();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
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

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _loadHealingContent() {
    setState(() {
      recommendedDhikr = _getDhikrForMood(widget.mood.id);
      recommendedDuas = _getDuasForMood(widget.mood.id);
      healingStory = _getStoryForMood(widget.mood.id);
    });
  }

  List<Map<String, String>> _getDhikrForMood(String moodId) {
    switch (moodId) {
      case 'grateful':
        return [
          {
            'arabic': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
            'transliteration': 'Alhamdulillahi Rabbil Alameen',
            'translation': 'All praise is due to Allah, Lord of all the worlds',
            'source': 'Quran 1:2'
          },
          {
            'arabic': 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
            'transliteration': 'Allahumma a\'inni ala dhikrika wa shukrika wa husni ibadatik',
            'translation': 'O Allah, help me to remember You, thank You, and worship You in the best manner',
            'source': 'Abu Dawud'
          }
        ];

      case 'peaceful':
        return [
          {
            'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
            'transliteration': 'Subhanallahi wa bihamdihi subhanallahil azeem',
            'translation': 'Glory be to Allah and praise Him, glory be to Allah the Magnificent',
            'source': 'Bukhari & Muslim'
          },
          {
            'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
            'transliteration': 'La ilaha illa Allah wahdahu la sharika lah',
            'translation': 'There is no deity except Allah, alone without partner',
            'source': 'Bukhari & Muslim'
          }
        ];

      case 'hopeful':
        return [
          {
            'arabic': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
            'transliteration': 'Hasbunallahu wa ni\'mal wakeel',
            'translation': 'Allah is sufficient for us and He is the best disposer of affairs',
            'source': 'Quran 3:173'
          },
          {
            'arabic': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
            'transliteration': 'Wa man yatawakkal \'alallahi fahuwa hasbuh',
            'translation': 'And whoever relies upon Allah - then He is sufficient for him',
            'source': 'Quran 65:3'
          }
        ];

      case 'anxious':
        return [
          {
            'arabic': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
            'transliteration': 'La hawla wa la quwwata illa billah',
            'translation': 'There is no power and no strength except with Allah',
            'source': 'Bukhari & Muslim'
          },
          {
            'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ',
            'transliteration': 'Allahumma inni a\'udhu bika minal hammi wal hazan',
            'translation': 'O Allah, I seek refuge in You from anxiety and sorrow',
            'source': 'Bukhari'
          }
        ];

      case 'sad':
        return [
          {
            'arabic': 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
            'transliteration': 'Inna lillahi wa inna ilayhi raji\'un',
            'translation': 'Indeed we belong to Allah, and indeed to Him we will return',
            'source': 'Quran 2:156'
          },
          {
            'arabic': 'اللَّهُمَّ اغْفِرْ لِي ذَنْبِي وَأَذْهِبْ غَيْظَ قَلْبِي',
            'transliteration': 'Allahummaghfir li dhanbi wa adhhib ghaydha qalbi',
            'translation': 'O Allah, forgive my sin and remove the anger of my heart',
            'source': 'Ahmad'
          }
        ];

      case 'struggling':
        return [
          {
            'arabic': 'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ',
            'transliteration': 'Allahu Akbar Allahu Akbar Allahu Akbar',
            'translation': 'Allah is the Greatest, Allah is the Greatest, Allah is the Greatest',
            'source': 'Various Hadith'
          },
          {
            'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
            'transliteration': 'Rabbish rahli sadri wa yassir li amri',
            'translation': 'My Lord, expand for me my breast and ease for me my task',
            'source': 'Quran 20:25-26'
          }
        ];

    // Add more cases for other moods...
      default:
        return [
          {
            'arabic': 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
            'transliteration': 'Subhanallahi walhamdulillahi wa la ilaha illallahu wallahu akbar',
            'translation': 'Glory be to Allah, praise be to Allah, there is no deity except Allah, and Allah is the Greatest',
            'source': 'Various Hadith'
          },
          {
            'arabic': 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
            'transliteration': 'Astaghfirullaha al-azeem alladhi la ilaha illa huwa al-hayyu al-qayyumu wa atubu ilayh',
            'translation': 'I seek forgiveness from Allah the Mighty, whom there is no deity except Him, the Living, the Eternal, and I repent to Him',
            'source': 'Abu Dawud'
          }
        ];
    }
  }

  List<Map<String, String>> _getDuasForMood(String moodId) {
    switch (moodId) {
      case 'grateful':
        return [
          {
            'arabic': 'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ',
            'translation': 'My Lord, enable me to be grateful for Your favor which You have bestowed upon me',
            'source': 'Quran 27:19'
          },
          {
            'arabic': 'اللَّهُمَّ مَا أَصْبَحَ بِي مِن نِّعْمَةٍ فَمِنكَ وَحْدَكَ لَا شَرِيكَ لَكَ',
            'translation': 'O Allah, whatever blessing I have received is from You alone, without partner',
            'source': 'Abu Dawud'
          }
        ];

      case 'anxious':
        return [
          {
            'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ وَرَحْمَتِكَ فَإِنَّهُ لَا يَمْلِكُهَا إِلَّا أَنتَ',
            'translation': 'O Allah, I ask You from Your bounty and mercy, for indeed, no one possesses them except You',
            'source': 'Tirmidhi'
          },
          {
            'arabic': 'رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا',
            'translation': 'Our Lord, do not impose blame upon us if we have forgotten or erred',
            'source': 'Quran 2:286'
          }
        ];

    // Add more cases...
      default:
        return [
          {
            'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
            'translation': 'Our Lord, give us in this world good and in the next world good and protect us from the punishment of the Fire',
            'source': 'Quran 2:201'
          }
        ];
    }
  }

  Map<String, String> _getStoryForMood(String moodId) {
    switch (moodId) {
      case 'grateful':
        return {
          'title': 'Prophet Sulaiman (AS) and Gratitude',
          'story': 'Despite being given a kingdom unlike any other, Prophet Sulaiman always remained grateful to Allah. When he saw the Queen of Sheba\'s throne brought to him instantly, he said, "This is from the favor of my Lord to test me whether I will be grateful or ungrateful."',
          'lesson': 'True gratitude recognizes that all blessings come from Allah and uses them in ways that please Him.',
          'source': 'Quran 27:40'
        };

      case 'anxious':
        return {
          'title': 'Prophet Yunus (AS) in the Whale',
          'story': 'When Prophet Yunus found himself in the belly of the whale, in complete darkness and distress, he called upon Allah with the words: "La ilaha illa anta subhanaka inni kuntu min az-zalimin" (There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers). Allah responded to his call and saved him from his distress.',
          'lesson': 'In times of anxiety and distress, turn to Allah with humility and sincere repentance. He is always ready to respond to those who call upon Him.',
          'source': 'Quran 21:87-88'
        };

      case 'sad':
        return {
          'title': 'Prophet Yaqub (AS) and Patience',
          'story': 'When Prophet Yaqub lost his beloved son Yusuf, he grieved deeply but never lost faith in Allah. He said, "I only complain of my suffering and my grief to Allah." His patience and trust in Allah\'s wisdom eventually led to the reunion with his son.',
          'lesson': 'Sadness is part of human experience, but maintaining faith and patience during difficult times brings Allah\'s mercy and eventual relief.',
          'source': 'Quran 12:86'
        };

      default:
        return {
          'title': 'The Mercy of Allah',
          'story': 'Allah\'s mercy encompasses all things, and He is always ready to forgive and guide those who turn to Him sincerely.',
          'lesson': 'No matter what you\'re feeling, Allah\'s door is always open for those who seek Him.',
          'source': 'Quran 7:156'
        };
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
              widget.mood.color.withOpacity(0.1),
              theme.scaffoldBackgroundColor,
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
                  padding: EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildMoodIndicator(theme),
                      ),
                      SizedBox(height: 24),
                      _buildTabSelector(theme),
                      SizedBox(height: 24),
                      _buildTabContent(theme),
                      SizedBox(height: 32),
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
        title: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Text(
                'Healing Journey',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMoodIndicator(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.mood.color.withOpacity(0.15),
            widget.mood.color.withOpacity(0.08),
          ],
        ),
        border: Border.all(
          color: widget.mood.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.mood.color.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  widget.mood.color.withOpacity(0.3),
                  widget.mood.color.withOpacity(0.1),
                ],
              ),
            ),
            child: Center(
              child: Text(
                widget.mood.emoji,
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feeling ${widget.mood.name}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: widget.mood.color,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Allah is with you in every moment',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
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

  Widget _buildTabSelector(ThemeData theme) {
    final tabs = ['Dhikr', 'Du\'as', 'Story'];

    return Container(
      height: 50,
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
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  selectedTabIndex = index;
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
                      widget.mood.color,
                      widget.mood.color.withOpacity(0.8),
                    ],
                  )
                      : null,
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme) {
    switch (selectedTabIndex) {
      case 0:
        return _buildDhikrSection(theme);
      case 1:
        return _buildDuasSection(theme);
      case 2:
        return _buildStorySection(theme);
      default:
        return _buildDhikrSection(theme);
    }
  }

  Widget _buildDhikrSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Recommended Dhikr', Icons.auto_awesome, theme),
        SizedBox(height: 16),
        ...recommendedDhikr.map((dhikr) => _buildDhikrCard(dhikr, theme)),
      ],
    );
  }

  Widget _buildDuasSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Healing Du\'as', Icons.favorite, theme),
        SizedBox(height: 16),
        ...recommendedDuas.map((dua) => _buildDuaCard(dua, theme)),
      ],
    );
  }

  Widget _buildStorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Prophetic Wisdom', Icons.menu_book, theme),
        SizedBox(height: 16),
        _buildStoryCard(theme),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                widget.mood.color.withOpacity(0.2),
                widget.mood.color.withOpacity(0.1),
              ],
            ),
          ),
          child: Icon(
            icon,
            color: widget.mood.color,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildDhikrCard(Map<String, String> dhikr, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: widget.mood.color.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: widget.mood.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dhikr['transliteration'] ?? '',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: widget.mood.color,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.mood.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dhikr['arabic'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  height: 1.8,
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
            SizedBox(height: 16),
            Text(
              dhikr['translation'] ?? '',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: theme.textTheme.bodyMedium?.color,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (dhikr['source']?.isNotEmpty == true) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.mood.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Source: ${dhikr['source']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.mood.color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDuaCard(Map<String, String> dua, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: widget.mood.color.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: widget.mood.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.mood.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dua['arabic'] ?? '',
                style: TextStyle(
                  fontSize: 22,
                  height: 1.8,
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
            SizedBox(height: 16),
            Text(
              dua['translation'] ?? '',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: theme.textTheme.bodyMedium?.color,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (dua['source']?.isNotEmpty == true) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.mood.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Source: ${dua['source']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.mood.color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: widget.mood.color.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: widget.mood.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              healingStory['title'] ?? '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: widget.mood.color,
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.mood.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                healingStory['story'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.mood.color.withOpacity(0.1),
                    widget.mood.color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: widget.mood.color,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Lesson',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.mood.color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    healingStory['lesson'] ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: theme.textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (healingStory['source']?.isNotEmpty == true) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.mood.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Source: ${healingStory['source']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.mood.color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}