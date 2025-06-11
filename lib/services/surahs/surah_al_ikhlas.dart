import '../../models/surah.dart';

class SurahAlIkhlas {
  static Surah getSurah() {
    return Surah(
      number: 112,
      arabicName: 'سُورَةُ الْإِخْلَاصِ',
      englishName: 'Al-Ikhlas',
      transliteration: 'Al-Ikhlas',
      verses: 4,
      revelation: 'Meccan',
      meaning: 'The Sincerity',
      benefits: [
        'Equals one-third of Quran',
        'Purification of faith',
        'Protection from shirk',
        'Spiritual cleansing',
        'Divine unity understanding'
      ],
      recommendedTimes: ['morning', 'evening', 'prayer'],
      audioUrl: 'https://example.com/audio/112.mp3',
      fullText: [
        Verse(
          number: 1,
          arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          translation: 'Say, "He is Allah, [who is] One,',
          transliteration: 'Qul huwal-lahu ahad',
        ),
        Verse(
          number: 2,
          arabic: 'اللَّهُ الصَّمَدُ',
          translation: 'Allah, the Eternal Refuge.',
          transliteration: 'Allahus-samad',
        ),
        Verse(
          number: 3,
          arabic: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
          translation: 'He neither begets nor is born,',
          transliteration: 'Lam yalid wa lam yoolad',
        ),
        Verse(
          number: 4,
          arabic: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
          translation: 'Nor is there to Him any equivalent."',
          transliteration: 'Wa lam yakun lahu kufuwan ahad',
        ),
      ],
    );
  }
}
// TODO Implement this library.