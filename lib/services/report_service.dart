import 'package:healthy_therapy_ms/models/user_exercise.dart';
import 'package:uuid/uuid.dart';
import '../models/report.dart';
import '../models/symptom.dart';
import 'storage_service.dart';
import 'symptom_service.dart';
import 'exercise_service.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final StorageService _storage = StorageService();
  final SymptomService _symptomService = SymptomService();
  final ExerciseService _exerciseService = ExerciseService();
  final Uuid _uuid = const Uuid();

  // Générer un rapport
  Future<Report?> generateReport({
    required String userId,
    String? generatedBy,
    required ReportType type,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    try {
      // Récupérer les données pour la période
      final symptoms = await _symptomService.getSymptomsByDateRange(
        userId,
        startDate,
        endDate,
      );

      final userExercises = await _exerciseService.getUserExercises(userId);

      // Calculer les exercices complétés dans la période
      int exercisesCompleted = 0;
      for (final ue in userExercises) {
        exercisesCompleted += ue.completed.where((c) {
          return c.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              c.date.isBefore(endDate.add(const Duration(days: 1)));
        }).length;
      }

      // Calculer la sévérité moyenne
      double averageSeverity = 0.0;
      if (symptoms.isNotEmpty) {
        final totalSeverity =
            symptoms.fold<int>(0, (sum, s) => sum + s.severity);
        averageSeverity = totalSeverity / symptoms.length;
      }

      // Trouver le symptôme le plus commun
      String? mostCommonSymptom;
      if (symptoms.isNotEmpty) {
        final typeCount = <SymptomType, int>{};
        for (final symptom in symptoms) {
          typeCount[symptom.type] = (typeCount[symptom.type] ?? 0) + 1;
        }
        final mostCommon =
            typeCount.entries.reduce((a, b) => a.value > b.value ? a : b);
        mostCommonSymptom = mostCommon.key.displayName;
      }

      // Calculer le pourcentage de progrès
      // Basé sur la diminution de la sévérité moyenne et l'augmentation des exercices
      double progressPercentage = 0.0;
      if (symptoms.isNotEmpty && exercisesCompleted > 0) {
        // Formule simple: plus d'exercices et moins de sévérité = meilleur progrès
        final exerciseScore = (exercisesCompleted / 10).clamp(0.0, 1.0);
        final severityScore = (1 - (averageSeverity / 10)).clamp(0.0, 1.0);
        progressPercentage = ((exerciseScore + severityScore) / 2) * 100;
      }

      final reportData = ReportData(
        symptomsCount: symptoms.length,
        exercisesCompleted: exercisesCompleted,
        averageSeverity: averageSeverity,
        mostCommonSymptom: mostCommonSymptom,
        progressPercentage: progressPercentage,
        notes: notes,
      );

      final report = Report(
        id: _uuid.v4(),
        userId: userId,
        generatedBy: generatedBy,
        type: type,
        startDate: startDate,
        endDate: endDate,
        data: reportData,
        createdAt: DateTime.now(),
      );

      await _storage.addToList(
        'reports.json',
        'reports',
        report,
        (r) => r.toJson(),
        Report.fromJson,
      );

      return report;
    } catch (e) {
      print('Erreur lors de la génération du rapport: $e');
      return null;
    }
  }

  // Récupérer tous les rapports d'un utilisateur
  Future<List<Report>> getUserReports(String userId) async {
    try {
      final reports = await _storage.readList<Report>(
        'reports.json',
        'reports',
        Report.fromJson,
      );

      return reports.where((r) => r.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Erreur lors de la récupération des rapports: $e');
      return [];
    }
  }

  // Récupérer un rapport par ID
  Future<Report?> getReportById(String reportId) async {
    try {
      final reports = await _storage.readList<Report>(
        'reports.json',
        'reports',
        Report.fromJson,
      );

      return reports.firstWhere((r) => r.id == reportId);
    } catch (e) {
      return null;
    }
  }

  // Générer un rapport hebdomadaire
  Future<Report?> generateWeeklyReport(String userId,
      {String? generatedBy}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));

    return await generateReport(
      userId: userId,
      generatedBy: generatedBy,
      type: ReportType.weekly,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Générer un rapport mensuel
  Future<Report?> generateMonthlyReport(String userId,
      {String? generatedBy}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));

    return await generateReport(
      userId: userId,
      generatedBy: generatedBy,
      type: ReportType.monthly,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Supprimer un rapport
  Future<bool> deleteReport(String reportId) async {
    try {
      return await _storage.deleteFromList(
        'reports.json',
        'reports',
        reportId,
        (r) => r.id,
        (r) => r.toJson(),
        Report.fromJson,
      );
    } catch (e) {
      print('Erreur lors de la suppression du rapport: $e');
      return false;
    }
  }

  // Obtenir des statistiques globales pour un utilisateur
  Future<Map<String, dynamic>> getGlobalStatistics(String userId) async {
    try {
      final symptoms = await _symptomService.getUserSymptoms(userId);
      final userExercises = await _exerciseService.getUserExercises(userId);

      int totalExercisesCompleted = 0;
      for (final ue in userExercises) {
        totalExercisesCompleted += ue.completed.length;
      }

      double averageSeverity = 0.0;
      if (symptoms.isNotEmpty) {
        final totalSeverity =
            symptoms.fold<int>(0, (sum, s) => sum + s.severity);
        averageSeverity = totalSeverity / symptoms.length;
      }

      return {
        'totalSymptoms': symptoms.length,
        'totalExercisesCompleted': totalExercisesCompleted,
        'averageSeverity': averageSeverity,
        'activeExercises': userExercises
            .where((ue) => ue.status == ExerciseStatus.active)
            .length,
      };
    } catch (e) {
      return {};
    }
  }
}
