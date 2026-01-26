# OurOS - Architektura projektu

## Přehled

OurOS je Flutter aplikace pro páry postavená na Firebase a Riverpod. Projekt používá feature-based strukturu s jasným oddělením vrstev.

## Struktura projektu

```
lib/
├── main.dart                 # Vstupní bod (inicializace Firebase, RevenueCat)
├── app.dart                  # Hlavní Widget (MaterialApp, Theme, Router)
├── firebase_options.dart     # Generováno přes flutterfire configure
│
├── core/                     # Sdílené věci pro celou appku
│   ├── constants/            # app_spacing.dart (design system)
│   ├── theme/                # app_theme.dart (Inter font, Border Radius 24)
│   ├── router/               # app_router.dart (GoRouter konfigurace)
│   ├── services/             # Firebase služby (auth_service, firebase_service)
│   ├── utils/                # Date formatters, Validators (zatím prázdné)
│   └── widgets/              # Sdílené UI komponenty (bento_card)
│
└── features/                 # Hlavní sekce podle PD
    ├── auth/                 # Autentizace a párování
    │   ├── data/             # Repositories (user_repository, user_data_source)
    │   ├── domain/           # Models (UserModel, CoupleModel)
    │   └── presentation/     # Screens & Providers (login, register, pairing, auth_providers)
    │
    ├── dashboard/            # HOME: Staggered Grid, Status, Countdowns
    │   └── presentation/
    │       └── screens/      # DashboardScreen (home_screen.dart)
    │
    ├── timeline/             # TIMELINE: Feed, Memories
    │   ├── data/             # Repositories (memory_repository)
    │   ├── domain/           # Models (Memory)
    │   └── presentation/     # Screens & Providers
    │       ├── screens/      # TimelineScreen, AddMemoryScreen
    │       └── memory_provider.dart
    │
    ├── tracker/              # DATA: Intimacy Log, Cycle Sync, Analytics
    │   └── presentation/     # DataScreen (zatím základní)
    │
    ├── lists/                # LISTS: Groceries, Bucket List, Settings
    │   └── lists_screen.dart, settings_screen.dart
    │
    └── premium/              # RevenueCat Paywall, Subscription logic
        └── presentation/     # PaywallScreen (zatím prázdné)
```

## Klíčové komponenty

### Core

- **theme/app_theme.dart**: Design system s barvami, fontem Inter a border radius 24px
- **router/app_router.dart**: GoRouter konfigurace s auth redirect logikou
- **services/**: Firebase služby pro auth a Firestore operace
- **widgets/**: Sdílené UI komponenty (BentoCard)

### Features

Každá feature má jasnou strukturu:
- **data/**: Repository pattern pro data operace
- **domain/**: Freezed modely (immutable data classes)
- **presentation/**: Screens a Riverpod providers

### Auth Flow

1. User se přihlásí (`login_screen.dart`)
2. Po přihlášení se zkontroluje `coupleId` v UserModel
3. Pokud nemá `coupleId`, přesměruje se na `pairing_screen.dart`
4. Po spárování má přístup k hlavní aplikaci

### State Management

- **Riverpod**: Pro všechny state management
- **Streams**: Pro real-time data z Firestore
- **Providers**: V `presentation/` složkách každé feature

## Routing

Router (`core/router/app_router.dart`) má tři typy rout:
- **Public**: `/login`, `/register`, `/firebase-test` (bez auth)
- **Pairing**: `/pairing` (vyžaduje auth, ale ne pairing)
- **Protected**: Všechny ostatní (vyžadují auth i pairing)

## Firebase

- **Authentication**: Email/password přes Firebase Auth
- **Firestore**: User data, couples, memories
- **Storage**: Obrázky a videa pro memories

## Generované soubory

Po změnách v modelu nebo provideru spusť:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Generuje:
- `.freezed.dart` - immutable data classes
- `.g.dart` - JSON serialization, Riverpod providers

## Best Practices

1. **Feature-based struktura**: Každá feature má vlastní složku
2. **Clean Architecture**: data → domain → presentation
3. **Type Safety**: Freezed modely pro všechny data
4. **Error Handling**: Try-catch v repository vrstvách
5. **Constants**: Design system v `core/constants/`
w