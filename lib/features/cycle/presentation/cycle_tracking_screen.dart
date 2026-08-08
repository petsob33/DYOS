import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/build_context_l10n_extension.dart';
import '../../../core/widgets/bento_card.dart';
import '../../../core/widgets/dyos_universal_calendar.dart';
import '../../../core/utils/time_format.dart';
import '../../events/presentation/event_provider.dart';
import '../../events/presentation/add_event_sheet.dart';
import '../../events/domain/event_model.dart';
import '../../tracker/presentation/intimacy_provider.dart';
import '../../tracker/domain/intimacy_log_model.dart';
import '../../tracker/presentation/widgets/add_intimacy_sheet.dart';
import '../../tracker/presentation/widgets/intimacy_log_detail_sheet.dart';
import '../../timeline/presentation/memory_provider.dart';
import '../../timeline/domain/memory_model.dart';
import '../../timeline/presentation/widgets/memory_detail_dialog.dart';
import 'package:go_router/go_router.dart';
import '../domain/cycle_calculator.dart';
import '../domain/cycle_log_model.dart';
import 'cycle_log_sheet.dart';
import 'cycle_provider.dart';
import 'cycle_settings_sheet.dart';
import 'package:table_calendar/table_calendar.dart';

/// Screen for tracking menstrual cycle
/// 
/// Features:
/// - Calendar view with custom markers for periods, fertile window, and ovulation
/// - Bottom sheet for adding/editing cycle logs
class CycleTrackingScreen extends ConsumerStatefulWidget {
  const CycleTrackingScreen({super.key});

  @override
  ConsumerState<CycleTrackingScreen> createState() =>
      _CycleTrackingScreenState();
}

class _CycleTrackingScreenState extends ConsumerState<CycleTrackingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _dayOptionsDate; // Date for which to show day options on page

  @override
  void initState() {
    super.initState();
    // Set default to today
    _dayOptionsDate = DateTime.now();
  }

  // Phase colors
  static const Color _menstruationColor = Color(0xFFFF375F); // Red
  static const Color _fertileColor = Color(0xFF34C759); // Green
  static const Color _lutealColor = Color(0xFFFF9F0A); // Orange
  static const Color _follicularColor = Color(0xFF5E5CE6); // Indigo/Brand

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(cycleLogsStreamProvider);
    final predictedPeriods = ref.watch(predictedPeriodDaysProvider);
    final fertileDays = ref.watch(fertileWindowDaysProvider);
    final ovulationDay = ref.watch(ovulationDayProvider);
    final settingsAsync = ref.watch(cycleSettingsStreamProvider);
    final eventsAsync = ref.watch(eventsStreamProvider);
    final intimacyLogsAsync = ref.watch(intimacyLogsStreamProvider);
    final memoriesAsync = ref.watch(memoriesStreamProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    context.l10n.cycleTrackingScreenTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.text,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: context.colors.textSecondary,
                    onPressed: () => _showSettingsSheet(context),
                    tooltip: context.l10n.cycleTrackingScreenSettingsTooltip,
                  ),
                ],
              ),
            ),

            // Calendar
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: logsAsync.when(
                    data: (logs) {
                      final settings = settingsAsync.valueOrNull;
                      debugPrint('CycleTrackingScreen: settings.hideMenstruation = ${settings?.hideMenstruation}');
                      final events = eventsAsync.valueOrNull ?? [];
                      final intimacyLogs = intimacyLogsAsync.valueOrNull ?? [];
                      final memories = memoriesAsync.valueOrNull ?? [];
                      
                      // Pokud je hideMenstruation zapnuto, nepoužíváme predictedPeriods a fertileDays
                      final shouldShowMenstruation = settings == null || !settings.hideMenstruation;
                      final effectivePredictedPeriods = shouldShowMenstruation ? predictedPeriods : <DateTime>[];
                      final effectiveFertileDays = shouldShowMenstruation ? fertileDays : <DateTime>[];
                      final effectiveOvulationDay = shouldShowMenstruation ? ovulationDay : null;
                      
                      // Create maps by date for faster lookup
                      final eventsByDate = <DateTime, List<Event>>{};
                      for (final event in events) {
                        final normalizedDate = DateTime(
                          event.date.year,
                          event.date.month,
                          event.date.day,
                        );
                        eventsByDate.putIfAbsent(normalizedDate, () => []).add(event);
                      }
                      
                      final intimacyByDate = <DateTime, List<IntimacyLog>>{};
                      for (final log in intimacyLogs) {
                        final normalizedDate = DateTime(
                          log.date.year,
                          log.date.month,
                          log.date.day,
                        );
                        intimacyByDate.putIfAbsent(normalizedDate, () => []).add(log);
                      }
                      
                      final memoriesByDate = <DateTime, List<Memory>>{};
                      for (final memory in memories) {
                        final normalizedDate = DateTime(
                          memory.date.year,
                          memory.date.month,
                          memory.date.day,
                        );
                        memoriesByDate.putIfAbsent(normalizedDate, () => []).add(memory);
                      }

                      // Same O(1)-lookup approach as the maps above, applied
                      // to what eventLoader (called once per rendered day
                      // cell, ~35-42 times per month) used to scan linearly
                      // via firstWhere/.any() on every call.
                      final logByDate = <DateTime, CycleLog>{};
                      for (final log in logs) {
                        final normalizedDate = DateTime(
                          log.date.year,
                          log.date.month,
                          log.date.day,
                        );
                        logByDate.putIfAbsent(normalizedDate, () => log);
                      }
                      final predictedPeriodDates = effectivePredictedPeriods
                          .map((d) => DateTime(d.year, d.month, d.day))
                          .toSet();
                      final fertileDates = effectiveFertileDays
                          .map((d) => DateTime(d.year, d.month, d.day))
                          .toSet();
                      final ovulationDateNormalized = effectiveOvulationDay != null
                          ? DateTime(
                              effectiveOvulationDay.year,
                              effectiveOvulationDay.month,
                              effectiveOvulationDay.day,
                            )
                          : null;

                      return Column(
                        children: [
                          OurOSUniversalCalendar(
                            key: ValueKey('calendar_${settings?.hideMenstruation ?? false}'),
                            focusedDay: _focusedDay,
                            selectedDay: _selectedDay,
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                                // Toggle day options - if same day clicked, hide it
                                if (_dayOptionsDate != null && 
                                    _dayOptionsDate!.year == selectedDay.year &&
                                    _dayOptionsDate!.month == selectedDay.month &&
                                    _dayOptionsDate!.day == selectedDay.day) {
                                  _dayOptionsDate = null;
                                } else {
                                  _dayOptionsDate = selectedDay;
                                }
                              });
                            },
                            calendarStyle: CalendarStyle(
                              defaultDecoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              weekendDecoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              outsideDecoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: context.colors.primary,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: context.colors.primary.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.colors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            eventLoader: (date) {
                        // Return markers for this date
                        final normalizedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                        );
                        
                        final markers = <String>[];
                        
                        // Check for recorded period (flow intensity is not spotting)
                        // Skip if hideMenstruation is enabled
                        bool hasPeriod = false;
                        final shouldShowMenstruation = settings == null || !settings.hideMenstruation;
                        if (shouldShowMenstruation) {
                          final log = logByDate[normalizedDate];
                          if (log != null && log.flowIntensity != FlowIntensity.spotting) {
                            markers.add('recorded_period');
                            hasPeriod = true;
                          }

                          // Check for predicted period
                          if (predictedPeriodDates.contains(normalizedDate)) {
                            markers.add('predicted_period');
                            hasPeriod = true;
                          }
                        }

                        // Pokud je menstruace, nezobrazujeme ovulaci a fertile window
                        if (!hasPeriod && shouldShowMenstruation) {
                          // Check for fertile window
                          if (fertileDates.contains(normalizedDate)) {
                            markers.add('fertile');
                          }

                          // Check for ovulation
                          if (ovulationDateNormalized != null &&
                              ovulationDateNormalized == normalizedDate) {
                            markers.add('ovulation');
                          }
                        }
                        
                        // Check for events
                        if (eventsByDate.containsKey(normalizedDate)) {
                          markers.add('event');
                        }
                        
                        // Check for intimacy logs
                        if (intimacyByDate.containsKey(normalizedDate)) {
                          markers.add('intimacy');
                        }
                        
                        // Check for memories
                        if (memoriesByDate.containsKey(normalizedDate)) {
                          markers.add('memory');
                        }
                        
                        return markers;
                      },
                      calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, date, _) {
                                Color? backgroundColor;
                                
                                if (settings != null && !settings.hideMenstruation) {
                                  final status = CycleCalculator.calculateStatus(
                                    settings: settings,
                                    targetDate: date,
                                  );
                                  
                                  // Výraznější barvy pro jednotlivé fáze
                                  // Skip menstruation color if hideMenstruation is enabled
                                  switch (status.phase) {
                                    case CyclePhase.menstruation:
                                      if (!settings.hideMenstruation) {
                                        backgroundColor = _menstruationColor.withValues(alpha: 0.25);
                                      }
                                      break;
                                    case CyclePhase.follicular:
                                      backgroundColor = _follicularColor.withValues(alpha: 0.2);
                                      break;
                                    case CyclePhase.ovulation:
                                      backgroundColor = _fertileColor.withValues(alpha: 0.3);
                                      break;
                                    case CyclePhase.luteal:
                                      backgroundColor = _lutealColor.withValues(alpha: 0.2);
                                      break;
                                  }
                                } else if (settings != null) {
                                  // If hideMenstruation is true, still show other phases
                                  final status = CycleCalculator.calculateStatus(
                                    settings: settings,
                                    targetDate: date,
                                  );
                                  
                                  switch (status.phase) {
                                    case CyclePhase.menstruation:
                                      // Skip menstruation color
                                      break;
                                    case CyclePhase.follicular:
                                      backgroundColor = _follicularColor.withValues(alpha: 0.2);
                                      break;
                                    case CyclePhase.ovulation:
                                      backgroundColor = _fertileColor.withValues(alpha: 0.3);
                                      break;
                                    case CyclePhase.luteal:
                                      backgroundColor = _lutealColor.withValues(alpha: 0.2);
                                      break;
                                  }
                                }
                                
                                return Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: backgroundColor ?? context.colors.card,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${date.day}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: context.colors.text,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              markerBuilder: (context, date, events) {
                                // Build list of markers to display (all markers below the date)
                                final markerWidgets = <Widget>[];
                                const markerSize = 6.0;
                                const markerSpacing = 8.0;
                                
                                // Check if we should show menstruation markers
                                final shouldShowMenstruation = settings == null || !settings.hideMenstruation;

                                // Filter out menstruation-related markers if hideMenstruation is enabled
                                // This is a safety check - even if eventLoader returns these markers, we won't display them
                                final filteredEvents = shouldShowMenstruation
                                    ? events
                                    : events.where((e) =>
                                        e != 'recorded_period' &&
                                        e != 'predicted_period' &&
                                        e != 'ovulation' &&
                                        e != 'fertile'
                                      ).toList();

                                // Cycle markers (priority: recorded_period > predicted_period > ovulation > fertile)
                                // Only process if shouldShowMenstruation is true (filteredEvents will already exclude them)
                                if (filteredEvents.contains('recorded_period')) {
                                  markerWidgets.add(
                                    Container(
                                      width: markerSize,
                                      height: markerSize,
                                      decoration: BoxDecoration(
                                        color: context.colors.love,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                } else if (filteredEvents.contains('predicted_period')) {
                                  markerWidgets.add(
                                    Container(
                                      width: markerSize,
                                      height: markerSize,
                                      decoration: BoxDecoration(
                                        color: context.colors.love.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: context.colors.love,
                                          width: 1,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (filteredEvents.contains('ovulation')) {
                                  markerWidgets.add(
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: context.colors.success,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (filteredEvents.contains('fertile')) {
                                  markerWidgets.add(
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: context.colors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }
                                
                                // Event marker (modrá tečka)
                                if (events.contains('event')) {
                                  markerWidgets.add(
                                    Container(
                                      width: markerSize,
                                      height: markerSize,
                                      decoration: BoxDecoration(
                                        color: context.colors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }
                                
                                // Intimacy marker (růžová tečka)
                                if (events.contains('intimacy')) {
                                  markerWidgets.add(
                                    Container(
                                      width: markerSize,
                                      height: markerSize,
                                      decoration: BoxDecoration(
                                        color: context.colors.love,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }
                                
                                // Memory marker (zelená tečka)
                                if (events.contains('memory')) {
                                  markerWidgets.add(
                                    Container(
                                      width: markerSize,
                                      height: markerSize,
                                      decoration: BoxDecoration(
                                        color: context.colors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }
                                
                                if (markerWidgets.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                
                                // If only one marker, center it; otherwise show them side by side (centered)
                                return Positioned(
                                  bottom: 2,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: markerWidgets.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final widget = entry.value;
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right: index < markerWidgets.length - 1 ? markerSpacing : 0,
                                          ),
                                          child: widget,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Day Options (shown on page instead of bottom sheet)
                        if (_dayOptionsDate != null)
                          _DayOptionsWidget(
                            selectedDate: _dayOptionsDate!,
                            logs: logs,
                            eventsByDate: eventsByDate,
                            intimacyByDate: intimacyByDate,
                            memoriesByDate: memoriesByDate,
                            onClose: () {
                              setState(() {
                                _dayOptionsDate = null;
                              });
                            },
                            onShowCycleLogSheet: (date) {
                              _showCycleLogSheet(context, date, logs);
                            },
                          ),
                        if (_dayOptionsDate == null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          // Legend
                          _CycleLegend(),
                        ],
                      ],
                    );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => const CycleSettingsSheet(),
    );
  }

  void _showCycleLogSheet(
    BuildContext context,
    DateTime selectedDate,
    List<CycleLog> logs,
  ) {
    final normalizedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    
    CycleLog? existingLog;
    try {
      existingLog = logs.firstWhere(
        (log) {
          final logDate = DateTime(
            log.date.year,
            log.date.month,
            log.date.day,
          );
          return logDate == normalizedDate;
        },
      );
    } catch (e) {
      // No log found
      existingLog = null;
    }
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => CycleLogSheet(
        date: normalizedDate,
        existingLog: existingLog,
      ),
    );
  }
}

/// Day Options Widget - displays day events and actions directly on the page
class _DayOptionsWidget extends ConsumerWidget {
  const _DayOptionsWidget({
    required this.selectedDate,
    required this.logs,
    required this.eventsByDate,
    required this.intimacyByDate,
    required this.memoriesByDate,
    required this.onClose,
    required this.onShowCycleLogSheet,
  });

  final DateTime selectedDate;
  final List<CycleLog> logs;
  final Map<DateTime, List<Event>> eventsByDate;
  final Map<DateTime, List<IntimacyLog>> intimacyByDate;
  final Map<DateTime, List<Memory>> memoriesByDate;
  final VoidCallback onClose;
  final void Function(DateTime) onShowCycleLogSheet;

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return context.l10n.cycleTrackingScreenToday;
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return context.l10n.cycleTrackingScreenYesterday;
    } else if (selectedDay == today.add(const Duration(days: 1))) {
      return context.l10n.cycleTrackingScreenTomorrow;
    } else {
      return DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final dayEvents = eventsByDate[normalizedDate] ?? [];
    final dayIntimacyLogs = intimacyByDate[normalizedDate] ?? [];
    final dayMemories = memoriesByDate[normalizedDate] ?? [];
    
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Text(
                  _formatDate(context, selectedDate),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.text,
                      ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Memories section
                if (dayMemories.isNotEmpty) ...[
                  Text(
                    context.l10n.cycleTrackingScreenMemoriesHeading,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.text,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...dayMemories.map((memory) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: BentoCard(
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          MemoryDetailDialog.show(
                            context,
                            memory: memory,
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Text(
                                memory.category.emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memory.caption,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: context.colors.text,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      memory.category.displayName,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: context.colors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                PhosphorIconsBold.caretRight,
                                color: context.colors.textSecondary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // Intimacy logs section
                if (dayIntimacyLogs.isNotEmpty) ...[
                  Text(
                    context.l10n.cycleTrackingScreenIntimacyHeading,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.text,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...dayIntimacyLogs.map((log) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: BentoCard(
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          IntimacyLogDetailSheet.show(
                            context,
                            log: log,
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIconsBold.heartStraight,
                                color: context.colors.love,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.cycleTrackingScreenIntimacyHeading,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: context.colors.text,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      context.l10n.cycleTrackingScreenRating(log.rating),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: context.colors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                PhosphorIconsBold.caretRight,
                                color: context.colors.textSecondary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // Events section
                if (dayEvents.isNotEmpty) ...[
                  Text(
                    context.l10n.cycleTrackingScreenEventsHeading,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.text,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...dayEvents.map((event) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: BentoCard(
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          AddEventSheet.show(
                            context,
                            eventToEdit: event,
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIconsBold.calendar,
                                color: context.colors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: context.colors.text,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formatTime24h(event.date),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: context.colors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                PhosphorIconsBold.caretRight,
                                color: context.colors.textSecondary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // Action buttons - pod sebou
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push('/add-memory');
                        },
                        icon: Icon(
                          PhosphorIconsBold.heart,
                          color: context.colors.success,
                          size: 18,
                        ),
                        label: Text(context.l10n.cycleTrackingScreenAddMemoryButton),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.success,
                          side: BorderSide(color: context.colors.success),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          AddIntimacySheet.show(context);
                        },
                        icon: Icon(
                          PhosphorIconsBold.heartStraight,
                          color: context.colors.love,
                          size: 18,
                        ),
                        label: Text(context.l10n.cycleTrackingScreenAddIntimacyButton),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.love,
                          side: BorderSide(color: context.colors.love),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          AddEventSheet.show(
                            context,
                            initialDate: selectedDate,
                          );
                        },
                        icon: Icon(
                          PhosphorIconsBold.calendarPlus,
                          color: context.colors.primary,
                          size: 18,
                        ),
                        label: Text(context.l10n.cycleTrackingScreenAddEventButton),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.primary,
                          side: BorderSide(color: context.colors.primary),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          onShowCycleLogSheet(selectedDate);
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(context.l10n.cycleTrackingScreenAddPeriodLogButton),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.warning,
                          side: BorderSide(color: context.colors.warning),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Legend widget showing cycle phase colors
class _CycleLegend extends StatelessWidget {
  const _CycleLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.cycleTrackingScreenLegendHeading,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _LegendItem(
                color: const Color(0xFFFF375F),
                label: context.l10n.cycleTrackingScreenMenstruationLabel,
              ),
              _LegendItem(
                color: const Color(0xFF5E5CE6),
                label: context.l10n.cycleTrackingScreenFollicularLabel,
              ),
              _LegendItem(
                color: const Color(0xFF34C759),
                label: context.l10n.cycleTrackingScreenOvulationFertileLabel,
              ),
              _LegendItem(
                color: const Color(0xFFFF9F0A),
                label: context.l10n.cycleTrackingScreenLutealPmsLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

