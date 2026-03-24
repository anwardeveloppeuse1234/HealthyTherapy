class Appointment {
  final String id;
  final String patientId;
  final String professionalId;
  final String title;
  final String description;
  final DateTime date;
  final String startTime;
  final String endTime;
  final AppointmentType type;
  final AppointmentStatus status;
  final String? location;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.professionalId,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.status,
    this.location,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'professionalId': professionalId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'location': location,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patientId'],
      professionalId: json['professionalId'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      type: AppointmentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      location: json['location'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Appointment copyWith({
    String? id,
    String? patientId,
    String? professionalId,
    String? title,
    String? description,
    DateTime? date,
    String? startTime,
    String? endTime,
    AppointmentType? type,
    AppointmentStatus? status,
    String? location,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      professionalId: professionalId ?? this.professionalId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum AppointmentType {
  consultation,
  therapy,
  checkup,
  other,
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  cancelled,
  completed,
}

extension AppointmentTypeExtension on AppointmentType {
  String get displayName {
    switch (this) {
      case AppointmentType.consultation:
        return 'Consultation';
      case AppointmentType.therapy:
        return 'Thérapie';
      case AppointmentType.checkup:
        return 'Contrôle';
      case AppointmentType.other:
        return 'Autre';
    }
  }
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get displayName {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Planifié';
      case AppointmentStatus.confirmed:
        return 'Confirmé';
      case AppointmentStatus.cancelled:
        return 'Annulé';
      case AppointmentStatus.completed:
        return 'Terminé';
    }
  }
}
