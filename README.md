# Healthy Therapy for MS

Application mobile Flutter complète pour le suivi de santé des patients atteints de sclérose en plaques.

## 📋 Description

**Healthy Therapy for MS** est une application mobile développée avec Flutter qui permet aux patients atteints de sclérose en plaques de suivre leurs symptômes, d'accéder à des exercices personnalisés, de communiquer avec des professionnels de santé et de gérer leurs rendez-vous médicaux.

L'application utilise un système de stockage local en JSON, permettant un fonctionnement 100% hors ligne sans nécessiter de base de données externe.

## ✨ Fonctionnalités principales

### Pour les Patients
- **Suivi des symptômes** : Enregistrement détaillé des symptômes avec sévérité, déclencheurs et durée
- **Exercices personnalisés** : Accès à une bibliothèque d'exercices adaptés avec vidéos et instructions
- **Calendrier de rendez-vous** : Gestion des rendez-vous médicaux avec calendrier interactif
- **Chat en temps réel** : Communication directe avec les professionnels de santé
- **Forum communautaire** : Partage d'expériences avec d'autres patients
- **Rapports de progrès** : Génération automatique de rapports hebdomadaires et mensuels

### Pour les Professionnels de Santé
- **Gestion des exercices** : Création et assignation d'exercices personnalisés
- **Suivi des patients** : Consultation des rapports et de l'évolution des patients
- **Communication** : Chat sécurisé avec les patients
- **Gestion des rendez-vous** : Planification et suivi des consultations

### Pour les Administrateurs
- **Gestion des utilisateurs** : Administration des comptes patients et professionnels
- **Modération du forum** : Supervision des publications
- **Statistiques globales** : Vue d'ensemble de l'utilisation de l'application

## 🏗️ Architecture

### Structure du projet

```
healthy_therapy_ms/
├── lib/
│   ├── main.dart                 # Point d'entrée de l'application
│   ├── models/                   # Modèles de données
│   │   ├── user.dart
│   │   ├── symptom.dart
│   │   ├── exercise.dart
│   │   ├── user_exercise.dart
│   │   ├── appointment.dart
│   │   ├── message.dart
│   │   ├── forum_post.dart
│   │   └── report.dart
│   ├── services/                 # Services métier
│   │   ├── storage_service.dart
│   │   ├── auth_service.dart
│   │   ├── symptom_service.dart
│   │   ├── exercise_service.dart
│   │   ├── appointment_service.dart
│   │   ├── message_service.dart
│   │   ├── forum_service.dart
│   │   └── report_service.dart
│   ├── providers/                # Gestion d'état
│   │   └── auth_provider.dart
│   ├── screens/                  # Écrans de l'application
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── symptoms/
│   │   ├── exercises/
│   │   ├── calendar/
│   │   ├── chat/
│   │   ├── forum/
│   │   ├── reports/
│   │   └── profile/
│   └── utils/                    # Utilitaires
│       ├── constants.dart
│       ├── theme.dart
│       └── validators.dart
├── assets/                       # Ressources
├── pubspec.yaml                  # Configuration et dépendances
└── README.md                     # Ce fichier
```

### Stockage des données

L'application utilise 8 fichiers JSON pour le stockage local :

1. **users.json** - Comptes utilisateurs
2. **symptoms.json** - Historique des symptômes
3. **exercises.json** - Bibliothèque d'exercices
4. **user_exercises.json** - Exercices assignés aux patients
5. **appointments.json** - Rendez-vous planifiés
6. **messages.json** - Conversations et messages
7. **forum.json** - Publications et commentaires du forum
8. **reports.json** - Rapports de progrès générés

## 🚀 Installation

### Prérequis

- Flutter SDK (version 3.0.0 ou supérieure)
- Dart SDK (version 3.0.0 ou supérieure)
- Android Studio / Xcode (pour émulation)
- Un éditeur de code (VS Code, Android Studio, etc.)

### Étapes d'installation

1. **Cloner ou extraire le projet**
   ```bash
   cd healthy_therapy_ms
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Vérifier l'installation Flutter**
   ```bash
   flutter doctor
   ```

4. **Lancer l'application**
   
   Sur un émulateur Android :
   ```bash
   flutter run
   ```
   
   Sur un émulateur iOS :
   ```bash
   flutter run -d ios
   ```
   
   Sur un appareil physique :
   ```bash
   flutter run -d <device_id>
   ```

## 📱 Utilisation

### Première connexion

L'application nécessite la création d'un compte. Lors de l'inscription, vous devez choisir votre rôle :

- **Patient** : Pour suivre vos symptômes et accéder aux exercices
- **Professionnel** : Pour gérer les patients et créer des exercices

### Comptes de test

Vous pouvez créer vos propres comptes via l'écran d'inscription.

## 🔒 Sécurité

- **Hashage des mots de passe** : Utilisation de SHA-256 pour le stockage sécurisé
- **Stockage sécurisé** : flutter_secure_storage pour les données sensibles
- **Validation des entrées** : Tous les formulaires sont validés
- **Session persistante** : Maintien de la connexion de manière sécurisée

## 📦 Dépendances principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1                    # Gestion d'état
  shared_preferences: ^2.2.2          # Stockage local
  path_provider: ^2.1.1               # Accès aux chemins système
  flutter_secure_storage: ^9.0.0     # Stockage sécurisé
  uuid: ^4.2.2                        # Génération d'identifiants uniques
  intl: ^0.19.0                       # Internationalisation et formats
  crypto: ^3.0.3                      # Cryptographie
  table_calendar: ^3.0.9              # Calendrier interactif
  fl_chart: ^0.65.0                   # Graphiques
  image_picker: ^1.0.7                # Sélection d'images
  video_player: ^2.8.2                # Lecture de vidéos
  cached_network_image: ^3.3.1       # Cache d'images réseau
  local_auth: ^2.1.8                  # Authentification biométrique
```

## 🎨 Design

- **Couleur primaire** : Bleu (#2196F3)
- **Couleur secondaire** : Cyan (#03DAC6)
- **Style** : Material Design 3
- **Thème** : Clair (extensible au thème sombre)

## 🔄 Fonctionnalités techniques

### Chat en temps réel
Le système de chat utilise un mécanisme de **polling** (vérification périodique toutes les 2 secondes) pour simuler le temps réel sans nécessiter de serveur WebSocket.

### Calendrier interactif
Intégration de `table_calendar` pour une gestion complète des rendez-vous avec :
- Vue mensuelle, hebdomadaire et quotidienne
- Marqueurs pour les rendez-vous
- Sélection de date intuitive

### Rapports automatiques
Génération automatique de rapports basés sur :
- Nombre de symptômes enregistrés
- Exercices complétés
- Sévérité moyenne des symptômes
- Symptôme le plus fréquent
- Pourcentage de progrès

## 🚧 Limitations actuelles

- **Stockage local uniquement** : Les données ne sont pas synchronisées entre appareils
- **Pas de backend** : Fonctionnement 100% local
- **Notifications** : Structure préparée mais non activée
- **Langue** : Interface en français uniquement

## 🔮 Évolutions futures

### Court terme
- Activation des notifications push
- Ajout d'exercices par défaut
- Export PDF des rapports

### Moyen terme
- Intégration d'un backend (Firebase/Supabase)
- Synchronisation cloud
- Support multilingue (FR/EN)
- Mode sombre complet

### Long terme
- Intelligence artificielle pour recommandations personnalisées
- Intégration avec wearables (Apple Health, Google Fit)
- Téléconsultation vidéo
- Application web companion

## 📄 Licence

Ce projet est développé dans un cadre éducatif et de démonstration.

## 👥 Support

Pour toute question ou problème :
- Consultez la documentation dans le dossier `/docs`
- Vérifiez les issues GitHub
- Contactez l'équipe de développement

## 🙏 Remerciements

Développé avec ❤️ pour améliorer la qualité de vie des patients atteints de sclérose en plaques.

---

**Version** : 1.0.0  
**Date** : Décembre 2025  
**Framework** : Flutter 3.x
