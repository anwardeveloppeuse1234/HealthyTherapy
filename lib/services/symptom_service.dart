import 'package:uuid/uuid.dart';
import '../models/symptom.dart';
import 'storage_service.dart';

class SymptomService {
  static final SymptomService _instance = SymptomService._internal();
  factory SymptomService() => _instance;
  SymptomService._internal();

  final StorageService _storage = StorageService();
  final Uuid _uuid = const Uuid();

  // Ajouter un symptôme
  Future<bool> addSymptom({
    required String userId,
    required SymptomType type,
    required int severity,
    required String description,
    required DateTime date,
    required String time,
    int? duration,
    List<String>? triggers,
  }) async {
    try {
      final symptom = Symptom(
        id: _uuid.v4(),
        userId: userId,
        type: type,
        severity: severity,
        description: description,
        date: date,
        time: time,
        duration: duration,
        triggers: triggers ?? [],
        createdAt: DateTime.now(),
      );

      return await _storage.addToList(
        'symptoms.json',
        'symptoms',
        symptom,
        (s) => s.toJson(),
        Symptom.fromJson,
      );
    } catch (e) {
      print('Erreur lors de l\'ajout du symptôme: $e');
      return false;
    }
  }

  // Récupérer tous les symptômes d'un utilisateur
  Future<List<Symptom>> getUserSymptoms(String userId) async {
    try {
      final symptoms = await _storage.readList<Symptom>(
        'symptoms.json',
        'symptoms',
        Symptom.fromJson,
      );

      return symptoms.where((s) => s.userId == userId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('Erreur lors de la récupération des symptômes: $e');
      return [];
    }
  }

  // Récupérer les symptômes par période
  Future<List<Symptom>> getSymptomsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final symptoms = await getUserSymptoms(userId);
    return symptoms.where((s) {
      return s.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          s.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Récupérer les symptômes par type
  Future<List<Symptom>> getSymptomsByType(
    String userId,
    SymptomType type,
  ) async {
    final symptoms = await getUserSymptoms(userId);
    return symptoms.where((s) => s.type == type).toList();
  }

  // Calculer la sévérité moyenne
  Future<double> getAverageSeverity(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<Symptom> symptoms;

    if (startDate != null && endDate != null) {
      symptoms = await getSymptomsByDateRange(userId, startDate, endDate);
    } else {
      symptoms = await getUserSymptoms(userId);
    }

    if (symptoms.isEmpty) return 0.0;

    final total = symptoms.fold<int>(0, (sum, s) => sum + s.severity);
    return total / symptoms.length;
  }

  // Trouver le symptôme le plus fréquent
  Future<SymptomType?> getMostCommonSymptom(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<Symptom> symptoms;

    if (startDate != null && endDate != null) {
      symptoms = await getSymptomsByDateRange(userId, startDate, endDate);
    } else {
      symptoms = await getUserSymptoms(userId);
    }

    if (symptoms.isEmpty) return null;

    final typeCount = <SymptomType, int>{};
    for (final symptom in symptoms) {
      typeCount[symptom.type] = (typeCount[symptom.type] ?? 0) + 1;
    }

    return typeCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Supprimer un symptôme
  Future<bool> deleteSymptom(String symptomId) async {
    try {
      return await _storage.deleteFromList(
        'symptoms.json',
        'symptoms',
        symptomId,
        (s) => s.id,
        (s) => s.toJson(),
        Symptom.fromJson,
      );
    } catch (e) {
      print('Erreur lors de la suppression du symptôme: $e');
      return false;
    }
  }

  // Obtenir des statistiques
  Future<Map<String, dynamic>> getStatistics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<Symptom> symptoms;

    if (startDate != null && endDate != null) {
      symptoms = await getSymptomsByDateRange(userId, startDate, endDate);
    } else {
      symptoms = await getUserSymptoms(userId);
    }

    final typeCount = <SymptomType, int>{};
    int totalSeverity = 0;

    for (final symptom in symptoms) {
      typeCount[symptom.type] = (typeCount[symptom.type] ?? 0) + 1;
      totalSeverity += symptom.severity;
    }

    return {
      'totalSymptoms': symptoms.length,
      'averageSeverity': symptoms.isEmpty ? 0.0 : totalSeverity / symptoms.length,
      'typeDistribution': typeCount,
      'mostCommon': await getMostCommonSymptom(userId, startDate: startDate, endDate: endDate),
    };
  }
}
