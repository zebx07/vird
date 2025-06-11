import '../models/surah.dart';
import 'surahs/surah_al_fatihah.dart';
import 'surahs/surah_al_ikhlas.dart';
import 'surahs/surah_al_falaq.dart';
import 'surahs/surah_an_nas.dart';
import 'surahs/surah_al_mulk.dart';
import 'surahs/surah_yaseen_part1.dart';

class SurahService {
  static List<Surah> getAllSurahs() {
    return [
      SurahAlFatihah.getSurah(),
      SurahYaseenComplete.getSurah(), // Combining parts
      _getSurahAlKahf(), // Placeholder for now
      _getSurahAlWaqiah(), // Placeholder for now
      SurahAlMulkComplete.getSurah(),
      _getSurahAsSajdah(), // Placeholder for now
      _getSurahAlJumah(), // Placeholder for now
      SurahAlIkhlas.getSurah(),
      SurahAlFalaq.getSurah(),
      SurahAnNas.getSurah(),
    ];
  }

  static Surah? getSurahByNumber(int number) {
    try {
      return getAllSurahs().firstWhere((surah) => surah.number == number);
    } catch (e) {
      return null;
    }
  }

  static List<Surah> getSurahsForTime(String timeOfDay) {
    return getAllSurahs()
        .where((surah) => surah.recommendedTimes.contains(timeOfDay))
        .toList();
  }

  static List<Surah> getFridaySurahs() {
    return getAllSurahs()
        .where((surah) => surah.recommendedTimes.contains('friday'))
        .toList();
  }

  // Placeholder methods - you can create separate files for these later
  static Surah _getSurahAlKahf() {
    return Surah(
      number: 18,
      arabicName: 'سُورَةُ الْكَهْفِ',
      englishName: 'Al-Kahf',
      transliteration: 'Al-Kahf',
      verses: 110,
      revelation: 'Meccan',
      meaning: 'The Cave',
      benefits: [
        'Light between two Fridays',
        'Protection from Dajjal (Antichrist)',
        'Forgiveness of sins between two Fridays',
        'Spiritual guidance',
        'Protection from trials'
      ],
      recommendedTimes: ['friday'],
      audioUrl: 'https://example.com/audio/018.mp3',
      fullText: [
        Verse(
          number: 1,
          arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَنزَلَ عَلَىٰ عَبْدِهِ الْكِتَابَ وَلَمْ يَجْعَل لَّهُ عِوَجًا',
          translation: 'All praise is due to Allah, who has sent down upon His Servant the Book and has not made therein any deviance.',
          transliteration: 'Alhamdu lillahil-lazee anzala ala abdihil-kitaba wa lam yaj\'al lahu iwajan',
        ),
        // More verses to be added in separate file
      ],
    );
  }

  static Surah _getSurahAlWaqiah() {
    return Surah(
      number: 56,
      arabicName: 'سُورَةُ الْوَاقِعَةِ',
      englishName: 'Al-Waqiah',
      transliteration: 'Al-Waqi\'ah',
      verses: 96,
      revelation: 'Meccan',
      meaning: 'The Inevitable',
      benefits: [
        'Protection from poverty',
        'Increase in sustenance',
        'Financial blessings',
        'Removal of hardship',
        'Spiritual wealth'
      ],
      recommendedTimes: ['evening', 'daily'],
      audioUrl: 'https://example.com/audio/056.mp3',
      fullText: [
        Verse(
          number: 1,
          arabic: 'إِذَا وَقَعَتِ الْوَاقِعَةُ',
          translation: 'When the Inevitable occurs,',
          transliteration: 'Iza waqa\'atil-waqi\'ah',
        ),
        // More verses to be added in separate file
      ],
    );
  }

  static Surah _getSurahAsSajdah() {
    return Surah(
      number: 32,
      arabicName: 'سُورَةُ السَّجْدَةِ',
      englishName: 'As-Sajdah',
      transliteration: 'As-Sajdah',
      verses: 30,
      revelation: 'Meccan',
      meaning: 'The Prostration',
      benefits: [
        'Peaceful sleep',
        'Protection through the night',
        'Spiritual purification',
        'Increased faith',
        'Divine guidance'
      ],
      recommendedTimes: ['night', 'before_sleep'],
      audioUrl: 'https://example.com/audio/032.mp3',
      fullText: [
        Verse(
          number: 1,
          arabic: 'الم',
          translation: 'Alif, Lam, Meem.',
          transliteration: 'Alif-Lam-Meem',
        ),
        // More verses to be added in separate file
      ],
    );
  }

  static Surah _getSurahAlJumah() {
    return Surah(
      number: 62,
      arabicName: 'سُورَةُ الْجُمُعَةِ',
      englishName: 'Al-Jumu\'ah',
      transliteration: 'Al-Jumu\'ah',
      verses: 11,
      revelation: 'Medinan',
      meaning: 'Friday',
      benefits: [
        'Emphasis on Friday prayer',
        'Community bonding',
        'Spiritual gathering',
        'Divine remembrance',
        'Weekly renewal'
      ],
      recommendedTimes: ['friday'],
      audioUrl: 'https://example.com/audio/062.mp3',
      fullText: [
        Verse(
          number: 1,
          arabic: 'يُسَبِّحُ لِلَّهِ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ الْمَلِكِ الْقُدُّوسِ الْعَزِيزِ الْحَكِيمِ',
          translation: 'Whatever is in the heavens and whatever is on the earth is exalting Allah, the Sovereign, the Pure, the Exalted in Might, the Wise.',
          transliteration: 'Yusabbihu lillahi ma fis-samawati wa ma fil-ardil-malikil-quddoosil-azeezil-hakeem',
        ),
        // More verses to be added in separate file
      ],
    );
  }
}
