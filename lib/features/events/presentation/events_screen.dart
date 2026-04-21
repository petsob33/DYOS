import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bento_card.dart';
import '../../../shared/widgets/calendar/dyos_universal_calendar.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/event_repository.dart';
import '../domain/event_model.dart';
import '../presentation/event_provider.dart';
import 'add_event_sheet.dart';

/// Screen for viewing and managing events
/// 
/// Features:
/// - Calendar view with event markers
/// - List of events for selected date
/// - Add event functionality
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        backgroundColor: AppTheme.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIconsBold.arrowLeft,
            color: AppTheme.colors.text,
          ),
          onPressed: () {
            context.pop();
          },
          tooltip: 'Back',
        ),
        title: Text(
          'Events',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              PhosphorIconsBold.plus,
              color: AppTheme.colors.text,
            ),
            onPressed: () {
              AddEventSheet.show(context);
            },
            tooltip: 'Add event',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Calendar
              Padding(
                padding: const EdgeInsets.all(16),
                child: eventsAsync.when(
                  data: (events) {
                    // Debug: print events count
                    debugPrint('EventsScreen: Loaded ${events.length} events');
                    
                    // Create a map of events by date for faster lookup
                    final eventsByDate = <DateTime, List<Event>>{};
                    for (final event in events) {
                      final normalizedDate = DateTime(
                        event.date.year,
                        event.date.month,
                        event.date.day,
                      );
                      eventsByDate.putIfAbsent(normalizedDate, () => []).add(event);
                      debugPrint('EventsScreen: Event ${event.title} on ${normalizedDate.toString()}');
                    }
                    
                    return Column(
                      children: [
                        // Debug: show events count
                        if (events.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Debug: ${events.length} events loaded',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        OurOSUniversalCalendar(
                      key: ValueKey('calendar_${events.length}_${events.map((e) => '${e.id}_${e.date.millisecondsSinceEpoch}').join('_')}'),
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                      eventLoader: (date) {
                        // Return event markers for this date
                        final normalizedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                        );
                        
                        final dayEvents = eventsByDate[normalizedDate] ?? [];
                        final hasEvents = dayEvents.isNotEmpty;
                        debugPrint('EventsScreen: eventLoader called for ${normalizedDate.toString()}, hasEvents: $hasEvents, eventsByDate keys: ${eventsByDate.keys.map((d) => d.toString()).join(", ")}');
                        if (hasEvents) {
                          debugPrint('EventsScreen: eventLoader for ${normalizedDate.toString()} found ${dayEvents.length} events');
                        }
                        return hasEvents ? ['event'] : [];
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.contains('event')) {
                            debugPrint('EventsScreen: markerBuilder for ${date.toString()} - showing marker');
                            return Positioned(
                              bottom: 2,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppTheme.colors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              // Events list - show all events or filtered by selected day
              eventsAsync.when(
                data: (events) {
                  // Filter events by selected day if one is selected
                  final filteredEvents = _selectedDay != null
                      ? events.where((event) {
                          final normalizedDate = DateTime(
                            _selectedDay!.year,
                            _selectedDay!.month,
                            _selectedDay!.day,
                          );
                          final eventDate = DateTime(
                            event.date.year,
                            event.date.month,
                            event.date.day,
                          );
                          return eventDate == normalizedDate;
                        }).toList()
                      : events;

                  if (filteredEvents.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIconsBold.calendar,
                              size: 64,
                              color: AppTheme.colors.textSecondary.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _selectedDay != null
                                  ? 'No events on this day'
                                  : 'No events yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.colors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: () {
                                AddEventSheet.show(
                                  context,
                                  eventToEdit: null,
                                  initialDate: _selectedDay,
                                );
                              },
                              child: const Text('Add event'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _EventCard(
                          event: event,
                          onDelete: () => _deleteEvent(context, ref, event),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text(
                    'Error loading events: $error',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.colors.love,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteEvent(BuildContext context, WidgetRef ref, Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.colors.love,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final userAsync = ref.read(currentUserDataProvider);
    userAsync.whenData((userData) async {
      if (userData == null || userData.coupleId == null || userData.coupleId!.isEmpty) {
        if (context.mounted) {
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

      try {
        final repository = ref.read(eventRepositoryProvider);
        await repository.deleteEvent(event.id, userData.coupleId!);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Event deleted successfully'),
              backgroundColor: AppTheme.colors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
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
    });
  }
}

/// Card displaying a single event
class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.onDelete,
  });

  final Event event;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatTime(event.date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.colors.primary,
                    ),
              ),
              Text(
                _formatDate(event.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          // Title
          Expanded(
            child: Text(
              event.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colors.text,
                  ),
            ),
          ),
          // Delete button
          IconButton(
            icon: Icon(
              PhosphorIconsBold.trash,
              color: AppTheme.colors.love,
              size: 20,
            ),
            onPressed: onDelete,
            tooltip: 'Delete event',
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}';
  }
}
