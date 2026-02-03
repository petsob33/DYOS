import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../cycle/domain/cycle_calculator.dart';
import '../../cycle/presentation/cycle_provider.dart';
import '../../events/presentation/event_provider.dart';
import '../../tracker/presentation/intimacy_provider.dart';
import '../../timeline/presentation/memory_provider.dart';
import '../domain/insight_item.dart';

/// Aggregates memories, intimacy, cycle, events, and couple into insight items (incl. period tip, "a year ago", "a month ago", last sex/memory).
final insightItemsProvider = Provider<AsyncValue<List<InsightItem>>>((ref) {
  final memoriesAsync = ref.watch(memoriesStreamProvider);
  final intimacyAsync = ref.watch(intimacyLogsStreamProvider);
  final cycleSettingsAsync = ref.watch(cycleSettingsStreamProvider);
  final nextEventAsync = ref.watch(nextEventProvider);
  final eventsAsync = ref.watch(eventsStreamProvider);
  final coupleAsync = ref.watch(coupleProvider);

  return memoriesAsync.when(
    data: (memories) {
      return intimacyAsync.when(
        data: (intimacyLogs) {
          return cycleSettingsAsync.when(
            data: (cycleSettings) {
              return nextEventAsync.when(
                data: (nextEvent) {
                  return eventsAsync.when(
                    data: (events) {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final thisMonthStart = DateTime(now.year, now.month, 1);
                      final memoriesThisMonth = memories
                          .where((m) =>
                              m.date.isAfter(thisMonthStart) ||
                              _sameDay(m.date, thisMonthStart))
                          .length;
                      final intimacyThisMonth = intimacyLogs
                          .where((l) =>
                              l.date.isAfter(thisMonthStart) ||
                              _sameDay(l.date, thisMonthStart))
                          .length;

                      final items = <InsightItem>[];

                      // For your partner – period / cycle tip (moved from bottom banner)
                      if (cycleSettings != null &&
                          cycleSettings.lastPeriodDate != null) {
                        final status = CycleCalculator.calculateStatus(
                          settings: cycleSettings,
                          targetDate: now,
                        );
                        items.add(InsightItem(
                          title: 'For your partner',
                          subtitle: status.partnerMessage,
                          icon: PhosphorIconsBold.heart,
                        ));
                      }

                      // Memories & moments this month
                      items.add(InsightItem(
                        title: '$memoriesThisMonth',
                        subtitle: 'memories\nthis month',
                        icon: PhosphorIconsBold.images,
                      ));
                      items.add(InsightItem(
                        title: '$intimacyThisMonth',
                        subtitle: 'moments\nthis month',
                        icon: PhosphorIconsBold.heart,
                      ));

                      // Last intimacy
                      if (intimacyLogs.isNotEmpty) {
                        final sorted =
                            List.from(intimacyLogs)
                              ..sort((a, b) => b.date.compareTo(a.date));
                        final last = sorted.first;
                        final daysSince =
                            today.difference(DateTime(last.date.year, last.date.month, last.date.day)).inDays;
                        items.add(InsightItem(
                          title: daysSince == 0
                              ? 'Today'
                              : daysSince == 1
                                  ? '1 day ago'
                                  : '$daysSince days ago',
                          subtitle: 'last moment',
                          icon: PhosphorIconsBold.heart,
                        ));
                      }

                      // Last memory
                      if (memories.isNotEmpty) {
                        final sorted =
                            List.from(memories)
                              ..sort((a, b) => b.date.compareTo(a.date));
                        final last = sorted.first;
                        final daysSince =
                            today.difference(DateTime(last.date.year, last.date.month, last.date.day)).inDays;
                        final title = last.caption.isNotEmpty
                            ? (last.caption.length > 20
                                ? '${last.caption.substring(0, 20)}…'
                                : last.caption)
                            : (daysSince == 0
                                ? 'Today'
                                : daysSince == 1
                                    ? '1 day ago'
                                    : '$daysSince days ago');
                        items.add(InsightItem(
                          title: title,
                          subtitle: daysSince <= 1
                              ? 'last memory'
                              : '$daysSince days ago',
                          icon: PhosphorIconsBold.images,
                        ));
                      }

                      // One month ago – memory or moment around 30 days ago
                      final monthAgo = today.subtract(const Duration(days: 30));
                      final memoryMonthAgo = _closestTo(memories, monthAgo, (m) => m.date);
                      final momentMonthAgo = _closestTo(intimacyLogs, monthAgo, (l) => l.date);
                      if (memoryMonthAgo != null) {
                        final d = (memoryMonthAgo.date.difference(monthAgo).inDays).abs();
                        if (d <= 7) {
                          final caption = memoryMonthAgo.caption.isNotEmpty
                              ? (memoryMonthAgo.caption.length > 18
                                  ? '${memoryMonthAgo.caption.substring(0, 18)}…'
                                  : memoryMonthAgo.caption)
                              : 'Memory';
                          items.add(InsightItem(
                            title: caption,
                            subtitle: 'about a month ago',
                            icon: PhosphorIconsBold.images,
                          ));
                        }
                      } else if (momentMonthAgo != null) {
                        final d = (momentMonthAgo.date.difference(monthAgo).inDays).abs();
                        if (d <= 7) {
                          items.add(InsightItem(
                            title: 'A moment',
                            subtitle: 'about a month ago',
                            icon: PhosphorIconsBold.heart,
                          ));
                        }
                      }

                      // On this day last year – memory or event
                      final lastYear = DateTime(now.year - 1, now.month, now.day);
                      final memoryYearAgo = memories.where((m) =>
                          m.date.year == lastYear.year &&
                          m.date.month == lastYear.month &&
                          m.date.day == lastYear.day).toList();
                      final eventYearAgo = events.where((e) =>
                          e.date.year == lastYear.year &&
                          e.date.month == lastYear.month &&
                          e.date.day == lastYear.day).toList();
                      if (memoryYearAgo.isNotEmpty) {
                        final m = memoryYearAgo.first;
                        final title = m.caption.isNotEmpty
                            ? (m.caption.length > 22
                                ? '${m.caption.substring(0, 22)}…'
                                : m.caption)
                            : 'Memory';
                        items.add(InsightItem(
                          title: title,
                          subtitle: 'a year ago today',
                          icon: PhosphorIconsBold.images,
                        ));
                      } else if (eventYearAgo.isNotEmpty) {
                        final e = eventYearAgo.first;
                        items.add(InsightItem(
                          title: e.title.length > 22
                              ? '${e.title.substring(0, 22)}…'
                              : e.title,
                          subtitle: 'a year ago today',
                          icon: PhosphorIconsBold.calendarStar,
                        ));
                      }

                      // Days until period
                      if (cycleSettings != null &&
                          cycleSettings.lastPeriodDate != null) {
                        final nextPeriod = CycleCalculator.calculatePredictedPeriod(
                            settings: cycleSettings);
                        if (nextPeriod != null) {
                          final nextPeriodDay = DateTime(
                              nextPeriod.year,
                              nextPeriod.month,
                              nextPeriod.day);
                          final daysUntil = nextPeriodDay.difference(today).inDays;
                          if (daysUntil >= 0) {
                            items.add(InsightItem(
                              title: daysUntil == 0 ? 'Today' : '$daysUntil',
                              subtitle: daysUntil == 0
                                  ? 'period today'
                                  : 'days to\nnext period',
                              icon: PhosphorIconsBold.calendar,
                            ));
                          }
                        }
                      }

                      // Next event
                      if (nextEvent != null) {
                        final eventDate = DateTime(
                            nextEvent.date.year,
                            nextEvent.date.month,
                            nextEvent.date.day);
                        final daysUntil = eventDate.difference(today).inDays;
                        if (daysUntil >= 0) {
                          items.add(InsightItem(
                            title: nextEvent.title.length > 20
                                ? '${nextEvent.title.substring(0, 20)}…'
                                : nextEvent.title,
                            subtitle: daysUntil == 0
                                ? 'today'
                                : 'in $daysUntil days',
                            icon: PhosphorIconsBold.calendarStar,
                          ));
                        }
                      }

                      // Days together
                      return coupleAsync.when(
                        data: (couple) {
                          if (couple?.anniversaryDate != null) {
                            final ann = couple!.anniversaryDate!;
                            final annDay =
                                DateTime(ann.year, ann.month, ann.day);
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

T? _closestTo<T>(List<T> list, DateTime target, DateTime Function(T) getDate) {
  if (list.isEmpty) return null;
  T? closest;
  int minDiff = 999999;
  for (final x in list) {
    final d = getDate(x);
    final diff = (DateTime(d.year, d.month, d.day).difference(target).inDays).abs();
    if (diff < minDiff) {
      minDiff = diff;
      closest = x;
    }
  }
  return closest;
}
