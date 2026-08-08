import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/build_context_l10n_extension.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/cycle_repository.dart';
import '../domain/cycle_log_model.dart';

/// Bottom sheet for adding/editing cycle log
class CycleLogSheet extends ConsumerStatefulWidget {
  const CycleLogSheet({
    super.key,
    required this.date,
    this.existingLog,
  });

  final DateTime date;
  final CycleLog? existingLog;

  @override
  ConsumerState<CycleLogSheet> createState() => _CycleLogSheetState();
}

class _CycleLogSheetState extends ConsumerState<CycleLogSheet> {
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
            content: Text(context.l10n.cycleTrackingScreenPairFirst),
            backgroundColor: context.colors.love,
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

      // Empty id lets the repository generate a new doc; reuse the existing
      // log's id when editing so this updates it instead of creating a
      // duplicate entry for the same day.
      final log = CycleLog(
        id: widget.existingLog?.id ?? '',
        date: widget.date,
        flowIntensity: _flowIntensity,
        mood: _mood,
        notes: widget.existingLog?.notes,
      );

      await repository.addOrUpdateLog(log, user.coupleId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingLog != null
                  ? context.l10n.cycleTrackingScreenLogUpdated
                  : context.l10n.cycleTrackingScreenLogAdded,
            ),
            backgroundColor: context.colors.success,
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
            content: Text(context.l10n.cycleTrackingScreenError(e.toString())),
            backgroundColor: context.colors.love,
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
        color: context.colors.background,
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
                color: context.colors.textSecondary.withValues(alpha: 0.3),
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
                        ? context.l10n.cycleTrackingScreenEditLogTitle
                        : context.l10n.cycleTrackingScreenAddLogTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.text,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: context.colors.textSecondary,
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
                      _formatDate(context, widget.date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Flow Intensity
                    Text(
                      context.l10n.cycleTrackingScreenFlowIntensityLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.text,
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
                          selectedColor: context.colors.primary.withValues(alpha: 0.12),
                          checkmarkColor: context.colors.primary,
                          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: isSelected
                                    ? context.colors.primary
                                    : context.colors.text,
                                fontWeight:
                                    isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                          backgroundColor: context.colors.card,
                          side: BorderSide(
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.textSecondary.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1.5,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Mood
                    Text(
                      context.l10n.cycleTrackingScreenMoodLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.text,
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
                          selectedColor: context.colors.primary.withValues(alpha: 0.12),
                          checkmarkColor: context.colors.primary,
                          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: isSelected
                                    ? context.colors.primary
                                    : context.colors.text,
                                fontWeight:
                                    isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                          backgroundColor: context.colors.card,
                          side: BorderSide(
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.textSecondary.withValues(alpha: 0.2),
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
                          backgroundColor: context.colors.primary,
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
                                    ? context.l10n.cycleTrackingScreenUpdateLogButton
                                    : context.l10n.cycleTrackingScreenAddLogButton,
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

  String _formatDate(BuildContext context, DateTime date) {
    return DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date);
  }
}
