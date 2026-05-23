enum MeditationCategory { breathing, sleep, focus, anxiety }

extension MeditationCategoryX on MeditationCategory {
  String get label {
    switch (this) {
      case MeditationCategory.breathing:
        return 'Pernapasan';
      case MeditationCategory.sleep:
        return 'Tidur';
      case MeditationCategory.focus:
        return 'Fokus';
      case MeditationCategory.anxiety:
        return 'Kecemasan';
    }
  }
}

class MeditationSessionModel {
  final String id;
  final String title;
  final String description;
  final int duration; // seconds
  final String audioUrl;
  final String thumbnailUrl;
  final MeditationCategory category;

  const MeditationSessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.audioUrl,
    required this.thumbnailUrl,
    required this.category,
  });

  String get durationLabel => '${duration ~/ 60} menit';

  factory MeditationSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return MeditationSessionModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? 0,
      audioUrl: map['audioUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      category: MeditationCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => MeditationCategory.focus,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'duration': duration,
        'audioUrl': audioUrl,
        'thumbnailUrl': thumbnailUrl,
        'category': category.name,
      };
}
