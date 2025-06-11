class Surah {
  final int number;
  final String arabicName;
  final String englishName;
  final String transliteration;
  final int verses;
  final String revelation; // Meccan or Medinan
  final String meaning;
  final List<String> benefits;
  final List<String> recommendedTimes;
  final String audioUrl;
  final List<Verse> fullText;

  Surah({
    required this.number,
    required this.arabicName,
    required this.englishName,
    required this.transliteration,
    required this.verses,
    required this.revelation,
    required this.meaning,
    required this.benefits,
    required this.recommendedTimes,
    required this.audioUrl,
    required this.fullText,
  });
}

class Verse {
  final int number;
  final String arabic;
  final String translation;
  final String transliteration;

  Verse({
    required this.number,
    required this.arabic,
    required this.translation,
    required this.transliteration,
  });
}
// TODO Implement this library.