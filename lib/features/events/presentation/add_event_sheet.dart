import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../gamification/presentation/user_stats_provider.dart';
import '../../premium/presentation/premium_provider.dart';
import '../data/event_repository.dart';
import '../domain/event_model.dart';

/// Modal bottom sheet for adding or editing an event
/// 
/// Features:
/// - Date picker (defaults to now)
/// - Title text field
/// - Submit button
class AddEventSheet extends ConsumerStatefulWidget {
  const AddEventSheet({
    super.key,
    this.eventToEdit,
    this.initialDate,
  });

  final Event? eventToEdit;
  final DateTime? initialDate;

  /// Show the add event sheet
  static Future<void> show(BuildContext context, {Event? eventToEdit, DateTime? initialDate}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => AddEventSheet(
        eventToEdit: eventToEdit,
        initialDate: initialDate,
      ),
    );
  }

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing event data
    if (widget.eventToEdit != null) {
      final event = widget.eventToEdit!;
      _selectedDate = event.date;
      _titleController.text = event.title;
    } else if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// Show date picker
  Future<void> _selectDate() async {
    HapticFeedback.selectionClick();
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
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

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  /// Submit the event
  Future<void> _submit() async {
    final title = _titleController.text.trim();
    
    if (title.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter a title'),
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

    final userDataAsync = ref.read(currentUserDataProvider);
    
    userDataAsync.whenData((userData) async {
      if (userData == null || userData.coupleId == null || userData.coupleId!.isEmpty) {
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
        final repository = ref.read(eventRepositoryProvider);
        
        final isEditing = widget.eventToEdit != null;
        final event = Event(
          id: isEditing ? widget.eventToEdit!.id : '',
          date: _selectedDate,
          title: title,
        );

        await repository.addOrUpdateEvent(event, userData.coupleId!);

        if (!isEditing) {
          grantQuestXpIfEligible(ref, 'event', 15);
          final isPremium = ref.read(isPremiumProvider).valueOrNull ?? false;
          await ref.read(adServiceProvider).maybeShowAdAfterIntimacyOrEventAdded(
                isPremium: isPremium,
              );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing
                  ? 'Event updated successfully!'
                  : 'Event added! +15 XP'),
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
    });
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
                    widget.eventToEdit != null ? 'Edit Event' : 'Add Event',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.colors.text,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(PhosphorIconsBold.x),
                    color: AppTheme.colors.textSecondary,
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
                    // Date picker
                    _DatePickerSection(
                      selectedDate: _selectedDate,
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Title field
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter event title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.colors.textSecondary.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.colors.textSecondary.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.colors.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppTheme.colors.card,
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                        prefixIcon: Icon(
                          PhosphorIconsBold.calendar,
                          color: AppTheme.colors.primary,
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.colors.text,
                          ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.colors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                widget.eventToEdit != null ? 'Update Event' : 'Add Event',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Date picker section
class _DatePickerSection extends StatelessWidget {
  const _DatePickerSection({
    required this.selectedDate,
    required this.onTap,
  });

  final DateTime selectedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: AppTheme.colors.card,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsBold.calendar,
                    color: AppTheme.colors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(selectedDate),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.colors.text,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(selectedDate),
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
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
}
