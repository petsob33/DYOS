import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_format.dart';
import '../../../gamification/presentation/user_stats_provider.dart';
import '../../../premium/presentation/premium_provider.dart';
import '../../domain/memory_model.dart';
import '../memory_provider.dart';
import '../widgets/pick_place_screen.dart';

/// Screen for adding a new memory or editing an existing one (caption, date, category, place only).
class AddMemoryScreen extends ConsumerStatefulWidget {
  const AddMemoryScreen({super.key, this.initialMemory});

  final Memory? initialMemory;

  @override
  ConsumerState<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends ConsumerState<AddMemoryScreen> {
  final _captionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  List<XFile> _selectedFiles = [];
  // Bytes read at pick time so previews work on every platform (Image.file
  // relies on dart:io, which is unsupported on web).
  final List<Uint8List> _selectedThumbnails = [];
  DateTime _selectedDate = DateTime.now();
  MemoryCategory _selectedCategory = MemoryCategory.other;
  Map<String, dynamic>? _location;

  bool get _isEditMode => widget.initialMemory != null;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMemory;
    if (m != null) {
      _captionController.text = m.caption;
      _selectedDate = m.date;
      _selectedCategory = m.category;
      _location = m.location;
    }
  }

  Future<void> _pickPlace() async {
    final result = await pickPlaceOnMap(context, initialLocation: _location);
    if (result != null && mounted) {
      setState(() {
        _location = result;
      });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  /// Pick multiple images/videos from gallery (with compression)
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFiles.isNotEmpty) {
        final thumbnails = await Future.wait(
          pickedFiles.map((file) => file.readAsBytes()),
        );
        if (mounted) {
          setState(() {
            _selectedFiles = pickedFiles;
            _selectedThumbnails
              ..clear()
              ..addAll(thumbnails);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.addMemoryScreenErrorPickingImages(e.toString())),
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

  /// Pick a single image/video (alternative method, with compression)
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        final thumbnail = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _selectedFiles.add(pickedFile);
            _selectedThumbnails.add(thumbnail);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.addMemoryScreenErrorPickingImage(e.toString())),
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

  /// Remove a selected image
  void _removeImage(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _selectedThumbnails.removeAt(index);
    });
  }

  /// Show date picker
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.primary,
              onPrimary: Colors.white,
              surface: context.colors.card,
              onSurface: context.colors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          DateTime.now().hour,
          DateTime.now().minute,
        );
      });
    }
  }

  /// Save the memory (create or update)
  Future<void> _saveMemory() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(addMemoryControllerProvider.notifier);

    if (_isEditMode) {
      final m = widget.initialMemory!;
      final updated = m.copyWith(
        caption: _captionController.text.trim(),
        date: _selectedDate,
        category: _selectedCategory,
        location: _location,
      );
      final ok = await controller.updateMemory(updated);
      if (ok && mounted) {
        ref.read(addMemoryControllerProvider.notifier).reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.addMemoryScreenMemoryUpdated),
            backgroundColor: context.colors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.pop();
      }
      return;
    }

    // Free plan limit: max 30 memories without premium
    const freeLimit = 30;
    final isPremium = ref.read(isPremiumProvider).valueOrNull ?? false;
    final memoriesAsync = ref.read(memoriesStreamProvider);
    final currentCount = memoriesAsync.valueOrNull?.length ?? 0;

    if (!isPremium && currentCount >= freeLimit) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.addMemoryScreenFreeLimitMessage),
            backgroundColor: context.colors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.push('/premium');
      }
      return;
    }

    if (_selectedFiles.isEmpty && _captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.addMemoryScreenAddImageOrCaption),
          backgroundColor: context.colors.love,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final memory = Memory(
      id: '',
      pairId: '',
      authorId: '',
      caption: _captionController.text.trim(),
      date: _selectedDate,
      category: _selectedCategory,
      location: _location,
      createdAt: DateTime.now(),
    );

    await controller.uploadMemory(
      memory: memory,
      mediaFiles: _selectedFiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = ref.watch(addMemoryControllerProvider) is AddMemoryUploading;

    // Listen to state changes to handle success/error
    ref.listen<AddMemoryState>(
      addMemoryControllerProvider,
      (previous, next) async {
        if (next is AddMemorySuccess) {
          final isNewMemory = widget.initialMemory == null;
          final xpGranted = isNewMemory
              ? await grantQuestXpIfEligible(ref, 'memory', 25)
              : false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isNewMemory
                    ? (xpGranted
                        ? context.l10n.addMemoryScreenMemorySavedXp
                        : context.l10n.addMemoryScreenMemorySavedXpOncePerDay)
                    : context.l10n.addMemoryScreenMemoryUpdatedWithCaption(
                        next.memory.caption.isEmpty
                            ? context.l10n.addMemoryScreenUntitledCaption
                            : next.memory.caption,
                      ),
              ),
              backgroundColor: context.colors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          ref.read(addMemoryControllerProvider.notifier).reset();
          if (mounted) {
            context.pop();
          }
        } else if (next is AddMemoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.message),
              backgroundColor: context.colors.love,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode
              ? context.l10n.addMemoryScreenEditMemoryTitle
              : context.l10n.addMemoryScreenAddMemoryTitle,
        ),
        actions: [
          if (isUploading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveMemory,
              child: Text(
                context.l10n.commonSave,
                style: TextStyle(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_isEditMode) ...[
                  _ImagePickerSection(
                    thumbnails: _selectedThumbnails,
                    onPickImages: _pickImages,
                    onPickImage: _pickImage,
                    onRemoveImage: _removeImage,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Caption field
                TextFormField(
                  controller: _captionController,
                  decoration: InputDecoration(
                    labelText: context.l10n.addMemoryScreenCaptionLabel,
                    hintText: context.l10n.addMemoryScreenCaptionHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.colors.textSecondary.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.colors.textSecondary.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: context.colors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: context.colors.card,
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  maxLines: 4,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.colors.text,
                      ),
                  validator: (value) {
                    // Optional validation - at least one field (image or caption) should be filled
                    // This is checked in _saveMemory method
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Date picker section
                _DatePickerSection(
                  selectedDate: _selectedDate,
                  onDateSelected: _selectDate,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Category selection section
                _CategorySelectionSection(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Place section
                _PlaceSection(
                  location: _location,
                  onAddPlace: _pickPlace,
                  onChangePlace: _pickPlace,
                  onRemovePlace: () {
                    setState(() {
                      _location = null;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Save button
                ElevatedButton(
                  onPressed: (isUploading && !_isEditMode) ? null : _saveMemory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: (isUploading && !_isEditMode)
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditMode
                              ? context.l10n.addMemoryScreenUpdateMemoryButton
                              : context.l10n.addMemoryScreenSaveMemoryButton,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Image picker section with preview
class _ImagePickerSection extends StatelessWidget {
  const _ImagePickerSection({
    required this.thumbnails,
    required this.onPickImages,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  final List<Uint8List> thumbnails;
  final VoidCallback onPickImages;
  final VoidCallback onPickImage;
  final void Function(int) onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.addMemoryScreenPhotosVideosLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.text,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Selected images preview
        if (thumbnails.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: thumbnails.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          thumbnails[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => onRemoveImage(index),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                PhosphorIconsBold.x,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          const SizedBox(height: AppSpacing.sm),
        const SizedBox(height: AppSpacing.sm),
        // Add image button
        OutlinedButton.icon(
          onPressed: onPickImages,
          icon: const Icon(PhosphorIconsBold.image),
          label: Text(
            thumbnails.isEmpty
                ? context.l10n.addMemoryScreenAddPhotos
                : context.l10n.addMemoryScreenAddMorePhotos,
            style: TextStyle(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(
              color: context.colors.primary,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Date picker section
class _DatePickerSection extends StatelessWidget {
  const _DatePickerSection({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final VoidCallback onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.addMemoryScreenDateLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.text,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onDateSelected,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsBold.calendar,
                    color: context.colors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(context, selectedDate),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.colors.text,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatTime24h(selectedDate),
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

  String _formatDate(BuildContext context, DateTime date) {
    final localeName = Localizations.localeOf(context).toString();
    return DateFormat.yMMMMd(localeName).format(date);
  }
}

/// Category selection section with chips
class _CategorySelectionSection extends StatelessWidget {
  const _CategorySelectionSection({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final MemoryCategory selectedCategory;
  final void Function(MemoryCategory) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.addMemoryScreenCategoryLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.text,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: MemoryCategory.values.map((category) {
            final isSelected = category == selectedCategory;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    category.displayName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(category);
                }
              },
                selectedColor: context.colors.primary.withValues(alpha: 0.12),
              checkmarkColor: context.colors.primary,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.text,
                  ),
              backgroundColor: context.colors.card,
                side: BorderSide(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.textSecondary.withValues(alpha: 0.2),
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

/// Place section: add / show name + change / remove
class _PlaceSection extends StatelessWidget {
  const _PlaceSection({
    required this.location,
    required this.onAddPlace,
    required this.onChangePlace,
    required this.onRemovePlace,
  });

  final Map<String, dynamic>? location;
  final VoidCallback onAddPlace;
  final VoidCallback onChangePlace;
  final VoidCallback onRemovePlace;

  @override
  Widget build(BuildContext context) {
    final name = location?['name'] as String?;
    final hasLocation = location != null &&
        location!['lat'] != null &&
        location!['lng'] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.addMemoryScreenPlaceLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.text,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!hasLocation)
          Material(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onAddPlace,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsBold.mapPin,
                      color: context.colors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        context.l10n.addMemoryScreenAddPlace,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.text,
                            ),
                      ),
                    ),
                    Icon(
                      PhosphorIconsBold.caretRight,
                      color: context.colors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Material(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsBold.mapPin,
                    color: context.colors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name ?? context.l10n.addMemoryScreenLocationSet,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.colors.text,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onChangePlace,
                    icon: Icon(
                      PhosphorIconsBold.pencilSimple,
                      color: context.colors.primary,
                      size: 20,
                    ),
                    tooltip: context.l10n.addMemoryScreenChangePlaceTooltip,
                  ),
                  IconButton(
                    onPressed: onRemovePlace,
                    icon: Icon(
                      PhosphorIconsBold.trash,
                      color: context.colors.love,
                      size: 20,
                    ),
                    tooltip: context.l10n.addMemoryScreenRemovePlaceTooltip,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
