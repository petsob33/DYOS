import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/calendar/dyos_universal_calendar.dart';
import '../../auth/presentation/auth_providers.dart';
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
                    'Cycle Tracker',
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
                      return Column(
                        children: [
                          DyosUniversalCalendar(
                            focusedDay: _focusedDay,
                            selectedDay: _selectedDay,
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                              _showCycleLogSheet(context, selectedDay, logs);
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
                          }
                        } catch (e) {
                          // No log found for this date
                        }
                        
                        // Check for predicted period
                        final isPredictedPeriod = predictedPeriods.any(
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
                        }
                        
                        // Check for fertile window
                        final isFertile = fertileDays.any(
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
                        if (ovulationDay != null) {
                          final ovulationNormalized = DateTime(
                            ovulationDay.year,
                            ovulationDay.month,
                            ovulationDay.day,
                          );
                          if (ovulationNormalized == normalizedDate) {
                            markers.add('ovulation');
                          }
                        }
                        
                        return markers;
                      },
                      markerBuilder: (context, date, events) {
                        // Priority: recorded_period > predicted_period > ovulation > fertile
                        if (events.contains('recorded_period')) {
                          return Positioned(
                            bottom: 2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppTheme.colors.love,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        
                        if (events.contains('predicted_period')) {
                          return Positioned(
                            bottom: 2,
                            child: Container(
                              width: 6,
                              height: 6,
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
                        }
                        
                        if (events.contains('ovulation')) {
                          return Positioned(
                            bottom: 2,
                            child: Container(
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
                        }
                        
                        if (events.contains('fertile')) {
                          return Positioned(
                            bottom: 2,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppTheme.colors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        
                        return const SizedBox.shrink();
                      },
                      calendarBuilders: settings != null
                          ? CalendarBuilders(
                              defaultBuilder: (context, date, _) {
                                final status = CycleCalculator.calculateStatus(
                                  settings: settings,
                                  targetDate: date,
                                );
                                
                                Color? backgroundColor;
                                switch (status.phase) {
                                  case CyclePhase.menstruation:
                                    backgroundColor = _menstruationColor.withValues(alpha: 0.15);
                                    break;
                                  case CyclePhase.follicular:
                                    backgroundColor = _follicularColor.withValues(alpha: 0.15);
                                    break;
                                  case CyclePhase.ovulation:
                                    backgroundColor = _fertileColor.withValues(alpha: 0.2);
                                    break;
                                  case CyclePhase.luteal:
                                    backgroundColor = _lutealColor.withValues(alpha: 0.15);
                                    break;
                                }
                                
                                if (backgroundColor == null) return null;
                                
                                return Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
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
                                // Use existing marker builder logic
                                if (events.contains('recorded_period')) {
                                  return Positioned(
                                    bottom: 2,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppTheme.colors.love,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }
                                if (events.contains('predicted_period')) {
                                  return Positioned(
                                    bottom: 2,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppTheme.colors.love.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.colors.love,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                if (events.contains('ovulation')) {
                                  return Positioned(
                                    bottom: 2,
                                    child: Container(
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
                                }
                                if (events.contains('fertile')) {
                                  return Positioned(
                                    bottom: 2,
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: AppTheme.colors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            )
                          : null,
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