class DailyContent {
  final String id;
  final String type; // 'ayah', 'hadith', 'dhikr'
  final String arabicText;
  final String translation;
  final String source;
  final String timeOfDay; // 'morning', 'afternoon', 'evening', 'night'

  DailyContent({
    required this.id,
    required this.type,
    required this.arabicText,
    required this.translation,
    required this.source,
    required this.timeOfDay,
  });

  factory DailyContent.fromJson(Map<String, dynamic> json) {
    return DailyContent(
      id: json['id'],
      type: json['type'],
      arabicText: json['arabic_text'],
      translation: json['translation'],
      source: json['source'],
      timeOfDay: json['time_of_day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'arabic_text': arabicText,
      'translation': translation,
      'source': source,
      'time_of_day': timeOfDay,
    };
  }
}
