import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  // Lire un fichier JSON
  Future<Map<String, dynamic>> readJson(String filename) async {
    try {
      final file = await _getFile(filename);
      if (!await file.exists()) {
        return {};
      }
      final contents = await file.readAsString();
      return json.decode(contents) as Map<String, dynamic>;
    } catch (e) {
      print('Erreur lors de la lecture de $filename: $e');
      return {};
    }
  }

  // Écrire dans un fichier JSON
  Future<bool> writeJson(String filename, Map<String, dynamic> data) async {
    try {
      final file = await _getFile(filename);
      final jsonString = json.encode(data);
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      print('Erreur lors de l\'écriture de $filename: $e');
      return false;
    }
  }

  // Lire une liste d'objets depuis JSON
  Future<List<T>> readList<T>(
    String filename,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final data = await readJson(filename);
      if (!data.containsKey(key)) {
        return [];
      }
      final list = data[key] as List;
      return list.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Erreur lors de la lecture de la liste $key depuis $filename: $e');
      return [];
    }
  }

  // Écrire une liste d'objets dans JSON
  Future<bool> writeList<T>(
    String filename,
    String key,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final data = await readJson(filename);
      data[key] = items.map((item) => toJson(item)).toList();
      return await writeJson(filename, data);
    } catch (e) {
      print('Erreur lors de l\'écriture de la liste $key dans $filename: $e');
      return false;
    }
  }

  // Ajouter un élément à une liste
  Future<bool> addToList<T>(
    String filename,
    String key,
    T item,
    Map<String, dynamic> Function(T) toJson,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final items = await readList(filename, key, fromJson);
      items.add(item);
      return await writeList(filename, key, items, toJson);
    } catch (e) {
      print('Erreur lors de l\'ajout à la liste $key dans $filename: $e');
      return false;
    }
  }

  // Mettre à jour un élément dans une liste
  Future<bool> updateInList<T>(
    String filename,
    String key,
    String id,
    T updatedItem,
    String Function(T) getId,
    Map<String, dynamic> Function(T) toJson,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final items = await readList(filename, key, fromJson);
      final index = items.indexWhere((item) => getId(item) == id);
      if (index != -1) {
        items[index] = updatedItem;
        return await writeList(filename, key, items, toJson);
      }
      return false;
    } catch (e) {
      print('Erreur lors de la mise à jour dans la liste $key dans $filename: $e');
      return false;
    }
  }

  // Supprimer un élément d'une liste
  Future<bool> deleteFromList<T>(
    String filename,
    String key,
    String id,
    String Function(T) getId,
    Map<String, dynamic> Function(T) toJson,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final items = await readList(filename, key, fromJson);
      items.removeWhere((item) => getId(item) == id);
      return await writeList(filename, key, items, toJson);
    } catch (e) {
      print('Erreur lors de la suppression dans la liste $key dans $filename: $e');
      return false;
    }
  }

  // Vérifier si un fichier existe
  Future<bool> fileExists(String filename) async {
    final file = await _getFile(filename);
    return await file.exists();
  }

  // Supprimer un fichier
  Future<bool> deleteFile(String filename) async {
    try {
      final file = await _getFile(filename);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de $filename: $e');
      return false;
    }
  }

  // Initialiser les fichiers JSON avec des structures vides
  Future<void> initializeFiles() async {
    final files = {
      'users.json': {'users': []},
      'symptoms.json': {'symptoms': []},
      'exercises.json': {'exercises': []},
      'user_exercises.json': {'userExercises': []},
      'appointments.json': {'appointments': []},
      'messages.json': {'conversations': [], 'messages': []},
      'forum.json': {'posts': [], 'comments': []},
      'reports.json': {'reports': []},
    };

    for (final entry in files.entries) {
      if (!await fileExists(entry.key)) {
        await writeJson(entry.key, entry.value);
      }
    }
  }
}
