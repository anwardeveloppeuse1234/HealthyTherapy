# Démarrage Rapide - Healthy Therapy for MS

## 🚀 Installation en 3 étapes

### 1. Extraire le projet
```bash
unzip healthy_therapy_ms_complete.zip
cd healthy_therapy_ms
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Lancer l'application
```bash
flutter run
```

## ✅ Vérification de l'installation

Si vous rencontrez des problèmes, exécutez :
```bash
flutter doctor
```

Assurez-vous que Flutter est correctement installé et configuré.

## 📱 Première utilisation

1. **Lancez l'application** sur un émulateur ou appareil physique
2. **Cliquez sur "S'inscrire"** sur l'écran de connexion
3. **Créez un compte** :
   - Choisissez "Patient" ou "Professionnel"
   - Remplissez vos informations
   - Validez l'inscription
4. **Explorez l'application** !

## 🎯 Fonctionnalités principales

### Pour les Patients
- ✅ Suivre vos symptômes quotidiens
- ✅ Accéder aux exercices thérapeutiques
- ✅ Gérer vos rendez-vous médicaux
- ✅ Communiquer avec votre professionnel de santé
- ✅ Consulter vos rapports de progrès

### Pour les Professionnels
- ✅ Créer des exercices personnalisés
- ✅ Suivre l'évolution de vos patients
- ✅ Gérer votre planning de consultations
- ✅ Communiquer avec vos patients

## 📚 Documentation complète

- **README.md** - Vue d'ensemble du projet
- **INSTALLATION.md** - Guide d'installation détaillé
- **USER_GUIDE.md** - Manuel utilisateur complet
- **PROJECT_SUMMARY.md** - Résumé technique du projet

## 🆘 Besoin d'aide ?

### Problèmes courants

**"Flutter command not found"**
```bash
# Ajoutez Flutter au PATH
export PATH="$PATH:/path/to/flutter/bin"
```

**"Android licenses not accepted"**
```bash
flutter doctor --android-licenses
```

**Erreurs de dépendances**
```bash
flutter clean
flutter pub get
```

## 🔧 Configuration des émulateurs

### Android
```bash
# Lister les émulateurs disponibles
flutter emulators

# Lancer un émulateur
flutter emulators --launch <emulator_id>
```

### iOS (macOS uniquement)
```bash
# Ouvrir le simulateur
open -a Simulator
```

## 📦 Structure du projet

```
healthy_therapy_ms/
├── lib/                    # Code source Dart
│   ├── main.dart          # Point d'entrée
│   ├── models/            # Modèles de données
│   ├── services/          # Services métier
│   ├── providers/         # Gestion d'état
│   ├── screens/           # Écrans UI
│   └── utils/             # Utilitaires
├── assets/                # Ressources (images, icons)
├── android/               # Configuration Android
├── ios/                   # Configuration iOS
└── pubspec.yaml           # Dépendances
```

## 🎨 Personnalisation

### Changer les couleurs
Modifiez `lib/utils/constants.dart` :
```dart
static const Color primaryColor = Color(0xFF2196F3);
static const Color secondaryColor = Color(0xFF03DAC6);
```

### Changer le nom de l'application
Modifiez `lib/utils/constants.dart` :
```dart
static const String appName = 'Votre Nom';
```

## 🔐 Comptes de test

Créez vos propres comptes via l'écran d'inscription.

**Exemple de compte Patient :**
- Email : patient@example.com
- Mot de passe : password123

**Exemple de compte Professionnel :**
- Email : pro@example.com
- Mot de passe : password123

## 📊 Fonctionnalités techniques

- ✅ **Stockage local JSON** - Pas de base de données externe
- ✅ **Chat temps réel** - Polling toutes les 2 secondes
- ✅ **Calendrier interactif** - table_calendar
- ✅ **Rapports automatiques** - Génération hebdomadaire/mensuelle
- ✅ **Authentification sécurisée** - Hashage SHA-256
- ✅ **Interface Material Design 3** - Design moderne

## 🚧 Limitations

- Stockage local uniquement (pas de synchronisation cloud)
- Interface en français uniquement
- Notifications non activées

## 🔮 Évolutions futures

- Backend Firebase/Supabase
- Synchronisation multi-appareils
- Notifications push
- Mode sombre
- Support multilingue
- Export PDF des rapports

## 📞 Support

Pour toute question :
- Consultez la documentation complète
- Vérifiez les commentaires dans le code
- Contactez l'équipe de développement

---

**Bon développement ! 🎉**

Version 1.0.0 | Décembre 2025
