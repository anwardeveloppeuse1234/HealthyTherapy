# Guide d'installation - Healthy Therapy for MS

Ce guide vous accompagne pas à pas pour installer et exécuter l'application **Healthy Therapy for MS** sur votre machine de développement.

## Prérequis système

### Système d'exploitation
- **Windows** : Windows 10 ou supérieur (64-bit)
- **macOS** : macOS 10.14 (Mojave) ou supérieur
- **Linux** : Ubuntu 18.04 ou supérieur, Debian, Fedora, Arch Linux

### Configuration matérielle recommandée
- **Processeur** : Intel Core i5 ou équivalent
- **RAM** : 8 GB minimum (16 GB recommandé)
- **Espace disque** : 10 GB d'espace libre
- **Connexion Internet** : Pour télécharger les dépendances

## Installation de Flutter

### Windows

1. **Télécharger Flutter SDK**
   - Visitez [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
   - Téléchargez le fichier ZIP du SDK Flutter
   - Extrayez le fichier dans `C:\src\flutter`

2. **Ajouter Flutter au PATH**
   - Ouvrez les variables d'environnement système
   - Ajoutez `C:\src\flutter\bin` au PATH
   - Redémarrez votre terminal

3. **Vérifier l'installation**
   ```bash
   flutter doctor
   ```

### macOS

1. **Télécharger Flutter SDK**
   ```bash
   cd ~/development
   curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.0-stable.zip
   unzip flutter_macos_3.16.0-stable.zip
   ```

2. **Ajouter Flutter au PATH**
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Vérifier l'installation**
   ```bash
   flutter doctor
   ```

### Linux

1. **Télécharger Flutter SDK**
   ```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
   tar xf flutter_linux_3.16.0-stable.tar.xz
   ```

2. **Ajouter Flutter au PATH**
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Vérifier l'installation**
   ```bash
   flutter doctor
   ```

## Installation des outils de développement

### Android Studio (pour Android)

1. **Télécharger Android Studio**
   - Visitez [developer.android.com/studio](https://developer.android.com/studio)
   - Téléchargez et installez Android Studio

2. **Installer les composants Android**
   - Ouvrez Android Studio
   - Allez dans **Tools > SDK Manager**
   - Installez :
     - Android SDK Platform (API 33 ou supérieur)
     - Android SDK Build-Tools
     - Android SDK Platform-Tools
     - Android Emulator

3. **Installer les plugins Flutter**
   - Allez dans **File > Settings > Plugins**
   - Recherchez "Flutter" et installez le plugin
   - Redémarrez Android Studio

4. **Accepter les licences Android**
   ```bash
   flutter doctor --android-licenses
   ```

### Xcode (pour iOS - macOS uniquement)

1. **Installer Xcode**
   ```bash
   xcode-select --install
   ```
   
   Ou téléchargez depuis l'App Store

2. **Configurer Xcode**
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. **Installer CocoaPods**
   ```bash
   sudo gem install cocoapods
   ```

### Visual Studio Code (optionnel mais recommandé)

1. **Télécharger VS Code**
   - Visitez [code.visualstudio.com](https://code.visualstudio.com)
   - Téléchargez et installez VS Code

2. **Installer les extensions**
   - Flutter
   - Dart
   - Flutter Widget Snippets

## Installation du projet

### 1. Obtenir le code source

Si vous avez reçu un fichier ZIP :
```bash
unzip healthy_therapy_ms.zip
cd healthy_therapy_ms
```

Si vous utilisez Git :
```bash
git clone <repository_url>
cd healthy_therapy_ms
```

### 2. Installer les dépendances

```bash
flutter pub get
```

Cette commande télécharge toutes les dépendances listées dans `pubspec.yaml`.

### 3. Vérifier la configuration

```bash
flutter doctor -v
```

Assurez-vous qu'aucune erreur critique n'est affichée.

## Configuration des émulateurs

### Émulateur Android

1. **Créer un AVD (Android Virtual Device)**
   ```bash
   flutter emulators
   ```

2. **Ou via Android Studio**
   - Ouvrez Android Studio
   - Allez dans **Tools > AVD Manager**
   - Cliquez sur **Create Virtual Device**
   - Sélectionnez un appareil (ex: Pixel 5)
   - Téléchargez une image système (API 33 recommandé)
   - Finalisez la création

3. **Lancer l'émulateur**
   ```bash
   flutter emulators --launch <emulator_id>
   ```

### Simulateur iOS (macOS uniquement)

1. **Lister les simulateurs disponibles**
   ```bash
   xcrun simctl list devices
   ```

2. **Lancer un simulateur**
   ```bash
   open -a Simulator
   ```

## Exécution de l'application

### Méthode 1 : Ligne de commande

1. **Lister les appareils disponibles**
   ```bash
   flutter devices
   ```

2. **Lancer l'application**
   ```bash
   flutter run
   ```

   Ou sur un appareil spécifique :
   ```bash
   flutter run -d <device_id>
   ```

### Méthode 2 : VS Code

1. Ouvrez le projet dans VS Code
2. Appuyez sur `F5` ou cliquez sur **Run > Start Debugging**
3. Sélectionnez l'appareil cible

### Méthode 3 : Android Studio

1. Ouvrez le projet dans Android Studio
2. Sélectionnez un appareil dans la barre d'outils
3. Cliquez sur le bouton **Run** (▶️)

## Modes d'exécution

### Mode Debug (par défaut)
```bash
flutter run
```
- Hot reload activé
- Outils de débogage disponibles
- Performance non optimisée

### Mode Release
```bash
flutter run --release
```
- Performance optimale
- Pas de hot reload
- Taille d'application réduite

### Mode Profile
```bash
flutter run --profile
```
- Performance proche du mode release
- Outils de profilage disponibles

## Génération des builds

### Android APK

```bash
flutter build apk --release
```

Le fichier APK sera généré dans :
`build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (pour Google Play)

```bash
flutter build appbundle --release
```

Le fichier AAB sera généré dans :
`build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS uniquement)

```bash
flutter build ios --release
```

Puis ouvrez le projet dans Xcode pour archiver et distribuer.

## Résolution des problèmes courants

### Problème : "Flutter command not found"

**Solution** : Ajoutez Flutter au PATH système
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Problème : "Android licenses not accepted"

**Solution** : Acceptez les licences
```bash
flutter doctor --android-licenses
```

### Problème : "Unable to locate Android SDK"

**Solution** : Définissez la variable ANDROID_HOME
```bash
export ANDROID_HOME=/path/to/android/sdk
```

### Problème : "CocoaPods not installed" (macOS)

**Solution** : Installez CocoaPods
```bash
sudo gem install cocoapods
pod setup
```

### Problème : Erreurs de dépendances

**Solution** : Nettoyez et réinstallez
```bash
flutter clean
flutter pub get
```

### Problème : L'application ne démarre pas

**Solution** : Vérifiez les logs
```bash
flutter run -v
```

## Tests

### Exécuter les tests unitaires

```bash
flutter test
```

### Exécuter les tests d'intégration

```bash
flutter drive --target=test_driver/app.dart
```

## Débogage

### Hot Reload
Pendant l'exécution en mode debug, appuyez sur `r` dans le terminal pour recharger l'application.

### Hot Restart
Appuyez sur `R` pour redémarrer complètement l'application.

### DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

## Configuration des données initiales

Au premier lancement, l'application créera automatiquement les fichiers JSON nécessaires dans le répertoire de l'application. Aucune configuration manuelle n'est requise.

Les fichiers seront créés dans :
- **Android** : `/data/data/com.example.healthy_therapy_ms/app_flutter/`
- **iOS** : `~/Library/Containers/<bundle_id>/Data/Documents/`

## Prochaines étapes

Une fois l'installation terminée :

1. Lancez l'application
2. Créez un compte (Patient ou Professionnel)
3. Explorez les fonctionnalités
4. Consultez le fichier `USER_GUIDE.md` pour plus de détails

## Support

En cas de problème :
- Consultez la documentation Flutter officielle : [flutter.dev/docs](https://flutter.dev/docs)
- Vérifiez les issues GitHub du projet
- Contactez l'équipe de développement

---

**Dernière mise à jour** : Décembre 2025
