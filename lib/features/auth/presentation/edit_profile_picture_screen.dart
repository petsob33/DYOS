import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/build_context_l10n_extension.dart';
import '../../../core/widgets/bento_card.dart';
import '../data/user_repository.dart';
import 'auth_providers.dart';

/// Screen for editing profile picture
/// 
/// Features:
/// - Display current profile picture
/// - Pick new image from gallery
/// - Upload to Firebase Storage
/// - Update photoUrl in Firestore users collection
class EditProfilePictureScreen extends ConsumerStatefulWidget {
  const EditProfilePictureScreen({super.key});

  @override
  ConsumerState<EditProfilePictureScreen> createState() =>
      _EditProfilePictureScreenState();
}

class _EditProfilePictureScreenState
    extends ConsumerState<EditProfilePictureScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  /// Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.editProfilePictureScreenPickError(e.toString())),
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

  /// Upload profile picture and update user data
  Future<void> _saveProfilePicture() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.editProfilePictureScreenSelectImageFirst),
          backgroundColor: context.colors.love,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final userDataAsync = ref.read(currentUserDataProvider);
    
    userDataAsync.whenData((userData) async {
      if (userData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.editProfilePictureScreenUserNotFound),
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
        _isUploading = true;
      });

      try {
        final storageService = ref.read(storageServiceProvider);
        final userRepository = ref.read(userRepositoryProvider);

        // Delete old profile picture if it exists
        if (userData.photoUrl != null && userData.photoUrl!.isNotEmpty) {
          try {
            await storageService.deleteProfilePicture(userData.photoUrl!);
          } catch (e) {
            // Silently fail - old picture might not exist
          }
        }

        // Upload new profile picture
        final downloadUrl = await storageService.uploadProfilePicture(
          _selectedImage!,
          userData.uid,
        );

        // Update user document in Firestore
        await userRepository.updateUserFields(
          userData.uid,
          {'photoUrl': downloadUrl},
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.editProfilePictureScreenUpdateSuccess),
              backgroundColor: context.colors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.editProfilePictureScreenGenericError(e.toString())),
              backgroundColor: context.colors.love,
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

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(context.l10n.editProfilePictureScreenTitle),
      ),
      body: SafeArea(
        child: userDataAsync.when(
          data: (userData) {
            if (userData == null) {
              return Center(
                child: Text(context.l10n.editProfilePictureScreenUserNotFound),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current/Selected Profile Picture
                  BentoCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        // Profile Picture Preview
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundColor:
                                  context.colors.primary.withValues(alpha: 0.1),
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (userData.photoUrl != null &&
                                          userData.photoUrl!.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          userData.photoUrl!)
                                      : null),
                              child: _selectedImage == null &&
                                      (userData.photoUrl == null ||
                                          userData.photoUrl!.isEmpty)
                                  ? Icon(
                                      PhosphorIconsBold.user,
                                      size: 80,
                                      color: context.colors.primary,
                                    )
                                  : null,
                            ),
                            if (_isUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Pick Image Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isUploading ? null : _pickImage,
                            icon: const Icon(PhosphorIconsBold.image),
                            label: Text(context.l10n.editProfilePictureScreenChooseImage),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.colors.primary,
                              side: BorderSide(
                                color: context.colors.primary,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isUploading || _selectedImage == null)
                          ? null
                          : _saveProfilePicture,
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
                      child: _isUploading
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
                              context.l10n.editProfilePictureScreenSaveButton,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text(context.l10n.editProfilePictureScreenGenericError(error.toString())),
          ),
        ),
      ),
    );
  }
}
