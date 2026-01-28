import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bento_card.dart';
import '../../../shared/widgets/calendar/dyos_universal_calendar.dart';
import '../../auth/presentation/auth_providers.dart';
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
import '../data/cycle_repository.dart';
import '../domain/cycle_calculator.dart';
import '../domain/cycle_log_model.dart';
import '../models/cycle_log.dart' as cycle_models;
import '../models/cycle_provider.dart' as cycle_providers;
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

  // Phase colors
  static const Color _menstruationColor = Color(0xFFFF375F); // Red
  static const Color _fertileColor = Color(0xFF34C759); // Green
  static const Color _lutealColor = Color(0xFFFF9F0A); // Orange
  static const Color _follicularColor = Color(0xFF5E5CE6); // Indigo/Brand

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(cycle_providers.cycleLogsProvider);
    final predictedPeriods = ref.watch(cycle_providers.predictedPeriodDaysProvider);
    final fertileDays = ref.watch(cycle_providers.fertileWindowProvider);
    final ovulationDay = ref.watch(cycle_providers.ovulationDayProvider);
    final settingsAsync = ref.watch(cycleSettingsStreamProvider);
    final eventsAsync = ref.watch(eventsStreamProvider);
    final intimacyLogsAsync = ref.watch(intimacyLogsStreamProvider);
    final memoriesAsync = ref.watch(memoriesStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Calendar',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.colors.text,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: AppTheme.colors.textSecondary,
                    onPressed: () => _showSettingsSheet(context),
                    tooltip: 'Cycle Settings',
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
                              });
                              // Show events and cycle log options
                              _showDayOptionsSheet(context, selectedDay, logs, eventsByDate, intimacyByDate, memoriesByDate);
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
                                color: AppTheme.colors.primary,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: AppTheme.colors.primary.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.colors.primary,
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
                        debugPrint('CycleTrackingScreen: eventLoader for $normalizedDate, shouldShowMenstruation: $shouldShowMenstruation, hideMenstruation: ${settings?.hideMenstruation}');
                        if (shouldShowMenstruation) {
                          try {
                            final log = logs.firstWhere(
                              (log) {
                                final logDate = DateTime(
                                  log.date.year,
                                  log.date.month,
                                  log.date.day,
                                );
                                return logDate == normalizedDate;
                              },
                            );
                            
                            if (log.flowIntensity != FlowIntensity.spotting) {
                              markers.add('recorded_period');
                              hasPeriod = true;
                            }
                          } catch (e) {
                            // No log found for this date
                          }
                          
                          // Check for predicted period
                          final isPredictedPeriod = effectivePredictedPeriods.any(
                            (periodDate) {
                              final periodNormalized = DateTime(
                                periodDate.year,
                                periodDate.month,
                                periodDate.day,
                              );
                              return periodNormalized == normalizedDate;
                            },
                          );
                          
                          if (isPredictedPeriod) {
                            markers.add('predicted_period');
                            hasPeriod = true;
                          }
                        }
                        
                        // Pokud je menstruace, nezobrazujeme ovulaci a fertile window
                        if (!hasPeriod && shouldShowMenstruation) {
                          // Check for fertile window
                          final isFertile = effectiveFertileDays.any(
                            (fertileDate) {
                              final fertileNormalized = DateTime(
                                fertileDate.year,
                                fertileDate.month,
                                fertileDate.day,
                              );
                              return fertileNormalized == normalizedDate;
                            },
                          );
                          
                          if (isFertile) {
                            markers.add('fertile');
                          }
                          
                          // Check for ovulation
                          if (effectiveOvulationDay != null) {
                            final ovulationNormalized = DateTime(
                              effectiveOvulationDay.year,
                              effectiveOvulationDay.month,
                              effectiveOvulationDay.day,
                            );
                            if (ovulationNormalized == normalizedDate) {
                              markers.add('ovulation');
                            }
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
                                    color: backgroundColor ?? AppTheme.colors.card,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${date.day}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.colors.text,
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
                                final normalizedDate = DateTime(date.year, date.month, date.day);
                                debugPrint('CycleTrackingScreen: markerBuilder for $normalizedDate, events: $events, shouldShowMenstruation: $shouldShowMenstruation, hideMenstruation: ${settings?.hideMenstruation}');
                                
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
                                
                                debugPrint('CycleTrackingScreen: markerBuilder filteredEvents: $filteredEvents');
                                
                                // Cycle markers (priority: recorded_period > predicted_period > ovulation > fertile)
                                // Only process if shouldShowMenstruation is true (filteredEvents will already exclude them)
                                if (filteredEvents.contains('recorded_period')) {
                                  markerWidgets.add(
                                    Container(
                                      width: markerSize,
                                      height: markerSize,
                                      decoration: BoxDecoration(
                                        color: AppTheme.colors.love,
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
                                        color: AppTheme.colors.love.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.colors.love,
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
                                          color: AppTheme.colors.success,
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
                                        color: AppTheme.colors.success,
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
                                        color: AppTheme.colors.primary,
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
                                        color: AppTheme.colors.love,
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
                                        color: AppTheme.colors.success,
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
                        // Legend
                        _CycleLegend(),
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

  void _showDayOptionsSheet(
    BuildContext context,
    DateTime selectedDate,
    List<cycle_models.CycleLog> logs,
    Map<DateTime, List<Event>> eventsByDate,
    Map<DateTime, List<IntimacyLog>> intimacyByDate,
    Map<DateTime, List<Memory>> memoriesByDate,
  ) {
    final normalizedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final dayEvents = eventsByDate[normalizedDate] ?? [];
    final dayIntimacyLogs = intimacyByDate[normalizedDate] ?? [];
    final dayMemories = memoriesByDate[normalizedDate] ?? [];
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: AppTheme.colors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.colors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      _formatDate(selectedDate),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.text,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        PhosphorIconsBold.x,
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Memories section
                      if (dayMemories.isNotEmpty) ...[
                        Text(
                          'Memories',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.colors.text,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...dayMemories.map((memory) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: BentoCard(
                            padding: EdgeInsets.zero,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
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
                                                  color: AppTheme.colors.text,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            memory.category.displayName,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppTheme.colors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      PhosphorIconsBold.caretRight,
                                      color: AppTheme.colors.textSecondary,
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
                          'Intimacy',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.colors.text,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...dayIntimacyLogs.map((log) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: BentoCard(
                            padding: EdgeInsets.zero,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
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
                                      color: AppTheme.colors.love,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Intimacy',
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.colors.text,
                                                ),
                                          ),
                                          if (log.rating != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'Rating: ${log.rating}/5',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: AppTheme.colors.textSecondary,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      PhosphorIconsBold.caretRight,
                                      color: AppTheme.colors.textSecondary,
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
                          'Events',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.colors.text,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...dayEvents.map((event) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: BentoCard(
                            padding: EdgeInsets.zero,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
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
                                      color: AppTheme.colors.primary,
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
                                                  color: AppTheme.colors.text,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatTime(event.date),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppTheme.colors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      PhosphorIconsBold.caretRight,
                                      color: AppTheme.colors.textSecondary,
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
                                Navigator.of(context).pop();
                                context.push('/add-memory');
                              },
                              icon: Icon(
                                PhosphorIconsBold.heart,
                                color: AppTheme.colors.success,
                                size: 18,
                              ),
                              label: const Text('Add Memory'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.colors.success,
                                side: BorderSide(color: AppTheme.colors.success),
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
                                Navigator.of(context).pop();
                                AddIntimacySheet.show(context);
                              },
                              icon: Icon(
                                PhosphorIconsBold.heartStraight,
                                color: AppTheme.colors.love,
                                size: 18,
                              ),
                              label: const Text('Add Intimacy'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.colors.love,
                                side: BorderSide(color: AppTheme.colors.love),
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
                                Navigator.of(context).pop();
                                AddEventSheet.show(
                                  context,
                                  initialDate: selectedDate,
                                );
                              },
                              icon: Icon(
                                PhosphorIconsBold.calendarPlus,
                                color: AppTheme.colors.primary,
                                size: 18,
                              ),
                              label: const Text('Add Event'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.colors.primary,
                                side: BorderSide(color: AppTheme.colors.primary),
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
                                Navigator.of(context).pop();
                                _showCycleLogSheet(context, selectedDate, logs);
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Period Log'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.colors.warning,
                                side: BorderSide(color: AppTheme.colors.warning),
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Today';
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (selectedDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showCycleLogSheet(
    BuildContext context,
    DateTime selectedDate,
    List<cycle_models.CycleLog> logs,
  ) {
    final normalizedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    
    cycle_models.CycleLog? existingLog;
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
      builder: (context) => _CycleLogSheet(
        date: normalizedDate,
        existingLog: existingLog,
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
        color: AppTheme.colors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.colors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _LegendItem(
                color: const Color(0xFFFF375F),
                label: 'Menstruation',
              ),
              _LegendItem(
                color: const Color(0xFF5E5CE6),
                label: 'Follicular',
              ),
              _LegendItem(
                color: const Color(0xFF34C759),
                label: 'Ovulation/Fertile',
              ),
              _LegendItem(
                color: const Color(0xFFFF9F0A),
                label: 'Luteal/PMS',
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
            color: AppTheme.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet for adding/editing cycle log
class _CycleLogSheet extends ConsumerStatefulWidget {
  const _CycleLogSheet({
    required this.date,
    this.existingLog,
  });

  final DateTime date;
  final cycle_models.CycleLog? existingLog;

  @override
  ConsumerState<_CycleLogSheet> createState() => _CycleLogSheetState();
}

class _CycleLogSheetState extends ConsumerState<_CycleLogSheet> {
  late FlowIntensity _flowIntensity;
  late Mood _mood;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _flowIntensity = widget.existingLog?.flowIntensity ?? FlowIntensity.medium;
    _mood = widget.existingLog?.mood ?? Mood.happy;
  }

  Future<void> _submit() async {
    final userAsync = ref.read(userProvider);
    final user = userAsync.valueOrNull;

    if (user == null || user.coupleId == null || user.coupleId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please pair with a partner first'),
            backgroundColor: AppTheme.colors.love,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(cycleRepositoryProvider);
      
      // Convert from models CycleLog to domain CycleLog
      final domainLog = CycleLog(
        id: '', // Will be generated by repository if empty
        date: widget.date,
        flowIntensity: _flowIntensity,
        mood: _mood,
        notes: null, // Optional notes
      );

      await repository.addOrUpdateLog(domainLog, user.coupleId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingLog != null
                  ? 'Cycle log updated successfully!'
                  : 'Cycle log added successfully!',
            ),
            backgroundColor: AppTheme.colors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.colors.love,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: AppTheme.colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.colors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    widget.existingLog != null
                        ? 'Edit Cycle Log'
                        : 'Add Cycle Log',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.colors.text,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppTheme.colors.textSecondary,
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date display
                    Text(
                      _formatDate(widget.date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.colors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Flow Intensity
                    Text(
                      'Flow Intensity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.text,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: FlowIntensity.values.map((intensity) {
                        final isSelected = _flowIntensity == intensity;
                        return ChoiceChip(
                          label: Text(
                            intensity.name[0].toUpperCase() +
                                intensity.name.substring(1),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _flowIntensity = intensity;
                            });
                          },
                          selectedColor: AppTheme.colors.primary.withValues(alpha: 0.12),
                          checkmarkColor: AppTheme.colors.primary,
                          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: isSelected
                                    ? AppTheme.colors.primary
                                    : AppTheme.colors.text,
                                fontWeight:
                                    isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                          backgroundColor: AppTheme.colors.card,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.colors.primary
                                : AppTheme.colors.textSecondary.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1.5,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Mood
                    Text(
                      'Mood',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.text,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Mood.values.map((mood) {
                        final isSelected = _mood == mood;
                        return ChoiceChip(
                          label: Text(
                            mood.name[0].toUpperCase() + mood.name.substring(1),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _mood = mood;
                            });
                          },
                          selectedColor: AppTheme.colors.primary.withValues(alpha: 0.12),
                          checkmarkColor: AppTheme.colors.primary,
                          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: isSelected
                                    ? AppTheme.colors.primary
                                    : AppTheme.colors.text,
                                fontWeight:
                                    isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                          backgroundColor: AppTheme.colors.card,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.colors.primary
                                : AppTheme.colors.textSecondary.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1.5,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.colors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                widget.existingLog != null
                                    ? 'Update Log'
                                    : 'Add Log',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom + 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}