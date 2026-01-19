import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bento_card.dart';
import 'auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserDataProvider);
    final partnerAsync = ref.watch(partnerProvider);

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: currentUserAsync.when(
                  data: (user) {
                    if (user == null) {
                      return const Center(
                        child: Text('User not found'),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header
                        BentoCard(
                          child: Row(
                            children: [
                              // Avatar
                              GestureDetector(
                                onTap: () {
                                  context.push('/edit-profile-picture');
                                },
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                                      backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                                          ? CachedNetworkImageProvider(user.photoUrl!)
                                          : null,
                                  child: user.photoUrl == null
                                      ? Icon(
                                          PhosphorIconsBold.user,
                                          size: 40,
                                          color: AppTheme.colors.primary,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              // User Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.displayName ?? 'No name',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.colors.text,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      user.email ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.colors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Partner Section
                        Text(
                          'Partner',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.colors.text,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        partnerAsync.when(
                          data: (partner) {
                            if (partner == null) {
                              return BentoCard(
                                child: Row(
                                  children: [
                                    Icon(
                                      PhosphorIconsBold.userPlus,
                                      color: AppTheme.colors.textSecondary,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Text(
                                        'No partner paired',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppTheme.colors.textSecondary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return BentoCard(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        AppTheme.colors.primary.withOpacity(0.1),
                                    backgroundImage: partner.photoUrl != null && partner.photoUrl!.isNotEmpty
                                        ? CachedNetworkImageProvider(partner.photoUrl!)
                                        : null,
                                    child: partner.photoUrl == null
                                        ? Icon(
                                            PhosphorIconsBold.user,
                                            size: 24,
                                            color: AppTheme.colors.primary,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          partner.displayName ?? 'No name',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.colors.text,
                                              ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          partner.email ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppTheme.colors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => BentoCard(
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (error, stackTrace) => BentoCard(
                            child: Text(
                              'Error loading partner: ${error.toString()}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.colors.love,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Actions
                        Text(
                          'Actions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.colors.text,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        BentoCard(
                          onTap: () {
                            context.push('/secret-notes');
                          },
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIconsBold.lock,
                                color: AppTheme.colors.primary,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  'Secret gift / Private',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.colors.text,
                                      ),
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
                        const SizedBox(height: AppSpacing.sm),
                        BentoCard(
                          onTap: () {
                            context.push('/settings');
                          },
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIconsBold.gear,
                                color: AppTheme.colors.primary,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  'Settings',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.colors.text,
                                      ),
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
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Error loading profile: ${error.toString()}',
                      style: TextStyle(color: AppTheme.colors.love),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
