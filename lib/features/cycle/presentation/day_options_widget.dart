import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/build_context_l10n_extension.dart';
import '../../../core/widgets/bento_card.dart';
import '../../../core/utils/time_format.dart';
import '../../events/presentation/add_event_sheet.dart';
import '../../events/domain/event_model.dart';
import '../../tracker/domain/intimacy_log_model.dart';
import '../../tracker/presentation/widgets/add_intimacy_sheet.dart';
import '../../tracker/presentation/widgets/intimacy_log_detail_sheet.dart';
import '../../timeline/domain/memory_model.dart';
import '../../timeline/presentation/widgets/memory_detail_dialog.dart';
import '../domain/cycle_log_model.dart';

/// Day Options Widget - displays day events and actions directly on the page
class DayOptionsWidget extends ConsumerWidget {
  const DayOptionsWidget({
    super.key,
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
