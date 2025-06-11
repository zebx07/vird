import '../../models/surah.dart';

class SurahAlFalaq {
  static Surah getSurah() {
    return Surah(
      number: 113,
      arabicName: 'سُورَةُ الْفَلَقِ',
      englishName: 'Al-Falaq',
      transliteration: 'Al-Falaq',
      verses: 5,
      revelation: 'Meccan',
      meaning: 'The Daybreak',
      benefits: [
        'Protection from evil',
        'Shield from black magic',
        'Safety from envy',
        'Morning protection',
        'Spiritual defense'
      ],
      recommendedTimes: ['morning', 'evening', 'protection'],
      audioUrl: 'https://example.com/audio/113.mp3',
      fullText: [
        Verse(
          number: 1,
          arabic: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          translation: 'Say, "I seek refuge in the Lord of daybreak',
          transliteration: 'Qul a\'oozu bi rabbil-falaq',
        ),
        Verse(
          number: 2,
          arabic: 'مِن شَرِّ مَا خَلَقَ',
          translation: 'From the evil of that which He created',
          transliteration: 'Min sharri ma khalaq',
        ),
        Verse(
          number: 3,
          arabic: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
          translation: 'And from the evil of darkness when it settles',
          transliteration: 'Wa min sharri ghasiqin iza waqab',
        ),
        Verse(
          number: 4,
          arabic: 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
          translation: 'And from the evil of the blowers in knots',
          transliteration: 'Wa min sharrin-naffasati fil-uqad',
        ),
        Verse(
          number: 5,
          arabic: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
          translation: 'And from the evil of an envier when he envies."',
          transliteration: 'Wa min sharri hasidin iza hasad',
        ),
      ],
    );
  }
}
// TODO Implement this library.