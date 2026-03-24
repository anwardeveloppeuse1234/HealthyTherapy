class Symptom {
  final String id;
  final String userId;
  final SymptomType type;
  final int severity; // 1-10
  final String description;
  final DateTime date;
  final String time;
  final int? duration; // en minutes
  final List<String> triggers;
  final DateTime createdAt;

  Symptom({
    required this.id,
    required this.userId,
    required this.type,
    required this.severity,
    required this.description,
    required this.date,
    required this.time,
    this.duration,
    required this.triggers,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'severity': severity,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'duration': duration,
      'triggers': triggers,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'],
      userId: json['userId'],
      type: SymptomType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      severity: json['severity'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      duration: json['duration'],
      triggers: List<String>.from(json['triggers'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum SymptomType {
  fatigue,
  pain,
  mobility,
  cognitive,
  visual,
  other,
}

extension SymptomTypeExtension on SymptomType {
  String get displayName {
    switch (this) {
      case SymptomType.fatigue:
        return 'Fatigue';
      case SymptomType.pain:
        return 'Douleur';
      case SymptomType.mobility:
        return 'Mobilité';
      case SymptomType.cognitive:
        return 'Cognitif';
      case SymptomType.visual:
        return 'Visuel';
      case SymptomType.other:
        return 'Autre';
    }
  }
}
