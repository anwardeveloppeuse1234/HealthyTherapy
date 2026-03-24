import 'package:uuid/uuid.dart';
import '../models/appointment.dart';
import 'storage_service.dart';

class AppointmentService {
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  final StorageService _storage = StorageService();
  final Uuid _uuid = const Uuid();

  // Créer un rendez-vous
  Future<bool> createAppointment({
    required String patientId,
    required String professionalId,
    required String title,
    required String description,
    required DateTime date,
    required String startTime,
    required String endTime,
    required AppointmentType type,
    String? location,
    String? notes,
  }) async {
    try {
      final appointment = Appointment(
        id: _uuid.v4(),
        patientId: patientId,
        professionalId: professionalId,
        title: title,
        description: description,
        date: date,
        startTime: startTime,
        endTime: endTime,
        type: type,
        status: AppointmentStatus.scheduled,
        location: location,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await _storage.addToList(
        'appointments.json',
        'appointments',
        appointment,
        (a) => a.toJson(),
        Appointment.fromJson,
      );
    } catch (e) {
      print('Erreur lors de la création du rendez-vous: $e');
      return false;
    }
  }

  // Récupérer tous les rendez-vous d'un utilisateur
  Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      final appointments = await _storage.readList<Appointment>(
        'appointments.json',
        'appointments',
        Appointment.fromJson,
      );

      return appointments
          .where((a) => a.patientId == userId || a.professionalId == userId)
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      print('Erreur lors de la récupération des rendez-vous: $e');
      return [];
    }
  }

  // Récupérer les rendez-vous par date
  Future<List<Appointment>> getAppointmentsByDate(
    String userId,
    DateTime date,
  ) async {
    final appointments = await getUserAppointments(userId);
    return appointments.where((a) {
      return a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day;
    }).toList();
  }

  // Récupérer les rendez-vous par période
  Future<List<Appointment>> getAppointmentsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final appointments = await getUserAppointments(userId);
    return appointments.where((a) {
      return a.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          a.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Récupérer les rendez-vous à venir
  Future<List<Appointment>> getUpcomingAppointments(String userId) async {
    final appointments = await getUserAppointments(userId);
    final now = DateTime.now();

    return appointments.where((a) {
      return a.date.isAfter(now) &&
          a.status != AppointmentStatus.cancelled &&
          a.status != AppointmentStatus.completed;
    }).toList();
  }

  // Récupérer les rendez-vous passés
  Future<List<Appointment>> getPastAppointments(String userId) async {
    final appointments = await getUserAppointments(userId);
    final now = DateTime.now();

    return appointments.where((a) {
      return a.date.isBefore(now) || a.status == AppointmentStatus.completed;
    }).toList();
  }

  // Mettre à jour un rendez-vous
  Future<bool> updateAppointment(Appointment appointment) async {
    try {
      return await _storage.updateInList(
        'appointments.json',
        'appointments',
        appointment.id,
        appointment.copyWith(updatedAt: DateTime.now()),
        (a) => a.id,
        (a) => a.toJson(),
        Appointment.fromJson,
      );
    } catch (e) {
      print('Erreur lors de la mise à jour du rendez-vous: $e');
      return false;
    }
  }

  // Changer le statut d'un rendez-vous
  Future<bool> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    try {
      final appointments = await _storage.readList<Appointment>(
        'appointments.json',
        'appointments',
        Appointment.fromJson,
      );

      final appointment = appointments.firstWhere((a) => a.id == appointmentId);

      return await updateAppointment(appointment.copyWith(status: status));
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      return false;
    }
  }

  // Annuler un rendez-vous
  Future<bool> cancelAppointment(String appointmentId) async {
    return await updateAppointmentStatus(
      appointmentId,
      AppointmentStatus.cancelled,
    );
  }

  // Confirmer un rendez-vous
  Future<bool> confirmAppointment(String appointmentId) async {
    return await updateAppointmentStatus(
      appointmentId,
      AppointmentStatus.confirmed,
    );
  }

  // Marquer un rendez-vous comme terminé
  Future<bool> completeAppointment(String appointmentId) async {
    return await updateAppointmentStatus(
      appointmentId,
      AppointmentStatus.completed,
    );
  }

  // Supprimer un rendez-vous
  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      return await _storage.deleteFromList(
        'appointments.json',
        'appointments',
        appointmentId,
        (a) => a.id,
        (a) => a.toJson(),
        Appointment.fromJson,
      );
    } catch (e) {
      print('Erreur lors de la suppression du rendez-vous: $e');
      return false;
    }
  }

  // Vérifier les conflits de rendez-vous
  Future<bool> hasConflict({
    required String professionalId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeAppointmentId,
  }) async {
    final appointments = await getUserAppointments(professionalId);

    return appointments.any((a) {
      if (excludeAppointmentId != null && a.id == excludeAppointmentId) {
        return false;
      }

      if (a.date.year != date.year ||
          a.date.month != date.month ||
          a.date.day != date.day) {
        return false;
      }

      if (a.status == AppointmentStatus.cancelled) {
        return false;
      }

      // Vérifier le chevauchement des horaires
      return _timeOverlaps(startTime, endTime, a.startTime, a.endTime);
    });
  }

  bool _timeOverlaps(String start1, String end1, String start2, String end2) {
    final s1 = _timeToMinutes(start1);
    final e1 = _timeToMinutes(end1);
    final s2 = _timeToMinutes(start2);
    final e2 = _timeToMinutes(end2);

    return (s1 < e2) && (e1 > s2);
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // Obtenir les créneaux disponibles pour un professionnel à une date donnée
  Future<List<String>> getAvailableTimeSlots(
    String professionalId,
    DateTime date,
  ) async {
    final List<String> availableSlots = [];

    // Générer des créneaux de 30 minutes de 8h à 18h
    for (int hour = 8; hour < 18; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final startHour = hour;
        final startMinute = minute;
        final endHour = minute == 30 ? hour + 1 : hour;
        final endMinute = minute == 30 ? 0 : 30;

        final startTime =
            '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
        final endTime =
            '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

        final hasConflictResult = await hasConflict(
          professionalId: professionalId,
          date: date,
          startTime: startTime,
          endTime: endTime,
        );

        if (!hasConflictResult) {
          availableSlots.add(startTime);
        }
      }
    }

    return availableSlots;
  }

  // Vérifier si un créneau spécifique est disponible
  Future<bool> isTimeSlotAvailable(
    String professionalId,
    DateTime date,
    String startTime,
    String endTime,
  ) async {
    return !await hasConflict(
      professionalId: professionalId,
      date: date,
      startTime: startTime,
      endTime: endTime,
    );
  }
}
