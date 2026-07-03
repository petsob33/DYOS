import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ouros_app/features/events/data/event_repository.dart';
import 'package:ouros_app/features/events/domain/event_model.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late EventRepository repository;
  const coupleId = 'couple_1';

  Event buildEvent({String id = '', required DateTime date, String title = 'Event'}) {
    return Event(id: id, date: date, title: title);
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = EventRepository(firestore: firestore);
  });

  group('EventRepository.watchEvents', () {
    test('includes future events regardless of how far ahead', () async {
      final farFuture = DateTime.now().add(const Duration(days: 3650));
      await repository.addOrUpdateEvent(buildEvent(date: farFuture, title: 'Far future'), coupleId);

      final events = await repository.watchEvents(coupleId).first;

      expect(events.map((e) => e.title), contains('Far future'));
    });

    test('excludes events older than yearsOfHistory', () async {
      final ancient = DateTime.now().subtract(const Duration(days: 3650));
      await repository.addOrUpdateEvent(buildEvent(date: ancient, title: 'Ancient'), coupleId);

      final events = await repository.watchEvents(coupleId, yearsOfHistory: 3).first;

      expect(events.map((e) => e.title), isNot(contains('Ancient')));
    });

    test('includes events within yearsOfHistory', () async {
      final recent = DateTime.now().subtract(const Duration(days: 30));
      await repository.addOrUpdateEvent(buildEvent(date: recent, title: 'Recent'), coupleId);

      final events = await repository.watchEvents(coupleId, yearsOfHistory: 3).first;

      expect(events.map((e) => e.title), contains('Recent'));
    });

    test('orders events by date ascending', () async {
      final now = DateTime.now();
      await repository.addOrUpdateEvent(
        buildEvent(date: now.add(const Duration(days: 10)), title: 'Later'),
        coupleId,
      );
      await repository.addOrUpdateEvent(
        buildEvent(date: now.add(const Duration(days: 1)), title: 'Sooner'),
        coupleId,
      );

      final events = await repository.watchEvents(coupleId).first;

      expect(events.map((e) => e.title), ['Sooner', 'Later']);
    });

    test('returns an empty stream for an empty coupleId', () async {
      final events = await repository.watchEvents('').first;
      expect(events, isEmpty);
    });
  });

  group('EventRepository.deleteEvent', () {
    test('deletes an existing event', () async {
      final created = await repository.addOrUpdateEvent(
        buildEvent(date: DateTime.now(), title: 'To delete'),
        coupleId,
      );

      await repository.deleteEvent(created.id, coupleId);

      final events = await repository.watchEvents(coupleId).first;
      expect(events, isEmpty);
    });

    test('throws when eventId is empty', () async {
      expect(
        () => repository.deleteEvent('', coupleId),
        throwsA(isA<Exception>()),
      );
    });
  });
}
