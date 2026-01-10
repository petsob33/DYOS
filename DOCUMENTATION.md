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
- **isUserPairedProvider**: Checks if current user is paired with a partner
- **currentCoupleProvider**: Fetches couple data for current user
- **partnerProvider**: Fetches partner's user data
- **currentUserDataProvider**: Fetches current user's Firestore data

### Data Models

#### UserModel (`lib/src/core/data/models/user_model.dart`)
Represents a user in the system:
- `uid`: Firebase Auth UID (used as Firestore document ID)
- `email`: User's email address
- `displayName`: User's full name
- `photoUrl`: Profile picture URL
- `inviteCode`: Unique code for pairing (format: "NAME-1234")
  - Automatically generated during registration
  - Format: First 4 letters of name (uppercase) + random 4-digit number
  - Example: "PETR-8821", "ANNA-1234"
- `coupleId`: ID of the couple this user belongs to
- `dateOfBirth`: Optional birth date
- `status`: User status (emoji + text)
- `createdAt`: Account creation timestamp

Uses Freezed for immutability and JSON serialization.

#### CoupleModel (`lib/src/core/data/models/couple_model.dart`)
Represents a paired couple in the system:
- `id`: Unique couple identifier
- `members`: Array of user UIDs (exactly 2 members)
- `anniversaryDate`: Date when couple started (for counting days together)
- `createdAt`: When couple document was created
- `subscriptionTier`: "free" | "premium" | "trial" (defaults to "free")
- `subscriptionExpiry`: When premium subscription ends (null for free tier)
- `status`: Map of user UIDs to CoupleStatus objects
  - Stores emoji and text status for each user
  - Allows dashboard to display status without reading additional documents
  - Key: User UID, Value: CoupleStatus (emoji, text, updatedAt)

#### CoupleStatus (`lib/src/core/data/models/couple_model.dart`)
Status information for a user within a couple:
- `emoji`: Emoji representing current status
- `text`: Text description of status
- `updatedAt`: When status was last updated

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
- **Protected Routes**: `/home`, `/memory`, `/data`, `/lists` (require authentication AND pairing)
- **Navigation Shell**: Bottom navigation bar with 4 tabs + center add button
- **Auth Redirect**: Automatically redirects based on authentication state
- **Pairing Redirect**: 
  - Authenticated users without a couple → redirected to `/pairing`
  - Authenticated users with a couple → redirected to `/home`
  - Users on pairing screen who are already paired → redirected to `/home`

Routes are protected by watching `authStateProvider` and `isUserPairedProvider` to ensure proper navigation flow.

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
Main dashboard with real-time couple data:
- **Status Header**: Displays both users' names, emojis, and statuses from couple document
  - Shows current user on left, partner on right
  - Real-time data from Firestore via `currentCoupleProvider` and `partnerProvider`
  - Responsive layout that fits all names on screen
- **Days Together Card**: Calculates and displays days since anniversary date
  - Uses `anniversaryDate` from couple document
  - Shows "0" if anniversary date not set
- **Bento-style card grid layout**: Various information widgets
- **Quick actions**: Access to common features

The screen automatically loads and displays couple data when user is paired.

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
Complete pairing system for connecting two users:
- **User's Invite Code Display**: Shows current user's unique invite code
  - Automatically generated during registration (format: "NAME-1234")
  - Copy to clipboard functionality
  - Code is fetched from Firestore user document
- **Partner Code Input**: Text field to enter partner's invite code
  - Format validation (LETTERS-NUMBERS pattern)
  - Prevents pairing with yourself
  - Case-insensitive matching
- **Pairing Process**:
  1. Validates partner code format
  2. Finds partner user by invite code
  3. Verifies partner is not already paired
  4. Creates couple document in Firestore with:
     - Both user UIDs in members array
     - Initial status objects for both users
     - Default subscription tier "free"
     - Anniversary date set to current date
  5. Updates both users' documents with coupleId
  6. Redirects to home page on success
- **Error Handling**: User-friendly error messages for:
  - Invalid code format
  - User not found
  - User already paired
  - Network errors
- **Loading States**: Shows loading indicators during data fetch and pairing
- **Auto-redirect**: If user is already paired, automatically redirects to home

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
- **User Data Management**:
  - `getUserData()`: Get current user's Firestore document
  - `createOrUpdateUser()`: Create or update user with automatic invite code generation
  - `findUserByInviteCode()`: Search for user by their invite code
- **Invite Code Generation**:
  - Automatically generates unique codes during registration
  - Format: First 4 letters of display name (uppercase) + random 4-digit number
  - Ensures uniqueness through Firestore queries
- **User Pairing**:
  - `pairUsers()`: Creates couple document and updates both users
    - Safety checks: prevents self-pairing, verifies users exist, checks if already paired
    - Creates couple document with initial status objects
    - Uses Firestore batch writes for atomicity
  - `getCoupleData()`: Fetches couple document by ID
  - `getPartner()`: Finds and returns partner's user data
  - `isUserPaired()`: Checks if current user has a coupleId
- **Couple Management**:
  - Handles couple document creation with all required fields
  - Manages status updates within couple documents

### Collections Structure

**users** collection:
- Document ID: Firebase Auth UID
- Fields: uid, email, displayName, photoUrl, inviteCode, coupleId, dateOfBirth, status, createdAt

**couples** collection:
- Document ID: Generated couple ID (format: "couple_{timestamp}")
- Fields:
  - `id`: Couple identifier (same as document ID)
  - `members`: Array of exactly 2 user UIDs
  - `anniversaryDate`: Timestamp (for counting days together)
  - `createdAt`: Timestamp (when couple was created)
  - `subscriptionTier`: String ("free" | "premium" | "trial")
  - `subscriptionExpiry`: Timestamp (when premium expires, null for free)
  - `status`: Map<String, CoupleStatus>
    - Key: User UID
    - Value: Object with emoji, text, updatedAt
    - Allows quick access to user statuses without reading user documents

## State Management

### Riverpod
The app uses Riverpod for state management with code generation:
- Providers are defined using `@riverpod` annotation
- Generated files (`.g.dart`) are created by `build_runner`
- Providers are type-safe and support dependency injection

### Key Providers
- `authServiceProvider`: Singleton AuthService instance
- `authStateProvider`: Stream of authentication state
- `currentUserProvider`: Current user (synchronous, from Firebase Auth)
- `currentUserDataProvider`: Current user's Firestore data (UserModel)
- `isUserPairedProvider`: Checks if current user is paired (Future<bool?>)
- `currentCoupleProvider`: Current user's couple data (Future<CoupleModel?>)
- `partnerProvider`: Partner's user data (Future<UserModel?>)
- `userRepositoryProvider`: UserRepository instance
- `firebaseServiceProvider`: FirebaseService instance
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
   - Deploy Firestore security rules: `firebase deploy --only firestore:rules`
4. Run app: `flutter run`

### Firebase Configuration Files
- **`firebase.json`**: Firebase project configuration
  - Specifies Firestore rules and indexes file locations
  - Database location and settings
- **`firestore.rules`**: Security rules for Firestore
  - Defines access permissions for users and couples collections
  - Must be deployed to Firebase for production use
- **`firestore.indexes.json`**: Firestore index configuration
  - Field overrides for efficient querying
  - Composite indexes if needed
- **`.firebaserc`**: Firebase project alias configuration
  - Maps project aliases to Firebase project IDs

### Running on Emulator
1. Start Android emulator
2. Ensure hardware keyboard is enabled in emulator settings
3. Run: `flutter run`

## Testing

### Widget Tests
Basic widget test structure in `test/widget_test.dart`.

### Firebase Testing
Firebase test screen available at `/firebase-test` route for testing Firebase connectivity.

## Firestore Security Rules

### Rules File (`firestore.rules`)
The app includes comprehensive Firestore security rules:

**Users Collection**:
- Users can read/write their own document
- Users can read other users' documents (needed for pairing by invite code)
- Users can update other users' `coupleId` field (for pairing process)
- Users can create their own document during registration
- All operations require authentication

**Couples Collection**:
- Users can read couple documents where they are a member
- Users can create couple documents if they are in the members array
- Only allows exactly 2 members per couple
- Users can update couple documents where they are a member
- Couple documents cannot be deleted

**Default**: All other operations are denied

### Deployment
Rules are deployed via Firebase CLI:
```bash
firebase deploy --only firestore:rules
```

Or manually through Firebase Console → Firestore Database → Rules

### Indexes (`firestore.indexes.json`)
- Field overrides for `displayName` in users collection
- Allows efficient querying and sorting by user names

## Known Issues / TODOs

- Memory screen map view navigation (TODO)
- Lists feature real-time sync (planned)
- Additional data visualization features (planned)
- Status update functionality (planned)
- Anniversary date editing (planned)

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

# Build APK (release)
flutter build apk --release

# Build APK Bundle (for Google Play)
flutter build appbundle --release

# Build iOS
flutter build ios

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Clean build
flutter clean
```

## Pairing System

### Overview
The pairing system allows two users to connect their accounts and share data. This is the core feature that enables all couple-specific functionality.

### Flow
1. **User Registration**: 
   - User creates account with email/password
   - Invite code is automatically generated (e.g., "PETR-8821")
   - User document is created in Firestore

2. **Pairing Process**:
   - User A opens pairing screen and sees their invite code
   - User B enters User A's invite code
   - System validates code, finds User A, creates couple document
   - Both users are updated with coupleId
   - Both users redirected to home screen

3. **After Pairing**:
   - Home screen displays both users' names and statuses
   - Days together counter starts from anniversary date
   - All couple-specific features become available

### Safety Features
- Prevents self-pairing
- Verifies both users exist before pairing
- Prevents pairing if either user is already paired
- Uses Firestore batch writes for atomicity
- Comprehensive error handling with user-friendly messages

### Data Structure
When two users pair, a couple document is created with:
- Both user UIDs in members array
- Initial status objects for both users
- Anniversary date (defaults to pairing date)
- Subscription tier (defaults to "free")
- Created timestamp

Both user documents are updated with the coupleId, linking them to the couple document.

## Support

For issues or questions, refer to:
- Flutter documentation: https://docs.flutter.dev
- Firebase documentation: https://firebase.google.com/docs
- Riverpod documentation: https://riverpod.dev
