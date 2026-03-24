import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StorageService _storage = StorageService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Uuid _uuid = const Uuid();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // Hasher un mot de passe
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Inscription
  Future<User?> register({
    required String email,
    required String password,
    required UserRole role,
    required String firstName,
    required String lastName,
    required String phone,
    DateTime? dateOfBirth,
    String? specialization,
  }) async {
    try {
      // Vérifier si l'email existe déjà
      final users = await _storage.readList<User>(
        'users.json',
        'users',
        User.fromJson,
      );

      if (users.any((u) => u.email == email)) {
        throw Exception('Un compte avec cet email existe déjà');
      }

      // Créer le nouvel utilisateur
      final user = User(
        id: _uuid.v4(),
        email: email,
        passwordHash: _hashPassword(password),
        role: role,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        specialization: specialization,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sauvegarder l'utilisateur
      await _storage.addToList(
        'users.json',
        'users',
        user,
        (u) => u.toJson(),
        User.fromJson,
      );

      return user;
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      return null;
    }
  }

  // Connexion
  Future<User?> login(String email, String password) async {
    try {
      final users = await _storage.readList<User>(
        'users.json',
        'users',
        User.fromJson,
      );

      final user = users.firstWhere(
        (u) => u.email == email && u.passwordHash == _hashPassword(password),
        orElse: () => throw Exception('Email ou mot de passe incorrect'),
      );

      _currentUser = user;
      
      // Sauvegarder l'ID de l'utilisateur de manière sécurisée
      await _secureStorage.write(key: 'userId', value: user.id);

      return user;
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return null;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _currentUser = null;
    await _secureStorage.delete(key: 'userId');
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final userId = await _secureStorage.read(key: 'userId');
    if (userId == null) return false;

    try {
      final users = await _storage.readList<User>(
        'users.json',
        'users',
        User.fromJson,
      );

      _currentUser = users.firstWhere((u) => u.id == userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Récupérer l'utilisateur actuel
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final userId = await _secureStorage.read(key: 'userId');
    if (userId == null) return null;

    try {
      final users = await _storage.readList<User>(
        'users.json',
        'users',
        User.fromJson,
      );

      _currentUser = users.firstWhere((u) => u.id == userId);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  // Mettre à jour le profil
  Future<bool> updateProfile(User updatedUser) async {
    try {
      final success = await _storage.updateInList(
        'users.json',
        'users',
        updatedUser.id,
        updatedUser.copyWith(updatedAt: DateTime.now()),
        (u) => u.id,
        (u) => u.toJson(),
        User.fromJson,
      );

      if (success) {
        _currentUser = updatedUser;
      }

      return success;
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      return false;
    }
  }

  // Changer le mot de passe
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;

    try {
      if (_currentUser!.passwordHash != _hashPassword(oldPassword)) {
        throw Exception('Ancien mot de passe incorrect');
      }

      final updatedUser = _currentUser!.copyWith(
        passwordHash: _hashPassword(newPassword),
        updatedAt: DateTime.now(),
      );

      return await updateProfile(updatedUser);
    } catch (e) {
      print('Erreur lors du changement de mot de passe: $e');
      return false;
    }
  }

  // Récupérer un utilisateur par ID
  Future<User?> getUserById(String userId) async {
    try {
      final users = await _storage.readList<User>(
        'users.json',
        'users',
        User.fromJson,
      );

      return users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Récupérer tous les utilisateurs (pour admin)
  Future<List<User>> getAllUsers() async {
    return await _storage.readList<User>(
      'users.json',
      'users',
      User.fromJson,
    );
  }

  // Récupérer les professionnels
  Future<List<User>> getProfessionals() async {
    final users = await getAllUsers();
    return users.where((u) => u.role == UserRole.professional).toList();
  }

  // Récupérer les patients
  Future<List<User>> getPatients() async {
    final users = await getAllUsers();
    return users.where((u) => u.role == UserRole.patient).toList();
  }
}
