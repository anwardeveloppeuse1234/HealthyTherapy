import 'constants.dart';

class Validators {
  // Valider l'email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emptyFieldError;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return AppConstants.invalidEmailError;
    }

    return null;
  }

  // Valider le mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emptyFieldError;
    }

    if (value.length < AppConstants.minPasswordLength) {
      return AppConstants.shortPasswordError;
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Le mot de passe est trop long';
    }

    return null;
  }

  // Valider la confirmation du mot de passe
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppConstants.emptyFieldError;
    }

    if (value != password) {
      return AppConstants.passwordMismatchError;
    }

    return null;
  }

  // Valider le nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emptyFieldError;
    }

    if (value.length < AppConstants.minNameLength) {
      return 'Le nom doit contenir au moins ${AppConstants.minNameLength} caractères';
    }

    if (value.length > AppConstants.maxNameLength) {
      return 'Le nom est trop long';
    }

    return null;
  }

  // Valider le numéro de téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emptyFieldError;
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');

    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return AppConstants.invalidPhoneError;
    }

    return null;
  }

  // Valider un champ obligatoire
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null 
          ? '$fieldName est obligatoire' 
          : AppConstants.emptyFieldError;
    }
    return null;
  }

  // Valider la sévérité (1-10)
  static String? validateSeverity(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emptyFieldError;
    }

    final severity = int.tryParse(value);
    if (severity == null) {
      return 'Veuillez entrer un nombre';
    }

    if (severity < AppConstants.minSymptomSeverity || 
        severity > AppConstants.maxSymptomSeverity) {
      return 'La sévérité doit être entre ${AppConstants.minSymptomSeverity} et ${AppConstants.maxSymptomSeverity}';
    }

    return null;
  }

  // Valider la note (1-5)
  static String? validateRating(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emptyFieldError;
    }

    final rating = int.tryParse(value);
    if (rating == null) {
      return 'Veuillez entrer un nombre';
    }

    if (rating < AppConstants.minExerciseRating || 
        rating > AppConstants.maxExerciseRating) {
      return 'La note doit être entre ${AppConstants.minExerciseRating} et ${AppConstants.maxExerciseRating}';
    }

    return null;
  }

  // Valider la durée
  static String? validateDuration(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emptyFieldError;
    }

    final duration = int.tryParse(value);
    if (duration == null) {
      return 'Veuillez entrer un nombre';
    }

    if (duration <= 0) {
      return 'La durée doit être supérieure à 0';
    }

    return null;
  }

  // Valider l'URL
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? AppConstants.emptyFieldError : null;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'URL invalide';
    }

    return null;
  }

  // Valider le format de l'heure (HH:mm)
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emptyFieldError;
    }

    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');

    if (!timeRegex.hasMatch(value)) {
      return 'Format invalide (HH:mm)';
    }

    return null;
  }

  // Valider que l'heure de fin est après l'heure de début
  static String? validateEndTime(String? endTime, String? startTime) {
    if (endTime == null || endTime.isEmpty) {
      return AppConstants.emptyFieldError;
    }

    if (startTime == null || startTime.isEmpty) {
      return null;
    }

    final timeError = validateTime(endTime);
    if (timeError != null) return timeError;

    final endParts = endTime.split(':');
    final startParts = startTime.split(':');

    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

    if (endMinutes <= startMinutes) {
      return 'L\'heure de fin doit être après l\'heure de début';
    }

    return null;
  }

  // Valider une liste non vide
  static String? validateList(List<dynamic>? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null 
          ? 'Veuillez ajouter au moins un $fieldName' 
          : 'La liste ne peut pas être vide';
    }
    return null;
  }
}
