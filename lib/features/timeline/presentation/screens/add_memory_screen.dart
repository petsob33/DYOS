import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/memory_model.dart';
import '../memory_provider.dart';

/// Screen for adding a new memory with photos/videos
/// 
/// Features:
/// - Multiple photo/video selection using image_picker
/// - Caption text field
/// - Date picker (defaults to today)
/// - Category selection with emoji chips
/// - Save button with loading state
class AddMemoryScreen extends ConsumerStatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  ConsumerState<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends ConsumerState<AddMemoryScreen> {
  final _captionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  List<File> _selectedFiles = [];
  DateTime _selectedDate = DateTime.now();
  MemoryCategory _selectedCategory = MemoryCategory.other;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  /// Pick multiple images/videos from gallery
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
      
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedFiles = pickedFiles.map((file) => File(file.path)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: ${e.toString()}'),
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

  /// Pick a single image/video (alternative method)
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFiles.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
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

  /// Remove a selected image
  void _removeImage(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
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

  /// Save the memory
  Future<void> _saveMemory() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate at least one image or caption
    if (_selectedFiles.isEmpty && _captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one image or a caption'),
          backgroundColor: AppTheme.colors.love,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Create memory object
    final memory = Memory(
      id: '', // Will be auto-generated
      pairId: '', // Will be set by controller
      authorId: '', // Will be set by controller
      caption: _captionController.text.trim(),
      date: _selectedDate,
      category: _selectedCategory,
      createdAt: DateTime.now(),
    );

    // Get controller and upload
    // The state changes will be handled by ref.listen in build method
    final controller = ref.read(addMemoryControllerProvider.notifier);
    await controller.uploadMemory(
      memory: memory,
      mediaFiles: _selectedFiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(addMemoryControllerProvider);
    final isUploading = controllerState.maybeWhen(
      uploading: () => true,
      orElse: () => false,
    );

    // Listen to state changes to handle success/error
    ref.listen<AddMemoryState>(
      addMemoryControllerProvider,
      (previous, next) {
        // Only handle state transitions from uploading to success/error
        // This prevents triggering on initial build or state resets
        final wasUploading = previous?.maybeWhen(uploading: () => true, orElse: () => false) ?? false;
        
        if (wasUploading) {
          next.when(
            initial: () {},
            uploading: () {
              // Still uploading, do nothing
            },
            success: (createdMemory) {
              // Show success message
              final memory = createdMemory as Memory;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Memory "${memory.caption.isEmpty ? 'Untitled' : memory.caption}" saved successfully!',
                  ),
                  backgroundColor: AppTheme.colors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
              // Reset controller state
              ref.read(addMemoryControllerProvider.notifier).reset();
              // Pop screen
              if (mounted) {
                context.pop();
              }
            },
            error: (message) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppTheme.colors.love,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Add Memory'),
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
                'Save',
                style: TextStyle(
                  color: AppTheme.colors.primary,
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
                // Image picker section
                _ImagePickerSection(
                  selectedFiles: _selectedFiles,
                  onPickImages: _pickImages,
                  onPickImage: _pickImage,
                  onRemoveImage: _removeImage,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Caption field
                TextFormField(
                  controller: _captionController,
                  decoration: InputDecoration(
                    labelText: 'Caption',
                    hintText: 'What\'s this memory about?',
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
                  maxLines: 4,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.colors.text,
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
                const SizedBox(height: AppSpacing.xl),

                // Save button
                ElevatedButton(
                  onPressed: isUploading ? null : _saveMemory,
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
                  child: isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Memory',
                          style: TextStyle(
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
    required this.selectedFiles,
    required this.onPickImages,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  final List<File> selectedFiles;
  final VoidCallback onPickImages;
  final VoidCallback onPickImage;
  final void Function(int) onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos & Videos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Selected images preview
        if (selectedFiles.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedFiles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          selectedFiles[index],
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
            selectedFiles.isEmpty ? 'Add Photos' : 'Add More Photos',
            style: TextStyle(
              color: AppTheme.colors.primary,
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
              color: AppTheme.colors.primary,
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
          'Date',
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
            onTap: onDateSelected,
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

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
          'Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
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
                selectedColor: AppTheme.colors.primary.withValues(alpha: 0.12),
              checkmarkColor: AppTheme.colors.primary,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? AppTheme.colors.primary
                        : AppTheme.colors.text,
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
