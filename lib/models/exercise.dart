class Exercise {
  final String id;
  final String title;
  final String description;
  final ExerciseCategory category;
  final ExerciseDifficulty difficulty;
  final int duration; // en minutes
  final String? videoUrl;
  final String? imageUrl;
  final List<String> instructions;
  final List<String> benefits;
  final List<String> precautions;
  final String createdBy; // ID du professionnel
  final DateTime createdAt;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.duration,
    this.videoUrl,
    this.imageUrl,
    required this.instructions,
    required this.benefits,
    required this.precautions,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'duration': duration,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'instructions': instructions,
      'benefits': benefits,
      'precautions': precautions,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: ExerciseCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      difficulty: ExerciseDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
      ),
      duration: json['duration'],
      videoUrl: json['videoUrl'],
      imageUrl: json['imageUrl'],
      instructions: List<String>.from(json['instructions'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      precautions: List<String>.from(json['precautions'] ?? []),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum ExerciseCategory {
  stretching,
  strength,
  balance,
  cardio,
  relaxation,
  mobility,
}

enum ExerciseDifficulty {
  easy,
  medium,
  hard,
}

extension ExerciseCategoryExtension on ExerciseCategory {
  String get displayName {
    switch (this) {
      case ExerciseCategory.stretching:
        return 'Étirement';
      case ExerciseCategory.strength:
        return 'Force';
      case ExerciseCategory.balance:
        return 'Équilibre';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.relaxation:
        return 'Relaxation';
      case ExerciseCategory.mobility:
        return 'mobility';
    }
  }
}

extension ExerciseDifficultyExtension on ExerciseDifficulty {
  String get displayName {
    switch (this) {
      case ExerciseDifficulty.easy:
        return 'Facile';
      case ExerciseDifficulty.medium:
        return 'Moyen';
      case ExerciseDifficulty.hard:
        return 'Difficile';
    }
  }
}
