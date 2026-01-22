import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/cycle_repository.dart';
import '../domain/cycle_calculator.dart';
import '../domain/cycle_settings_model.dart';
import 'cycle_provider.dart';

/// Bottom sheet for configuring cycle settings
class CycleSettingsSheet extends ConsumerStatefulWidget {
  const CycleSettingsSheet({super.key});

  @override
  ConsumerState<CycleSettingsSheet> createState() => _CycleSettingsSheetState();
}

class _CycleSettingsSheetState extends ConsumerState<CycleSettingsSheet> {
  bool _isLoading = false;

  Future<void> _saveLastPeriodDate(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
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

      final repository = ref.read(cycleRepositoryProvider);
      final currentSettings = await repository.getSettings(user.coupleId!);

      final updatedSettings = CycleSettings(
        id: currentSettings?.id ?? 'settings',
        averageCycleLength: currentSettings?.averageCycleLength ?? 28,
        periodLength: currentSettings?.periodLength ?? 5,
        lastPeriodDate: date,
      );

      await repository.updateSettings(updatedSettings, user.coupleId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings saved successfully!'),
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectLastPeriodDate() async {
    final settingsAsync = ref.read(cycleSettingsStreamProvider);
    final settings = settingsAsync.valueOrNull;
    final initialDate = settings?.lastPeriodDate ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.colors.primary,
              onPrimary: Colors.white,
              surface: AppTheme.colors.card,
              onSurface: AppTheme.colors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      await _saveLastPeriodDate(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(cycleSettingsStreamProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
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
                    'Cycle Settings',
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: settingsAsync.when(
                  data: (settings) {
                    // Calculate day in cycle for today
                    int? dayInCycle;
                    if (settings != null) {
                      final status = CycleCalculator.calculateStatus(
                        settings: settings,
                        targetDate: DateTime.now(),
                      );
                      dayInCycle = status.dayInCycle > 0 ? status.dayInCycle : null;
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Day in Cycle
                        if (dayInCycle != null) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppTheme.colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: AppTheme.colors.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Day in Cycle',
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                              color: AppTheme.colors.textSecondary,
                                            ),
                                      ),
                                      Text(
                                        'Day $dayInCycle',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.colors.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        Text(
                          'Last Period Date',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.colors.text,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: AppTheme.colors.card,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _isLoading ? null : _selectLastPeriodDate,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: AppTheme.colors.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          settings?.lastPeriodDate != null
                                              ? _formatDate(settings!.lastPeriodDate!)
                                              : 'Not set',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: settings?.lastPeriodDate != null
                                                    ? AppTheme.colors.text
                                                    : AppTheme.colors.textSecondary,
                                              ),
                                        ),
                                        if (settings?.lastPeriodDate != null)
                                          const SizedBox(height: 2),
                                        if (settings?.lastPeriodDate != null)
                                          Text(
                                            'Tap to change',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppTheme.colors.textSecondary,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (_isLoading)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  else
                                    Icon(
                                      Icons.chevron_right,
                                      color: AppTheme.colors.textSecondary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Average Cycle Length',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.colors.text,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${settings?.averageCycleLength ?? 28} days',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.colors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Period Length',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.colors.text,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${settings?.periodLength ?? 5} days',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.colors.textSecondary,
                              ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom + 16),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stackTrace) {
                    debugPrint('Error loading settings: $error');
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Error loading settings',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.colors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Last Period Date',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.colors.text,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Material(
                            color: AppTheme.colors.card,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _isLoading ? null : _selectLastPeriodDate,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppTheme.colors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Text(
                                        'Not set',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.colors.textSecondary,
                                            ),
                                      ),
                                    ),
                                    if (_isLoading)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    else
                                      Icon(
                                        Icons.chevron_right,
                                        color: AppTheme.colors.textSecondary,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
