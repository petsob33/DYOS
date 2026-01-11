# Memory Loading Flow

## Přehled
Tento dokument popisuje, jak se memories načítají z Firestore a zobrazují v UI.

## Flow načítání memories

### 1. UI Layer - TimelineScreen
**Soubor:** `lib/features/timeline/presentation/screens/timeline_screen.dart`

```dart
final memoriesAsync = ref.watch(memoriesStreamProvider);
```

- `TimelineScreen` sleduje `memoriesStreamProvider` pomocí `ref.watch()`
- Provider vrací `AsyncValue<List<Memory>>` s třemi stavy:
  - `loading`: Zobrazuje `_LoadingState()` widget
  - `data`: Zobrazuje seznam memories nebo `_EmptyState()` pokud je prázdný
  - `error`: Zobrazuje `_ErrorState()` widget

### 2. Provider Layer - memoriesStreamProvider
**Soubor:** `lib/features/timeline/presentation/memory_provider.dart`

```dart
@riverpod
Stream<List<Memory>> memoriesStream(MemoriesStreamRef ref)
```

**Logika:**
1. Vytvoří `StreamController<List<Memory>>` pro emisi dat
2. Sleduje změny v `userProvider` pomocí `ref.listen()`
3. Když se user změní:
   - Zruší předchozí subscription na memories
   - Pokud user nemá `coupleId`, emituje prázdný seznam
   - Pokud má `coupleId`, zavolá `repository.getMemories(coupleId)`
   - Přihlásí se k streamu memories a emituje data do controlleru
4. Při dispose zruší subscription a zavře controller

**Závislosti:**
- `userProvider` - poskytuje aktuálního uživatele s `coupleId`
- `memoryRepositoryProvider` - poskytuje instanci `MemoryRepository`

### 3. Repository Layer - MemoryRepository
**Soubor:** `lib/features/timeline/data/memory_repository.dart`

```dart
Stream<List<Memory>> getMemories(String coupleId)
```

**Logika:**
1. Ověří, že `coupleId` není prázdný
2. Vytvoří Firestore query: `couples/{coupleId}/memories`
3. Použije `.snapshots()` pro real-time stream
4. Mapuje každý snapshot:
   - Parsuje dokumenty na `Memory` objekty pomocí `_parseMemories()`
   - Seřadí memories podle data (nejnovější první)
5. Vrací `Stream<List<Memory>>` který se automaticky aktualizuje při změnách

**Firestore cesta:**
```
couples/{coupleId}/memories/{memoryId}
```

### 4. Parsing - _parseMemories
**Soubor:** `lib/features/timeline/data/memory_repository.dart`

```dart
List<Memory> _parseMemories(List<QueryDocumentSnapshot> docs)
```

**Logika:**
1. Projde všechny dokumenty
2. Pro každý dokument:
   - Zavolá `Memory.fromFirestore(doc)` pro parsování
   - Pokud parsování selže, vrátí `null` (dokument se přeskočí)
3. Filtruje `null` hodnoty a vrací seznam validních memories

### 5. Model Layer - Memory.fromFirestore
**Soubor:** `lib/features/timeline/domain/memory_model.dart`

```dart
factory Memory.fromFirestore(DocumentSnapshot doc)
```

**Logika:**
1. Získá data z dokumentu jako `Map<String, dynamic>`
2. Zavolá `Memory.fromJson(data)` pro deserializaci
3. Nastaví `id` z dokumentu pomocí `copyWith(id: doc.id)`

## Data Flow Diagram

```
TimelineScreen
    ↓ watch
memoriesStreamProvider
    ↓ listen
userProvider (coupleId)
    ↓ read
memoryRepositoryProvider
    ↓ getMemories(coupleId)
Firestore: couples/{coupleId}/memories
    ↓ snapshots()
Stream<QuerySnapshot>
    ↓ map
_parseMemories()
    ↓ Memory.fromFirestore()
Stream<List<Memory>>
    ↓ emit
StreamController
    ↓ emit
AsyncValue<List<Memory>>
    ↓ when
UI Widgets (MemoryCard, _EmptyState, _LoadingState, _ErrorState)
```

## Klíčové body

1. **Real-time updates**: Stream se automaticky aktualizuje při změnách v Firestore
2. **Reactive**: Provider reaguje na změny v `userProvider` a automaticky přepne na nový stream
3. **Error handling**: Chyby při parsování se ignorují (dokument se přeskočí)
4. **Empty states**: Pokud není user, není `coupleId`, nebo nejsou memories, vrací se prázdný seznam
5. **Sorting**: Memories se řadí podle data (nejnovější první) v repository vrstvě

## Související soubory

- **UI**: `lib/features/timeline/presentation/screens/timeline_screen.dart`
- **Provider**: `lib/features/timeline/presentation/memory_provider.dart`
- **Repository**: `lib/features/timeline/data/memory_repository.dart`
- **Model**: `lib/features/timeline/domain/memory_model.dart`
- **Auth Provider**: `lib/features/auth/presentation/auth_providers.dart` (userProvider)
