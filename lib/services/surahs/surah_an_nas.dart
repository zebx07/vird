import '../../models/surah.dart';

class SurahAnNas {
  static Surah getSurah() {
    return Surah(
      number: 114,
      arabicName: 'سُورَةُ النَّاسِ',
      englishName: 'An-Nas',
      transliteration: 'An-Nas',
      verses: 6,
      revelation: 'Meccan',
      meaning: 'Mankind',
      benefits: [
        'Protection from whispers',
        'Shield from Satan',
        'Mental peace',
        'Spiritual protection',
        'Divine refuge'
      ],
      recommendedTimes: ['morning', 'evening', 'protection'],
      audioUrl: 'https://example.com/audio/114.mp3',
      fullText: [
        Verse(
          number: 1,
          arabic: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
          translation: 'Say, "I seek refuge in the Lord of mankind,',
          transliteration: 'Qul a\'oozu bi rabbin-nas',
        ),
        Verse(
          number: 2,
          arabic: 'مَلِكِ النَّاسِ',
          translation: 'The Sovereign of mankind,',
          transliteration: 'Malikin-nas',
        ),
        Verse(
          number: 3,
          arabic: 'إِلَٰهِ النَّاسِ',
          translation: 'The God of mankind,',
          transliteration: 'Ilahin-nas',
        ),
        Verse(
          number: 4,
          arabic: 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
          translation: 'From the evil of the retreating whisperer -',
          transliteration: 'Min sharril-waswasil-khannas',
        ),
        Verse(
          number: 5,
          arabic: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
          translation: 'Who whispers [evil] into the breasts of mankind -',
          transliteration: 'Allazee yuwaswisu fee sudoorin-nas',
        ),
        Verse(
          number: 6,
          arabic: 'مِنَ الْجِنَّةِ وَالنَّاسِ',
          translation: 'From among the jinn and mankind."',
          transliteration: 'Minal-jinnati wan-nas',
        ),
      ],
    );
  }
}
