import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/event_repository.dart';
import '../domain/event_model.dart';

part 'event_provider.g.dart';

/// Provider that watches all events for the current couple
@riverpod
Stream<List<Event>> eventsStream(EventsStreamRef ref) {
  final userAsync = ref.watch(userProvider);
  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    debugPrint('EventsStreamProvider: No user or coupleId');
    return Stream.value([]);
  }

  debugPrint('EventsStreamProvider: Watching events for coupleId: ${user.coupleId}');
  final repository = ref.watch(eventRepositoryProvider);
  return repository.watchEvents(user.coupleId!).map((events) {
    debugPrint('EventsStreamProvider: Received ${events.length} events');
    return events;
  });
}

/// Provider that gets the next upcoming event
@riverpod
Stream<Event?> nextEvent(NextEventRef ref) {
  final userAsync = ref.watch(userProvider);
  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value(null);
  }

  final repository = ref.watch(eventRepositoryProvider);
  return repository.watchEvents(user.coupleId!).map((events) {
    final now = DateTime.now();
    final upcomingEvents = events.where((event) {
      final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
      final today = DateTime(now.year, now.month, now.day);
      return eventDate.isAfter(today) || eventDate.isAtSameMomentAs(today);
    }).toList();

    if (upcomingEvents.isEmpty) {
      return null;
    }

    // Return the first upcoming event (already sorted by date ascending)
    return upcomingEvents.first;
  });
}

/// Provider that gets events for a specific date
@riverpod
Stream<List<Event>> eventsForDate(EventsForDateRef ref, DateTime date) {
  final userAsync = ref.watch(userProvider);
  final user = userAsync.valueOrNull;

  if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(eventRepositoryProvider);
  return repository.watchEvents(user.coupleId!).map((events) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return events.where((event) {
      final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
      return eventDate.isAtSameMomentAs(normalizedDate);
    }).toList();
  });
}
