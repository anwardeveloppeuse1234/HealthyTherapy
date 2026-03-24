class Report {
  final String id;
  final String userId; // Patient
  final String? generatedBy; // Professionnel
  final ReportType type;
  final DateTime startDate;
  final DateTime endDate;
  final ReportData data;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.userId,
    this.generatedBy,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'generatedBy': generatedBy,
      'type': type.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'data': data.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      userId: json['userId'],
      generatedBy: json['generatedBy'],
      type: ReportType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      data: ReportData.fromJson(json['data']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ReportData {
  final int symptomsCount;
  final int exercisesCompleted;
  final double averageSeverity;
  final String? mostCommonSymptom;
  final double progressPercentage;
  final String? notes;

  ReportData({
    required this.symptomsCount,
    required this.exercisesCompleted,
    required this.averageSeverity,
    this.mostCommonSymptom,
    required this.progressPercentage,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'symptomsCount': symptomsCount,
      'exercisesCompleted': exercisesCompleted,
      'averageSeverity': averageSeverity,
      'mostCommonSymptom': mostCommonSymptom,
      'progressPercentage': progressPercentage,
      'notes': notes,
    };
  }

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      symptomsCount: json['symptomsCount'] ?? 0,
      exercisesCompleted: json['exercisesCompleted'] ?? 0,
      averageSeverity: (json['averageSeverity'] ?? 0).toDouble(),
      mostCommonSymptom: json['mostCommonSymptom'],
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      notes: json['notes'],
    );
  }
}

enum ReportType {
  weekly,
  monthly,
  custom,
}

extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.weekly:
        return 'Hebdomadaire';
      case ReportType.monthly:
        return 'Mensuel';
      case ReportType.custom:
        return 'Personnalisé';
    }
  }
}
