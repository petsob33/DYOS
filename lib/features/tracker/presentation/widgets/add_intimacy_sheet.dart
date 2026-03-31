import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../gamification/presentation/user_stats_provider.dart';
import '../../../premium/presentation/premium_provider.dart';
import '../../data/intimacy_repository.dart';
import '../../domain/intimacy_log_model.dart';

/// Available tags for intimacy logs
final List<String> availableTags = [
  'Romantic',
  'Quickie',
  'Slow',
  'Morning',
  'Evening',
  'Oral',
  'Toy',
  'Massage',
  'Experiment',
  'Passionate',
  'Tender',
];

/// Modal bottom sheet for adding or editing an intimacy log
/// 
/// Features:
/// - Date picker (defaults to now)
/// - 5-star rating with fire icons
/// - Initiator selection (Me/Partner)
/// - Tag selection with chips
/// - Protection switch
/// - Submit button
class AddIntimacySheet extends ConsumerStatefulWidget {
  const AddIntimacySheet({
    super.key,
    this.logToEdit,
  });

  final IntimacyLog? logToEdit;

  /// Show the add intimacy sheet
  static Future<void> show(BuildContext context, {IntimacyLog? logToEdit}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => AddIntimacySheet(logToEdit: logToEdit),
    );
  }

  @override
  ConsumerState<AddIntimacySheet> createState() => _AddIntimacySheetState();
}

class _AddIntimacySheetState extends ConsumerState<AddIntimacySheet> {
  DateTime _selectedDate = DateTime.now();
  int _rating = 5;
  String? _initiatorId;
  final Set<String> _selectedTags = {};
  bool _protectionUsed = false;
  final TextEditingController _noteController = TextEditingController();
  int _orgasmsMe = 0;
  int _orgasmsPartner = 0;
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isSubmitting = false;
  bool _initiatorInitialized = false;

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing log data
    if (widget.logToEdit != null) {
      final log = widget.logToEdit!;
      _selectedDate = log.date;
      _rating = log.rating;
      _initiatorId = log.initiatorId;
      _selectedTags.addAll(log.tags);
      _protectionUsed = log.protectionUsed;
      _noteController.text = log.note ?? '';
      _orgasmsMe = log.userOrgasmCount;
      _orgasmsPartner = log.partnerOrgasmCount;
      if (log.duration != null) {
        _durationController.text = log.duration.toString();
      }
      if (log.location != null) {
        _locationController.text = log.location!;
      }
      _initiatorInitialized = true;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Show date and time picker
  Future<void> _selectDate() async {
    HapticFeedback.selectionClick();
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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

  /// Select rating (1-5)
  void _selectRating(int rating) {
    HapticFeedback.selectionClick();
    setState(() {
      _rating = rating;
    });
  }

  /// Toggle tag selection
  void _toggleTag(String tag) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  /// Submit the intimacy log
  Future<void> _submit() async {
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

      if (_initiatorId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please select an initiator'),
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
        final repository = ref.read(intimacyRepositoryProvider);
        
        final durationMinutes = _durationController.text.trim().isEmpty
            ? null
            : int.tryParse(_durationController.text.trim());

        final isEditing = widget.logToEdit != null;
        final log = IntimacyLog(
          id: isEditing ? widget.logToEdit!.id : '',
          date: _selectedDate,
          initiatorId: _initiatorId!,
          rating: _rating,
          tags: _selectedTags.toList(),
          protectionUsed: _protectionUsed,
          note: _noteController.text.trim().isEmpty 
              ? null 
              : _noteController.text.trim(),
          userOrgasmCount: _orgasmsMe,
          partnerOrgasmCount: _orgasmsPartner,
          duration: durationMinutes,
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
        );

        if (isEditing) {
          await repository.updateLog(log, userData.coupleId!);
        } else {
          await repository.addLog(log, userData.coupleId!);
          grantQuestXpIfEligible(ref, 'intimacy', 20);
          final isPremium = ref.read(isPremiumProvider).valueOrNull ?? false;
          await ref.read(adServiceProvider).maybeShowAdAfterIntimacyOrEventAdded(
                isPremium: isPremium,
              );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing
                  ? 'Intimacy log updated successfully!'
                  : 'Intimacy log added! +20 XP'),
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
    final userDataAsync = ref.watch(currentUserDataProvider);
    final partnerAsync = ref.watch(partnerProvider);

    // Initialize default initiator once when user data becomes available
    if (!_initiatorInitialized) {
      userDataAsync.whenData((userData) {
        if (userData != null && _initiatorId == null) {
          Future.microtask(() {
            if (mounted) {
              setState(() {
                _initiatorId = userData.uid;
                _initiatorInitialized = true;
              });
            }
          });
        }
      });
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                    widget.logToEdit != null ? 'Edit Intimacy Log' : 'Add Intimacy Log',
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

                    // Rating section
                    _RatingSection(
                      rating: _rating,
                      onRatingSelected: _selectRating,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Initiator section
                    userDataAsync.when(
                      data: (userData) => partnerAsync.when(
                        data: (partnerData) => _InitiatorSection(
                          currentUserId: userData?.uid ?? '',
                          partnerId: partnerData?.uid ?? '',
                          selectedId: _initiatorId,
                          currentUserDisplayName: userData?.displayName ?? 'Me',
                          partnerDisplayName: partnerData?.displayName ?? 'Partner',
                          currentUserPhotoUrl: userData?.photoUrl,
                          partnerPhotoUrl: partnerData?.photoUrl,
                          onSelected: (id) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _initiatorId = id;
                            });
                          },
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Tags section
                    _TagsSection(
                      selectedTags: _selectedTags,
                      onTagToggled: _toggleTag,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Protection switch
                    _ProtectionSwitch(
                      value: _protectionUsed,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _protectionUsed = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Orgasms section
                    userDataAsync.when(
                      data: (userData) => partnerAsync.when(
                        data: (partnerData) => _OrgasmsSection(
                          currentUserDisplayName: userData?.displayName ?? 'Me',
                          partnerDisplayName: partnerData?.displayName ?? 'Partner',
                          orgasmsMe: _orgasmsMe,
                          orgasmsPartner: _orgasmsPartner,
                          onOrgasmsMeChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _orgasmsMe = value;
                            });
                          },
                          onOrgasmsPartnerChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _orgasmsPartner = value;
                            });
                          },
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Duration section
                    _DurationSection(
                      controller: _durationController,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Location section
                    _LocationSection(
                      controller: _locationController,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Note field (optional)
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Note (optional)',
                        hintText: 'Add any notes...',
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
                      ),
                      maxLines: 3,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.colors.text,
                          ),
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
                                widget.logToEdit != null ? 'Update Log' : 'Add Log',
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

/// Rating section with 5 fire icons
class _RatingSection extends StatelessWidget {
  const _RatingSection({
    required this.rating,
    required this.onRatingSelected,
  });

  final int rating;
  final ValueChanged<int> onRatingSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final value = index + 1;
            final isSelected = value <= rating;
            return GestureDetector(
              onTap: () => onRatingSelected(value),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  PhosphorIconsBold.fire,
                  size: 36,
                  color: isSelected
                      ? AppTheme.colors.love
                      : AppTheme.colors.textSecondary.withValues(alpha: 0.3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Initiator selection section
class _InitiatorSection extends StatelessWidget {
  const _InitiatorSection({
    required this.currentUserId,
    required this.partnerId,
    required this.selectedId,
    required this.currentUserDisplayName,
    required this.partnerDisplayName,
    this.currentUserPhotoUrl,
    this.partnerPhotoUrl,
    required this.onSelected,
  });

  final String currentUserId;
  final String partnerId;
  final String? selectedId;
  final String currentUserDisplayName;
  final String partnerDisplayName;
  final String? currentUserPhotoUrl;
  final String? partnerPhotoUrl;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Initiator',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _InitiatorOption(
                label: currentUserDisplayName,
                isSelected: selectedId == currentUserId,
                photoUrl: currentUserPhotoUrl,
                onTap: () => onSelected(currentUserId),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _InitiatorOption(
                label: partnerDisplayName,
                isSelected: selectedId == partnerId,
                photoUrl: partnerPhotoUrl,
                onTap: () => onSelected(partnerId),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Single initiator option
class _InitiatorOption extends StatelessWidget {
  const _InitiatorOption({
    required this.label,
    required this.isSelected,
    this.photoUrl,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final String? photoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppTheme.colors.primary.withValues(alpha: 0.12)
          : AppTheme.colors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.colors.primary
                  : AppTheme.colors.textSecondary.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isSelected
                    ? AppTheme.colors.primary
                    : AppTheme.colors.textSecondary.withValues(alpha: 0.1),
                backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(photoUrl!)
                    : null,
                child: photoUrl == null || photoUrl!.isEmpty
                    ? Icon(
                        PhosphorIconsBold.user,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.colors.textSecondary,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.colors.primary
                          : AppTheme.colors.text,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tags selection section
class _TagsSection extends StatelessWidget {
  const _TagsSection({
    required this.selectedTags,
    required this.onTagToggled,
  });

  final Set<String> selectedTags;
  final ValueChanged<String> onTagToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: availableTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return ChoiceChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => onTagToggled(tag),
              selectedColor: AppTheme.colors.primary.withValues(alpha: 0.12),
              checkmarkColor: AppTheme.colors.primary,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? AppTheme.colors.primary
                        : AppTheme.colors.text,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
              backgroundColor: AppTheme.colors.card,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.colors.primary
                    : AppTheme.colors.textSecondary.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1.5,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Protection switch section
class _ProtectionSwitch extends StatelessWidget {
  const _ProtectionSwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.colors.card,
      borderRadius: BorderRadius.circular(16),
      child: SwitchListTile(
        title: Text(
          'Protection Used',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.colors.text,
              ),
        ),
        subtitle: Text(
          'Was protection used during intimacy?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.colors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}

/// Orgasms section with counters for both partners
class _OrgasmsSection extends StatelessWidget {
  const _OrgasmsSection({
    required this.currentUserDisplayName,
    required this.partnerDisplayName,
    required this.orgasmsMe,
    required this.orgasmsPartner,
    required this.onOrgasmsMeChanged,
    required this.onOrgasmsPartnerChanged,
  });

  final String currentUserDisplayName;
  final String partnerDisplayName;
  final int orgasmsMe;
  final int orgasmsPartner;
  final ValueChanged<int> onOrgasmsMeChanged;
  final ValueChanged<int> onOrgasmsPartnerChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Orgasms',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _OrgasmCounter(
                label: currentUserDisplayName,
                count: orgasmsMe,
                onChanged: onOrgasmsMeChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _OrgasmCounter(
                label: partnerDisplayName,
                count: orgasmsPartner,
                onChanged: onOrgasmsPartnerChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Single orgasm counter widget
class _OrgasmCounter extends StatelessWidget {
  const _OrgasmCounter({
    required this.label,
    required this.count,
    required this.onChanged,
  });

  final String label;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.colors.card,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.colors.textSecondary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colors.text,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: count > 0 ? () => onChanged(count - 1) : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: count > 0
                          ? AppTheme.colors.primary.withValues(alpha: 0.1)
                          : AppTheme.colors.textSecondary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIconsBold.minus,
                      size: 18,
                      color: count > 0
                          ? AppTheme.colors.primary
                          : AppTheme.colors.textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.colors.text,
                      ),
                ),
                const SizedBox(width: AppSpacing.md),
                InkWell(
                  onTap: () => onChanged(count + 1),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIconsBold.plus,
                      size: 18,
                      color: AppTheme.colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Duration section
class _DurationSection extends StatelessWidget {
  const _DurationSection({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: 'Duration (minutes)',
            hintText: 'e.g., 30',
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
              PhosphorIconsBold.clock,
              color: AppTheme.colors.primary,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.colors.text,
              ),
        ),
      ],
    );
  }
}

/// Location section
class _LocationSection extends StatelessWidget {
  const _LocationSection({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Location (optional)',
            hintText: 'e.g., Home, Hotel, Beach...',
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
              PhosphorIconsBold.mapPin,
              color: AppTheme.colors.primary,
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.colors.text,
              ),
        ),
      ],
    );
  }
}
