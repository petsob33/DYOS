import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firebase/firestore_parsing.dart';
import '../domain/event_model.dart';

part 'event_repository.g.dart';

/// Riverpod provider that creates a singleton EventRepository instance
@riverpod
EventRepository eventRepository(EventRepositoryRef ref) {
  return EventRepository();
}

/// Repository layer for event operations
/// 
/// This class provides a high-level API for event operations while hiding
/// the implementation details of Firestore.
class EventRepository {
  EventRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Add or update an event
  /// 
  /// Saves the event to Firestore at couples/{coupleId}/events/{eventId}
  /// 
  /// [event] - The Event object to add/update (id can be empty to auto-generate)
  /// [coupleId] - The ID of the couple this event belongs to
  /// 
  /// Returns: The created/updated Event object with populated id
  /// 
  /// Throws: Exception if save fails
  Future<Event> addOrUpdateEvent(Event event, String coupleId) async {
    try {
      if (coupleId.isEmpty) {
        throw Exception('coupleId cannot be empty');
      }

      // Generate event ID if not provided
      final eventId = event.id.isEmpty
          ? _firestore
              .collection('couples')
              .doc(coupleId)
              .collection('events')
              .doc()
              .id
          : event.id;

      // Prepare event with ID
      final eventWithId = event.copyWith(id: eventId);

      // Save to Firestore
      // Path: couples/{coupleId}/events/{eventId}
      final eventRef = _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('events')
          .doc(eventId);

      // Convert event to JSON and save
      final eventJson = eventWithId.toJson();
      await eventRef.set(eventJson);

      return eventWithId;
    } catch (e) {
      throw Exception('Failed to add/update event: ${e.toString()}');
    }
  }

  /// Watch events for a couple
  ///
  /// Returns a stream of events ordered by date ascending.
  /// The stream automatically updates when events are added, updated, or deleted.
  ///
  /// [coupleId] - The ID of the couple to get events for
  ///
  /// Returns: Stream of List of Event ordered by date ascending
  ///
  /// Deliberately not paginated like memories/intimacy logs: this single
  /// stream backs the events calendar (needs markers across every month the
  /// user navigates to, not just recent ones), nextEventProvider (needs to
  /// see future events) and eventsForDate (needs any past date the user
  /// picks) - truncating to "N most recent" would silently drop future
  /// events. Instead this bounds by a rolling date window
  /// ([yearsOfHistory] back, no upper bound so all future events are always
  /// included) plus a generous count [limit] as a belt-and-suspenders cap -
  /// unlike a plain count limit on an ascending query, this can't ever
  /// crowd out future events with old ones.
  Stream<List<Event>> watchEvents(
    String coupleId, {
    int yearsOfHistory = 3,
    int limit = 2000,
  }) {
    if (coupleId.isEmpty) {
      return Stream.value([]);
    }

    final now = DateTime.now();
    final cutoff = DateTime(now.year - yearsOfHistory, now.month, now.day);

    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .orderBy('date', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final events = _parseEvents(snapshot.docs);
      // Ensure sorted by date ascending
      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    });
  }

  /// Delete an event
  /// 
  /// Permanently removes the event from Firestore.
  /// 
  /// [eventId] - The ID of the event to delete
  /// [coupleId] - The ID of the couple this event belongs to
  /// 
  /// Throws: Exception if deletion fails
  Future<void> deleteEvent(String eventId, String coupleId) async {
    try {
      if (coupleId.isEmpty) {
        throw Exception('coupleId cannot be empty');
      }
      if (eventId.isEmpty) {
        throw Exception('eventId cannot be empty');
      }

      await _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('events')
          .doc(eventId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete event: ${e.toString()}');
    }
  }

  /// Helper method to parse event documents
  List<Event> _parseEvents(List<QueryDocumentSnapshot> docs) {
    return parseFirestoreDocs(docs, Event.fromFirestore);
  }
}
