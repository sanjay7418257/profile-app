# Profile Discovery Mobile Application

A Flutter mobile application built for profile discovery, authentication, profile management, favorites, local storage, API integration, and dark mode support.

## Features

- User registration
- User login
- Forgot password
- Session management using Firebase Auth
- Create and edit user profile
- Upload profile picture
- View profile details
- Browse profiles
- Search profiles
- Filter profiles by age
- Save or remove favorite profiles
- Offline cached profile data
- Dark mode toggle
- Logout functionality

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Riverpod for state management
- GetIt for dependency injection
- GoRouter for navigation
- Dio for API requests
- Hive for local profile, cache, and favorite storage
- SharedPreferences for theme preference
- Cloudinary for profile image upload
- RandomUser API for profile discovery data
- Material Design 3

## Project Setup

1. Clone the repository.

```bash
git clone <repository-url>
cd profileapp
```

2. Install dependencies.

```bash
flutter pub get
```

3. Run the application.

```bash
flutter run
```

4. Build APK.

```bash
flutter build apk --release
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Architecture Overview

This project follows Clean Architecture.

```text
Presentation Layer
  - Screens
  - Widgets
  - Riverpod Providers / Notifiers

Domain Layer
  - Entities
  - Use Cases
  - Repository Interfaces

Data Layer
  - Repository Implementations
  - Local Data Source
  - Remote Data Source
  - Models

External Services
  - Firebase Auth
  - RandomUser API
  - Cloudinary
  - Hive
  - SharedPreferences
```

## Application Flow

```text
main.dart
  -> Initialize Firebase
  -> Initialize Hive
  -> Open local storage boxes
  -> Setup dependency injection
  -> Start ProviderScope
  -> Load MaterialApp.router

Splash Screen
  -> Check Firebase session
  -> If user is logged in, open Home
  -> If user is not logged in, open Login

Authentication
  -> Login/Register/Forgot Password screen
  -> AuthProvider
  -> Auth Use Cases
  -> AuthRepository
  -> Firebase Auth

Profile Management
  -> Profile screen
  -> ProfileProvider
  -> Profile Use Cases
  -> ProfileRepository
  -> Hive local storage
  -> Cloudinary image upload

Profile Discovery
  -> Home screen
  -> DiscoveryProvider
  -> Discovery Use Cases
  -> DiscoveryRepository
  -> RandomUser API
  -> Hive cache and favorites

Settings
  -> ThemeProvider
  -> SharedPreferences
  -> Firebase logout
```

## Architecture Diagram

```text
Flutter UI Screens
       |
       v
Riverpod Providers / Notifiers
       |
       v
Use Cases
       |
       v
Repository Interfaces
       |
       v
Repository Implementations
       |
       v
Local Data Sources + Remote Data Sources
       |
       v
Hive / SharedPreferences / Firebase Auth / RandomUser API / Cloudinary
```

## API Integration

The app uses the RandomUser API to fetch discovery profiles.

```text
https://randomuser.me/api/
```

Implemented API handling:

- API request using Dio
- Response parsing into model classes
- Loading states
- Error handling
- Cached fallback data using Hive

## Local Storage

Hive is used for:

- User profile data
- Favorite profile IDs
- Cached discovery profiles

SharedPreferences is used for:

- Dark mode preference

Firebase Auth is used for:

- User session management

## Assumptions and Decisions

- Firebase Authentication is used for secure login, registration, forgot password, and session management.
- RandomUser API is used as the public API source for profile discovery.
- Hive is used because it is fast and simple for local Flutter storage.
- Clean Architecture is followed to keep UI, business logic, and data logic separate.
- Riverpod is used for predictable state management.
- GetIt is used for dependency injection.
- Cloudinary is used for profile image upload.

## Folder Structure

```text
lib/
  core/
    constants/
    di/
    errors/
    network/
    utils/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    providers/
    screens/
    widgets/
```

## Author

Sanjay S
