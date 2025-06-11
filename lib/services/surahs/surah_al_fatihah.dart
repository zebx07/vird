import '../../models/surah.dart';

class SurahAlFatihah {
  static Surah getSurah() {
    return Surah(
      number: 1,
      arabicName: 'سُورَةُ الْفَاتِحَةِ',
      englishName: 'Al-Fatihah',
      transliteration: 'Al-Faatihah',
      verses: 7,
      revelation: 'Meccan',
      meaning: 'The Opening',
      benefits: [
        'Complete cure for all diseases',
        'Protection from evil',
        'Spiritual healing',
        'Opens doors of mercy',
        'Foundation of all prayers'
      ],
      recommendedTimes: ['morning', 'evening', 'prayer', 'healing'],
      audioUrl: 'https://example.com/audio/001.mp3',
      fullText: [
        Verse(
          number: 1,
          arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          translation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
          transliteration: 'Bismillahir-Rahmanir-Raheem',
        ),
        Verse(
          number: 2,
          arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          translation: 'All praise is due to Allah, Lord of the worlds.',
          transliteration: 'Alhamdu lillahi rabbil-alameen',
        ),
        Verse(
          number: 3,
          arabic: 'الرَّحْمَٰنِ الرَّحِيمِ',
          translation: 'The Entirely Merciful, the Especially Merciful,',
          transliteration: 'Ar-Rahmanir-Raheem',
        ),
        Verse(
          number: 4,
          arabic: 'مَالِكِ يَوْمِ الدِّينِ',
          translation: 'Sovereign of the Day of Recompense.',
          transliteration: 'Maliki yawmid-deen',
        ),
        Verse(
          number: 5,
          arabic: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
          translation: 'It is You we worship and You we ask for help.',
          transliteration: 'Iyyaka na\'budu wa iyyaka nasta\'een',
        ),
        Verse(
          number: 6,
          arabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
          translation: 'Guide us to the straight path -',
          transliteration: 'Ihdinassiratal-mustaqeem',
        ),
        Verse(
          number: 7,
          arabic: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          translation: 'The path of those upon whom You have bestowed favor, not of those who have evoked anger or of those who are astray.',
          transliteration: 'Siratal-lazeena an\'amta alayhim ghayril-maghdoobi alayhim wa lad-dalleen',
        ),
      ],
    );
  }
}
