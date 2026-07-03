import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../events/presentation/event_provider.dart';

class EventsCard extends ConsumerWidget {
  const EventsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsStreamProvider);

    return eventsAsync.when(
      data: (events) {
        final upcomingEvents = events.where((event) {
          final today = DateTime.now();
          final eventDate = DateTime(
            event.date.year,
            event.date.month,
            event.date.day,
          );
          final todayDate = DateTime(today.year, today.month, today.day);
          return eventDate.isAfter(todayDate) ||
              eventDate.isAtSameMomentAs(todayDate);
        }).toList();

        final c = AppTheme.colors;

        return BentoCard(
          onTap: () {
            context.push('/events');
          },
          background: c.card,
          child: Center(
            child: Icon(PhosphorIconsBold.calendar, color: c.success, size: 52),
          ),
        );
      },
      loading: () {
        final c = AppTheme.colors;
        return BentoCard(
          onTap: () {
            context.push('/events');
          },
          background: c.card,
          child: Center(
            child: Icon(PhosphorIconsBold.calendar, color: c.success, size: 52),
          ),
        );
      },
      error: (error, stackTrace) {
        final c = AppTheme.colors;
        return BentoCard(
          onTap: () {
            context.push('/events');
          },
          background: c.card,
          child: Center(
            child: Icon(PhosphorIconsBold.calendar, color: c.success, size: 52),
          ),
        );
      },
    );
  }
}
