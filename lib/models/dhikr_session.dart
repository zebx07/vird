class DhikrSession {
  final String id;
  final String dhikrText;
  final int targetCount;
  final int actualCount;
  final int durationMinutes;
  final DateTime completedAt;
  final String? moodBefore;
  final String? moodAfter;

  DhikrSession({
    required this.id,
    required this.dhikrText,
    required this.targetCount,
    required this.actualCount,
    required this.durationMinutes,
    required this.completedAt,
    this.moodBefore,
    this.moodAfter,
  });

  factory DhikrSession.fromJson(Map<String, dynamic> json) {
    return DhikrSession(
      id: json['id'],
      dhikrText: json['dhikr_text'],
      targetCount: json['target_count'],
      actualCount: json['actual_count'],
      durationMinutes: json['duration_minutes'],
      completedAt: DateTime.parse(json['completed_at']),
      moodBefore: json['mood_before'],
      moodAfter: json['mood_after'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dhikr_text': dhikrText,
      'target_count': targetCount,
      'actual_count': actualCount,
      'duration_minutes': durationMinutes,
      'completed_at': completedAt.toIso8601String(),
      'mood_before': moodBefore,
      'mood_after': moodAfter,
    };
  }
}

class DhikrTemplate {
  final String id;
  final String arabicText;
  final String transliteration;
  final String translation;
  final int recommendedCount;
  final String category;
  final String source;
  final List<String> benefits;

  DhikrTemplate({
    required this.id,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    required this.recommendedCount,
    required this.category,
    required this.source,
    required this.benefits,
  });

  static List<DhikrTemplate> getDefaultDhikr() {
    return [
      DhikrTemplate(
        id: 'subhanallah',
        arabicText: 'سُبْحَانَ اللهِ',
        transliteration: 'Subhan Allah',
        translation: 'Glory be to Allah',
        recommendedCount: 33,
        category: 'Tasbih',
        source: 'Sahih Bukhari',
        benefits: ['Purifies the heart', 'Brings peace'],
      ),
      DhikrTemplate(
        id: 'alhamdulillah',
        arabicText: 'الْحَمْدُ لِلَّهِ',
        transliteration: 'Alhamdulillah',
        translation: 'All praise is due to Allah',
        recommendedCount: 33,
        category: 'Tahmid',
        source: 'Sahih Muslim',
        benefits: ['Increases gratitude', 'Brings blessings'],
      ),
      DhikrTemplate(
        id: 'allahu_akbar',
        arabicText: 'اللهُ أَكْبَرُ',
        transliteration: 'Allahu Akbar',
        translation: 'Allah is the Greatest',
        recommendedCount: 34,
        category: 'Takbir',
        source: 'Sahih Bukhari',
        benefits: ['Strengthens faith', 'Reminds of Allah\'s greatness'],
      ),
      DhikrTemplate(
        id: 'la_hawla',
        arabicText: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
        transliteration: 'La hawla wa la quwwata illa billah',
        translation: 'There is no power except with Allah',
        recommendedCount: 100,
        category: 'Hawqala',
        source: 'Sahih Bukhari',
        benefits: ['Removes difficulties', 'Brings strength'],
      ),
      DhikrTemplate(
        id: 'salawat',
        arabicText: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
        transliteration: 'Allahumma salli ala Muhammad wa ala ali Muhammad',
        translation: 'O Allah, send blessings upon Muhammad and his family',
        recommendedCount: 100,
        category: 'Salawat',
        source: 'Sahih Bukhari',
        benefits: ['Brings Allah\'s blessings', 'Increases love for Prophet'],
      ),
    ];
  }
}// TODO Implement this library.