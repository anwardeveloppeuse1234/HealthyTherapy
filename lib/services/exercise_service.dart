import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../models/user_exercise.dart';
import 'storage_service.dart';

class ExerciseService {
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  final StorageService _storage = StorageService();
  final Uuid _uuid = const Uuid();

  // Créer un exercice
  Future<bool> createExercise({
    required String title,
    required String description,
    required ExerciseCategory category,
    required ExerciseDifficulty difficulty,
    required int duration,
    String? videoUrl,
    String? imageUrl,
    required List<String> instructions,
    required List<String> benefits,
    required List<String> precautions,
    required String createdBy,
  }) async {
    try {
      final exercise = Exercise(
        id: _uuid.v4(),
        title: title,
        description: description,
        category: category,
        difficulty: difficulty,
        duration: duration,
        videoUrl: videoUrl,
        imageUrl: imageUrl,
        instructions: instructions,
        benefits: benefits,
        precautions: precautions,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      return await _storage.addToList(
        'exercises.json',
        'exercises',
        exercise,
        (e) => e.toJson(),
        Exercise.fromJson,
      );
    } catch (e) {
      print('Erreur lors de la création de l\'exercice: $e');
      return false;
    }
  }

  // Récupérer tous les exercices
  Future<List<Exercise>> getAllExercises() async {
    try {
      return await _storage.readList<Exercise>(
        'exercises.json',
        'exercises',
        Exercise.fromJson,
      );
    } catch (e) {
      print('Erreur lors de la récupération des exercices: $e');
      return [];
    }
  }

  // Récupérer un exercice par ID
  Future<Exercise?> getExerciseById(String exerciseId) async {
    try {
      final exercises = await getAllExercises();
      return exercises.firstWhere((e) => e.id == exerciseId);
    } catch (e) {
      return null;
    }
  }

  // Filtrer les exercices
  Future<List<Exercise>> filterExercises({
    ExerciseCategory? category,
    ExerciseDifficulty? difficulty,
  }) async {
    final exercises = await getAllExercises();
    
    return exercises.where((e) {
      if (category != null && e.category != category) return false;
      if (difficulty != null && e.difficulty != difficulty) return false;
      return true;
    }).toList();
  }

  // Assigner un exercice à un patient
  Future<bool> assignExerciseToUser({
    required String userId,
    required String exerciseId,
    required String assignedBy,
    required ExerciseFrequency frequency,
  }) async {
    try {
      final userExercise = UserExercise(
        id: _uuid.v4(),
        userId: userId,
        exerciseId: exerciseId,
        assignedBy: assignedBy,
        assignedDate: DateTime.now(),
        frequency: frequency,
        completed: [],
        status: ExerciseStatus.active,
      );

      return await _storage.addToList(
        'user_exercises.json',
        'userExercises',
        userExercise,
        (ue) => ue.toJson(),
        UserExercise.fromJson,
      );
    } catch (e) {
      print('Erreur lors de l\'assignation de l\'exercice: $e');
      return false;
    }
  }

  // Récupérer les exercices d'un utilisateur
  Future<List<UserExercise>> getUserExercises(String userId) async {
    try {
      final userExercises = await _storage.readList<UserExercise>(
        'user_exercises.json',
        'userExercises',
        UserExercise.fromJson,
      );

      return userExercises.where((ue) => ue.userId == userId).toList();
    } catch (e) {
      print('Erreur lors de la récupération des exercices de l\'utilisateur: $e');
      return [];
    }
  }

  // Marquer un exercice comme complété
  Future<bool> completeExercise({
    required String userExerciseId,
    required int duration,
    String? notes,
    required int rating,
  }) async {
    try {
      final userExercises = await _storage.readList<UserExercise>(
        'user_exercises.json',
        'userExercises',
        UserExercise.fromJson,
      );

      final userExercise = userExercises.firstWhere((ue) => ue.id == userExerciseId);

      final completion = ExerciseCompletion(
        date: DateTime.now(),
        duration: duration,
        notes: notes,
        rating: rating,
      );

      final updatedCompleted = [...userExercise.completed, completion];

      final updatedUserExercise = UserExercise(
        id: userExercise.id,
        userId: userExercise.userId,
        exerciseId: userExercise.exerciseId,
        assignedBy: userExercise.assignedBy,
        assignedDate: userExercise.assignedDate,
        frequency: userExercise.frequency,
        completed: updatedCompleted,
        status: userExercise.status,
      );

      return await _storage.updateInList(
        'user_exercises.json',
        'userExercises',
        userExerciseId,
        updatedUserExercise,
        (ue) => ue.id,
        (ue) => ue.toJson(),
        UserExercise.fromJson,
      );
    } catch (e) {
      print('Erreur lors de la complétion de l\'exercice: $e');
      return false;
    }
  }

  // Mettre à jour le statut d'un exercice
  Future<bool> updateExerciseStatus(
    String userExerciseId,
    ExerciseStatus status,
  ) async {
    try {
      final userExercises = await _storage.readList<UserExercise>(
        'user_exercises.json',
        'userExercises',
        UserExercise.fromJson,
      );

      final userExercise = userExercises.firstWhere((ue) => ue.id == userExerciseId);

      final updatedUserExercise = UserExercise(
        id: userExercise.id,
        userId: userExercise.userId,
        exerciseId: userExercise.exerciseId,
        assignedBy: userExercise.assignedBy,
        assignedDate: userExercise.assignedDate,
        frequency: userExercise.frequency,
        completed: userExercise.completed,
        status: status,
      );

      return await _storage.updateInList(
        'user_exercises.json',
        'userExercises',
        userExerciseId,
        updatedUserExercise,
        (ue) => ue.id,
        (ue) => ue.toJson(),
        UserExercise.fromJson,
      );
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      return false;
    }
  }

  // Supprimer un exercice
  Future<bool> deleteExercise(String exerciseId) async {
    try {
      return await _storage.deleteFromList(
        'exercises.json',
        'exercises',
        exerciseId,
        (e) => e.id,
        (e) => e.toJson(),
        Exercise.fromJson,
      );
    } catch (e) {
      print('Erreur lors de la suppression de l\'exercice: $e');
      return false;
    }
  }
}
