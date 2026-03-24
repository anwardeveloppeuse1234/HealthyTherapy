class UserExercise {
  final String id;
  final String userId; // Patient
  final String exerciseId;
  final String assignedBy; // Professionnel
  final DateTime assignedDate;
  final ExerciseFrequency frequency;
  final List<ExerciseCompletion> completed;
  final ExerciseStatus status;

  UserExercise({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.assignedBy,
    required this.assignedDate,
    required this.frequency,
    required this.completed,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      'assignedBy': assignedBy,
      'assignedDate': assignedDate.toIso8601String(),
      'frequency': frequency.toString().split('.').last,
      'completed': completed.map((c) => c.toJson()).toList(),
      'status': status.toString().split('.').last,
    };
  }

  factory UserExercise.fromJson(Map<String, dynamic> json) {
    return UserExercise(
      id: json['id'],
      userId: json['userId'],
      exerciseId: json['exerciseId'],
      assignedBy: json['assignedBy'],
      assignedDate: DateTime.parse(json['assignedDate']),
      frequency: ExerciseFrequency.values.firstWhere(
        (e) => e.toString().split('.').last == json['frequency'],
      ),
      completed: (json['completed'] as List)
          .map((c) => ExerciseCompletion.fromJson(c))
          .toList(),
      status: ExerciseStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
    );
  }
}

class ExerciseCompletion {
  final DateTime date;
  final int duration; // en minutes
  final String? notes;
  final int rating; // 1-5

  ExerciseCompletion({
    required this.date,
    required this.duration,
    this.notes,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'duration': duration,
      'notes': notes,
      'rating': rating,
    };
  }

  factory ExerciseCompletion.fromJson(Map<String, dynamic> json) {
    return ExerciseCompletion(
      date: DateTime.parse(json['date']),
      duration: json['duration'],
      notes: json['notes'],
      rating: json['rating'],
    );
  }
}

enum ExerciseFrequency {
  daily,
  weekly,
  custom,
}

enum ExerciseStatus {
  active,
  paused,
  completed,
}
