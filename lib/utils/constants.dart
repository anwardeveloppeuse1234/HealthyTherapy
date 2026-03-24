import 'package:flutter/material.dart';

class AppConstants {
  // Informations de l'application
  static const String appName = 'Healthy Therapy for MS';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Application de santé pour patients atteints de sclérose en plaques';

  // Couleurs
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  
  // Couleurs de sévérité
  static const Color severityLow = Color(0xFF4CAF50);
  static const Color severityMedium = Color(0xFFFF9800);
  static const Color severityHigh = Color(0xFFF44336);

  // Tailles
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;

  // Durées d'animation
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Messages
  static const String emptyFieldError = 'Ce champ est obligatoire';
  static const String invalidEmailError = 'Email invalide';
  static const String shortPasswordError = 'Le mot de passe doit contenir au moins 6 caractères';
  static const String passwordMismatchError = 'Les mots de passe ne correspondent pas';
  static const String invalidPhoneError = 'Numéro de téléphone invalide';

  // Noms de fichiers JSON
  static const String usersFile = 'users.json';
  static const String symptomsFile = 'symptoms.json';
  static const String exercisesFile = 'exercises.json';
  static const String userExercisesFile = 'user_exercises.json';
  static const String appointmentsFile = 'appointments.json';
  static const String messagesFile = 'messages.json';
  static const String forumFile = 'forum.json';
  static const String reportsFile = 'reports.json';

  // Intervalles de temps
  static const Duration chatPollingInterval = Duration(seconds: 2);
  static const Duration notificationCheckInterval = Duration(minutes: 5);

  // Limites
  static const int maxSymptomSeverity = 10;
  static const int minSymptomSeverity = 1;
  static const int maxExerciseRating = 5;
  static const int minExerciseRating = 1;
  
  // Formats de date
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // URLs par défaut pour les exercices de démonstration
  static const String defaultExerciseImage = 'https://via.placeholder.com/400x300?text=Exercice';
  static const String defaultExerciseVideo = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
  
  // Messages de succès
  static const String loginSuccess = 'Connexion réussie';
  static const String registerSuccess = 'Inscription réussie';
  static const String updateSuccess = 'Mise à jour réussie';
  static const String deleteSuccess = 'Suppression réussie';
  static const String saveSuccess = 'Sauvegarde réussie';

  // Messages d'erreur
  static const String genericError = 'Une erreur est survenue';
  static const String networkError = 'Erreur de connexion';
  static const String notFoundError = 'Élément non trouvé';
  
  // Rôles
  static const String rolePatient = 'Patient';
  static const String roleProfessional = 'Professionnel';
  static const String roleAdmin = 'Administrateur';
}
