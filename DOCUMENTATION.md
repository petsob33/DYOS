# DYOS App - Code Documentation

## Overview

DYOS is a Flutter application built for couples to manage their shared life together. The app features authentication, user pairing, memory tracking, data visualization, and list management.

## Architecture

### Tech Stack
- **Framework**: Flutter (Dart SDK ^3.10.4)
- **State Management**: Riverpod (with code generation)
- **Routing**: GoRouter
- **Backend**: Firebase (Auth, Firestore, Storage)
- **UI**: Material Design 3 with custom theme
- **Icons**: Phosphor Icons
- **Fonts**: Google Fonts (Inter)

### Architecture Pattern
The app follows a clean architecture pattern with clear separation of concerns:

```
UI Layer (Features/Presentation)
    ↓
Business Logic (Services)
    ↓
Repository Layer
    ↓
Data Source Layer
    ↓
Firebase (Firestore/Auth)
```

## Project Structure

```
lib/
├── main.dart                 # App entry point, Firebase initialization
├── src/
│   ├── app.dart             # Root widget with MaterialApp.router
│   ├── core/                # Core functionality shared across app
│   │   ├── constants/       # App-wide constants (spacing, etc.)
│   │   ├── data/            # Data layer
│   │   │   ├── datasources/ # Direct Firebase operations
│   │   │   ├── models/      # Data models (UserModel, etc.)
│   │   │   ├── repositories/ # Repository pattern implementation
│   │   │   └── services/    # Business logic services
│   │   ├── providers/       # Riverpod providers
│   │   ├── theme/           # App theme and colors
│   │   └── widgets/         # Reusable widgets
│   ├── features/            # Feature modules
│   │   ├── auth/            # Authentication feature
│   │   ├── home/            # Home screen
│   │   ├── memory/          # Memory/timeline feature
│   │   ├── data/            # Data visualization
│   │   ├── lists/           # List management
│   │   └── pairing/         # User pairing feature
│   └── routing/             # App routing configuration
```

## Core Components

### Authentication System

#### AuthService (`lib/src/core/data/services/auth_service.dart`)
Handles all authentication operations:
- **signInWithEmailAndPassword**: Authenticates existing users
- **registerWithEmailAndPassword**: Creates new accounts and Firestore documents
- **signOut**: Ends user session
- **authStateChanges**: Stream of authentication state changes
- **currentUser**: Synchronous access to current user

Error handling converts Firebase exceptions to user-friendly messages.

#### Auth Providers (`lib/src/core/providers/auth_providers.dart`)
Riverpod providers for reactive authentication:
- **authStateProvider**: Stream of User? (null when signed out)
- **currentUserProvider**: Synchronous current user access

### Data Models

#### UserModel (`lib/src/core/data/models/user_model.dart`)
Represents a user in the system:
- `uid`: Firebase Auth UID (used as Firestore document ID)
- `email`: User's email address
- `displayName`: User's full name
- `photoUrl`: Profile picture URL
- `inviteCode`: Unique code for pairing (format: "NAME-1234")
- `coupleId`: ID of the couple this user belongs to
- `dateOfBirth`: Optional birth date
- `status`: User status (emoji + text)
- `createdAt`: Account creation timestamp

Uses Freezed for immutability and JSON serialization.

### Repository Pattern

#### UserRepository (`lib/src/core/data/repositories/user_repository.dart`)
Abstraction layer for user data operations:
- **getCurrentUserData**: Get current user's complete data
- **getUserById**: Fetch user by UID
- **getUserByInviteCode**: Find user by invite code
- **createUser**: Create new user document
- **updateUser**: Update existing user
- **createOrUpdateUser**: Upsert operation
- **updateUserFields**: Partial update
- **deleteUser**: Remove user document
- **streamUser**: Real-time user data stream
- **isUserPaired**: Check if user has a couple

### Routing

#### App Router (`lib/src/routing/app_router.dart`)
Uses GoRouter for navigation:
- **Public Routes**: `/login`, `/register`, `/firebase-test`, `/pairing`
- **Protected Routes**: `/home`, `/memory`, `/data`, `/lists` (require authentication)
- **Navigation Shell**: Bottom navigation bar with 4 tabs + center add button
- **Auth Redirect**: Automatically redirects based on authentication state

Routes are protected by watching `authStateProvider` and redirecting unauthenticated users to login.

## Features

### Authentication Screens

#### Login Screen (`lib/src/features/auth/presentation/login_screen.dart`)
- Email and password input fields
- Form validation
- Password visibility toggle
- Error message display
- Loading state during authentication
- Link to registration screen
- **Keyboard Fix**: Explicit focus handling with FocusNode to ensure keyboard appears on emulator

#### Register Screen (`lib/src/features/auth/presentation/register_screen.dart`)
- Name, email, password, and confirm password fields
- Form validation (email format, password strength, password match)
- Password visibility toggles for both password fields
- Error message display
- Loading state during registration
- Link back to login screen
- **Keyboard Fix**: Explicit focus handling with FocusNode to ensure keyboard appears on emulator

### Main Screens

#### Home Screen (`lib/src/features/home/presentation/home_screen.dart`)
Main dashboard with:
- Welcome section
- Status header
- Bento-style card grid layout
- Quick actions

#### Memory Screen (`lib/src/features/memory/presentation/memory_screen.dart`)
Timeline view for shared memories:
- Filter chips
- Timeline feed
- Map view button (TODO)

#### Data Screen (`lib/src/features/data/presentation/data_screen.dart`)
Data visualization and analytics for the couple.

#### Lists Screen (`lib/src/features/lists/presentation/lists_screen.dart`)
List management:
- Groceries list
- Bucket list
- Private gift list
- Real-time sync (planned)

#### Pairing Screen (`lib/src/features/pairing/presentation/pairing_screen.dart`)
Allows users to pair with their partner using invite codes.

## Theme System

### AppTheme (`lib/src/core/theme/app_theme.dart`)
Centralized theme configuration:
- **Colors**: Background, card, primary, text, textSecondary, love, success, warning, shadow
- **Typography**: Google Fonts Inter
- **Material 3**: Uses Material Design 3 components
- **Custom Components**: Card theme, AppBar theme, FAB theme

Color palette:
- Background: `#F2F2F7` (light gray)
- Card: `#FFFFFF` (white)
- Primary: `#5E5CE6` (purple)
- Text: `#1C1C1E` (dark gray)
- Text Secondary: `#8E8E93` (medium gray)
- Love: `#FF375F` (red/pink)
- Success: `#34C759` (green)
- Warning: `#FF9F0A` (orange)

## Firebase Integration

### Services

#### FirebaseService (`lib/src/core/data/services/firebase_service.dart`)
High-level Firebase operations:
- User data management
- Invite code generation
- User pairing
- Couple management

### Collections Structure

**users** collection:
- Document ID: Firebase Auth UID
- Fields: uid, email, displayName, photoUrl, inviteCode, coupleId, dateOfBirth, status, createdAt

**couples** collection:
- Document ID: Generated couple ID
- Fields: id, members (array of UIDs), anniversaryDate, createdAt

## State Management

### Riverpod
The app uses Riverpod for state management with code generation:
- Providers are defined using `@riverpod` annotation
- Generated files (`.g.dart`) are created by `build_runner`
- Providers are type-safe and support dependency injection

### Key Providers
- `authServiceProvider`: Singleton AuthService instance
- `authStateProvider`: Stream of authentication state
- `currentUserProvider`: Current user (synchronous)
- `userRepositoryProvider`: UserRepository instance
- `appRouterProvider`: GoRouter instance

## Code Generation

The project uses several code generation tools:
- **Riverpod Generator**: Generates provider code
- **Freezed**: Generates immutable models with copyWith, equality, etc.
- **JSON Serializable**: Generates JSON serialization code

To regenerate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Keyboard Input Fix

### Issue
Keyboard was not appearing when tapping text fields in Android emulator.

### Solution
Added explicit focus handling to all text input fields:
1. Created `FocusNode` instances for each text field
2. Added `onTap` callbacks that explicitly request focus
3. Added `onFieldSubmitted` callbacks to move focus between fields
4. Properly dispose of focus nodes in `dispose()` method

This ensures the keyboard appears reliably when users tap on input fields.

## Android Configuration

### AndroidManifest.xml
- `windowSoftInputMode="adjustResize"`: Adjusts layout when keyboard appears
- Hardware acceleration enabled
- Proper keyboard configuration flags

## Development Setup

### Prerequisites
- Flutter SDK ^3.10.4
- Firebase project configured
- Android Studio / VS Code
- Android SDK for Android development

### Initial Setup
1. Install dependencies: `flutter pub get`
2. Generate code: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Configure Firebase:
   - Add `google-services.json` to `android/app/`
   - Configure Firebase in Firebase Console
4. Run app: `flutter run`

### Running on Emulator
1. Start Android emulator
2. Ensure hardware keyboard is enabled in emulator settings
3. Run: `flutter run`

## Testing

### Widget Tests
Basic widget test structure in `test/widget_test.dart`.

### Firebase Testing
Firebase test screen available at `/firebase-test` route for testing Firebase connectivity.

## Known Issues / TODOs

- Memory screen map view navigation (TODO)
- Lists feature real-time sync (planned)
- Additional data visualization features (planned)

## Dependencies

### Main Dependencies
- `flutter_riverpod`: State management
- `go_router`: Navigation
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`: Firebase services
- `google_fonts`: Typography
- `phosphor_flutter`: Icons
- `freezed_annotation`, `json_annotation`: Code generation
- `flutter_staggered_grid_view`: Grid layouts
- `table_calendar`: Calendar widget

### Dev Dependencies
- `build_runner`: Code generation
- `freezed`: Immutable models
- `json_serializable`: JSON serialization
- `riverpod_generator`: Riverpod code generation
- `flutter_lints`: Linting rules

## File Naming Conventions

- **Screens**: `*_screen.dart`
- **Services**: `*_service.dart`
- **Repositories**: `*_repository.dart`
- **Models**: `*_model.dart`
- **Providers**: `*_providers.dart`
- **Widgets**: `*_widget.dart` or descriptive names

## Code Style

- Uses Dart analyzer with `flutter_lints` package
- Follows Flutter/Dart style guide
- Extensive documentation comments for public APIs
- Clear separation of concerns

## Build Commands

```bash
# Get dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Clean build
flutter clean
```

## Support

For issues or questions, refer to:
- Flutter documentation: https://docs.flutter.dev
- Firebase documentation: https://firebase.google.com/docs
- Riverpod documentation: https://riverpod.dev
