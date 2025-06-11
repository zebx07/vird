class Wisdom {
  final String id;
  final String arabicText;
  final String translation;
  final String source;
  final String category;
  final bool isShown;

  Wisdom({
    required this.id,
    required this.arabicText,
    required this.translation,
    required this.source,
    required this.category,
    this.isShown = false,
  });

  factory Wisdom.fromJson(Map<String, dynamic> json) {
    return Wisdom(
      id: json['id'],
      arabicText: json['arabic_text'],
      translation: json['translation'],
      source: json['source'],
      category: json['category'],
      isShown: json['is_shown'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic_text': arabicText,
      'translation': translation,
      'source': source,
      'category': category,
      'is_shown': isShown ? 1 : 0,
    };
  }

  static List<Wisdom> getSampleWisdom() {
    return [
      Wisdom(
        id: 'wisdom_1',
        arabicText: 'الدُّنْيَا مَتَاعٌ وَخَيْرُ مَتَاعِهَا الْمَرْأَةُ الصَّالِحَةُ',
        translation: 'The world is but a provision, and the best provision of the world is a righteous woman.',
        source: 'Sahih Muslim',
        category: 'family',
      ),
      Wisdom(
        id: 'wisdom_2',
        arabicText: 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ طَرِيقًا إِلَى الْجَنَّةِ',
        translation: 'Whoever takes a path upon which to obtain knowledge, Allah makes the path to Paradise easy for him.',
        source: 'Sahih Muslim',
        category: 'knowledge',
      ),
      Wisdom(
        id: 'wisdom_3',
        arabicText: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
        translation: 'Actions are judged by intentions.',
        source: 'Sahih Bukhari',
        category: 'general',
      ),
      Wisdom(
        id: 'wisdom_4',
        arabicText: 'الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنَ الْمُؤْمِنِ الضَّعِيفِ',
        translation: 'The strong believer is better and more beloved to Allah than the weak believer, while there is good in both.',
        source: 'Sahih Muslim',
        category: 'strength',
      ),
      Wisdom(
        id: 'wisdom_5',
        arabicText: 'مَنْ لَا يَرْحَمْ لَا يُرْحَمْ',
        translation: 'Whoever does not show mercy will not be shown mercy.',
        source: 'Sahih Bukhari',
        category: 'mercy',
      ),
    ];
  }
}// TODO Implement this library.