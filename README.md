# 📅 Smart Planner

Une application Flutter de gestion de tâches avec calendrier intégré, rappels personnalisables et interface bilingue français/anglais.

## ✨ Fonctionnalités

### 🎯 Gestion des Tâches

- **CRUD complet** : Créer, lire, mettre à jour, supprimer des tâches
- **Priorités** : 3 niveaux (Urgent, Modéré, Faible) avec codes couleur
- **Stockage local** : Persistance des données avec Hive (base de données NoSQL)
- **Interface moderne** : Design Material 3 avec thème clair/sombre automatique

### 📅 Calendrier Intégré

- **Vue mensuelle** : Navigation fluide entre les mois
- **Affichage des tâches** : Les tâches s'affichent directement sur leur date d'échéance
- **Indicateurs visuels** : Jours avec tâches mis en évidence
- **Navigation intuitive** : Passage entre vue liste et vue calendrier

### 🔔 Notifications Intelligentes

- **Notification immédiate** : Alerte lors de la création d'une nouvelle tâche
- **Rappels configurables** : Plusieurs rappels actifs avant la deadline (à l'échéance, 15 min, 30 min, 1h, 2h ou 1 jour)
- **Rappels personnalisés** : Ajout de délais en minutes, heures ou jours depuis les paramètres
- **Alerte deadline** : Notification exacte à l'heure d'échéance ou notification de retard
- **Support multi-plateforme** : Android et iOS avec permissions natives
- **Gestion des fuseaux** : Support des fuseaux horaires automatiques

### ⚙️ Paramètres

- **Langue** : Français, anglais ou langue du système
- **Thème** : Clair, sombre ou réglage du système
- **Rappels** : Activation, désactivation et suppression des délais personnalisés
- **Persistance** : Les préférences sont conservées localement

### 🎨 Design & UX

- **Material 3** : Interface moderne suivant les dernières guidelines Google
- **Thème adaptatif** : Detection automatique du thème système (clair/sombre)
- **Animations fluides** : Transitions et micro-interactions soignées
- **Responsive design** : Adaptation à toutes les tailles d'écran

### 🛠️ Architecture Technique

- **Clean Architecture** : Séparation claire des responsabilités
- **State Management** : Gestion d'état locale avec StatefulWidget
- **Services découplés** : NotificationService, TaskService, SettingsService et services Google isolés
- **Widgets réutilisables** : Composants UI modulaires

## 🚀 Démarrage Rapide

### Prérequis

- Flutter SDK 3.10.8+ et Dart 3.10.8+
- Android 8.0+ / iOS 12.0+

### Installation

```bash
git clone https://github.com/rayaneSMR/Smart_Planner.git
cd Smart_Planner
flutter pub get
flutter run
```

## 📱 Captures d'Écran

### Vue Liste des Tâches

- Interface épurée avec cartes de tâches
- Indicateurs de priorité par couleur
- Bouton flottant d'ajout moderne

### Vue Calendrier

- Calendrier mensuel avec navigation
- Intégration visuelle des échéances
- Design Material 3 cohérent

### Modal de Création

- Bottom sheet moderne à 85% de hauteur
- Sélection visuelle des priorités
- Interface de sélection de dates intuitive

### Paramètres

- Choix de la langue et du thème
- Configuration de plusieurs rappels
- Ajout de rappels personnalisés

## 🔧 Technologies Utilisées

### Core

- **Flutter 3.10.8** : Framework de développement cross-platform
- **Dart** : Langage de programmation principal

### Stockage & Persistance

- **Hive 2.2.3** : Base de données NoSQL légère et rapide
- **Hive Flutter 1.1.0** : Intégration Flutter pour Hive

### Interface Utilisateur

- **Material 3** : Système de design Google moderne
- **Table Calendar 3.0.9** : Calendrier personnalisable et puissant
- **Shared Preferences 2.3.0** : Persistance des préférences utilisateur

### Notifications

- **Flutter Local Notifications 20.0.0** : Notifications natives multi-plateforme
- **Timezone 0.10.1** : Gestion des fuseaux horaires
- **Flutter Native Timezone 1.0.0** : Detection automatique de la timezone locale

### Intégrations

- **Google Sign-In** et **Google APIs** : Base technique pour l'intégration Google Calendar

### Développement

- **VS Code** : Éditeur de code recommandé pour Flutter
- **Git** : Contrôle de version et gestion du code source

## 📋 Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/
│   └── task.dart              # Modèle de données des tâches
├── services/
│   ├── google_calendar_service.dart # Préparation Google Calendar
│   ├── google_signin_service.dart   # Authentification Google
│   ├── notification_service.dart    # Gestion des notifications
│   ├── settings_service.dart        # Préférences utilisateur
│   └── task_service.dart            # Opérations CRUD sur les tâches
├── screens/
│   ├── home_screen.dart        # Écran principal avec navigation
│   └── settings_screen.dart    # Écran des paramètres
└── widgets/
    ├── task_card.dart           # Carte individuelle de tâche
    └── calendar_widget.dart     # Composant calendrier personnalisé
```

## 🎯 Fonctionnalités Clés

### Cycle de Vie d'une Tâche

1. **Création** → Notification immédiate + rappels activés dans les paramètres
2. **Modification** → Mise à jour des rappels automatiquement
3. **Suppression** → Annulation de toutes les notifications programmées

### Système de Notifications

- **3 canaux distincts** : Tâches, Deadlines, Deadline atteinte
- **Gestion des permissions** : Demande automatique Android 13+
- **Programmation robuste** : Reprogrammation des rappels au démarrage de l'app
- **Contenu bilingue** : Titres et messages adaptés à la langue choisie

## 🔄 Évolutions Futures

### Version 1.1 (En cours)

- [ ]  Finaliser la synchronisation Google Calendar
- [ ]  Synchronisation cloud multi-appareils
- [ ]  Partage de listes de tâches
- [ ]  Widgets personnalisables
- [ ]  Export/Import des données
- [ ]  Mode sombre amélioré

## 📝 Notes de Développement

### Architecture Respectée

- **SOLID Principles** : Chaque service a une responsabilité unique
- **Clean Code** : Séparation claire entre UI et logique métier
- **Performance** : Utilisation de builders et const pour optimiser le rendu

### Bonnes Pratiques

- **Gestion d'erreurs** : Try-catch robuste dans les services
- **Accessibilité** : Support des contrastes élevés et tailles de police
- **Internationalisation** : Structure prête pour la traduction (français intégré)

## 🤝 Contribution

### Comment Contribuer

1. **Forker** le projet
2. **Créer une branche** : `git checkout -b feature/nouvelle-fonctionnalite`
3. **Développer** en respectant le style de code existant
4. **Tester** : `flutter test` et tests manuels sur émulateurs
5. **Commiter** : Messages clairs et descriptifs
6. **Pull Request** : Explication détaillée des changements

### Convention de Code

- **Dart Style** : Respect des conventions de nommage et formatage
- **Flutter Widgets** : Utilisation de const et builders pour la performance
- **Comments** : Code documenté pour la maintenance

## 📄 Licence

Ce projet est sous licence **MIT** - libre d'utilisation, modification et distribution.

---

**Développé avec ❤️ par Rayane**  
**Architecturé pour évoluer** • **Conçu pour durer**

*Pour toute question ou suggestion : [rayaneSMR](https://github.com/rayaneSMR)*
