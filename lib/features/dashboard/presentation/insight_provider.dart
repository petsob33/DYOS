import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../cycle/domain/cycle_calculator.dart';
import '../../cycle/presentation/cycle_provider.dart';
import '../../events/presentation/event_provider.dart';
import '../../tracker/presentation/intimacy_provider.dart';
import '../../timeline/presentation/memory_provider.dart';
import '../domain/insight_item.dart';

/// Aggregates memories, intimacy, cycle, next event, and couple into a list of insight items for the horizontal strip.
final insightItemsProvider = Provider<AsyncValue<List<InsightItem>>>((ref) {
  final memoriesAsync = ref.watch(memoriesStreamProvider);
  final intimacyAsync = ref.watch(intimacyLogsStreamProvider);
  final cycleSettingsAsync = ref.watch(cycleSettingsStreamProvider);
  final nextEventAsync = ref.watch(nextEventProvider);
  final coupleAsync = ref.watch(coupleProvider);

  return memoriesAsync.when(
    data: (memories) {
      return intimacyAsync.when(
        data: (intimacyLogs) {
          return cycleSettingsAsync.when(
            data: (cycleSettings) {
              return nextEventAsync.when(
                data: (nextEvent) {
                  final now = DateTime.now();
                  final thisMonthStart = DateTime(now.year, now.month, 1);
                  final memoriesThisMonth = memories
                      .where((m) => m.date.isAfter(thisMonthStart) || _sameDay(m.date, thisMonthStart))
                      .length;
                  final intimacyThisMonth = intimacyLogs
                      .where((l) => l.date.isAfter(thisMonthStart) || _sameDay(l.date, thisMonthStart))
                      .length;

                  final items = <InsightItem>[
                    InsightItem(
                      title: '$memoriesThisMonth',
                      subtitle: 'memories\nthis month',
                      icon: PhosphorIconsBold.images,
                    ),
                    InsightItem(
                      title: '$intimacyThisMonth',
                      subtitle: 'moments\nthis month',
                      icon: PhosphorIconsBold.heart,
                    ),
                  ];

                  if (cycleSettings != null && cycleSettings.lastPeriodDate != null) {
                    final nextPeriod = CycleCalculator.calculatePredictedPeriod(settings: cycleSettings);
                    if (nextPeriod != null) {
                      final today = DateTime(now.year, now.month, now.day);
                      final nextPeriodDay = DateTime(nextPeriod.year, nextPeriod.month, nextPeriod.day);
                      final daysUntil = nextPeriodDay.difference(today).inDays;
                      if (daysUntil >= 0) {
                        items.add(InsightItem(
                          title: daysUntil == 0 ? 'Today' : '$daysUntil',
                          subtitle: daysUntil == 0 ? 'period day' : 'days until\nperiod',
                          icon: PhosphorIconsBold.calendar,
                        ));
                      }
                    }
                  }

                  if (nextEvent != null) {
                    final eventDate = DateTime(nextEvent.date.year, nextEvent.date.month, nextEvent.date.day);
                    final today = DateTime(now.year, now.month, now.day);
                    final daysUntil = eventDate.difference(today).inDays;
                    if (daysUntil >= 0) {
                      items.add(InsightItem(
                        title: nextEvent.title,
                        subtitle: daysUntil == 0 ? 'today' : 'in $daysUntil days',
                        icon: PhosphorIconsBold.calendarStar,
                      ));
                    }
                  }

                  return coupleAsync.when(
                    data: (couple) {
                      if (couple?.anniversaryDate != null) {
                        final ann = couple!.anniversaryDate!;
                        final annDay = DateTime(ann.year, ann.month, ann.day);
                        final today = DateTime(now.year, now.month, now.day);
                        final daysTogether = today.difference(annDay).inDays;
                        if (daysTogether >= 0) {
                          items.add(InsightItem(
                            title: '$daysTogether',
                            subtitle: 'days\ntogether',
                            icon: PhosphorIconsBold.heartStraight,
                          ));
                        }
                      }
                      return AsyncValue.data(items);
                    },
                    loading: () => AsyncValue.data(items),
                    error: (_, __) => AsyncValue.data(items),
                  );
                },
                loading: () => const AsyncValue.loading(),
                error: (e, st) => const AsyncValue.loading(),
              );
            },
            loading: () => const AsyncValue.loading(),
            error: (_, __) => const AsyncValue.loading(),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (_, __) => const AsyncValue.loading(),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
