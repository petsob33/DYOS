import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../models/notes_provider.dart';
import '../../../../widgets/home/quick_note_card.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../auth/domain/couple_model.dart';
import '../../../auth/domain/user_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
   @override
  Widget build(BuildContext context) {
    // 1. Načtení providerů
    final isPairedAsync = ref.watch(isUserPairedProvider);
    final currentUserAsync = ref.watch(currentUserDataProvider);
    final coupleAsync = ref.watch(currentCoupleProvider);
    final partnerAsync = ref.watch(partnerProvider);

    // 2. Debug výpis STAVU všech providerů
    debugPrint('=== HOME SCREEN DEBUG ===');
    debugPrint('isPaired: isLoading=${isPairedAsync.isLoading}, hasValue=${isPairedAsync.hasValue}, value=${isPairedAsync.value}');
    debugPrint('currentUser: isLoading=${currentUserAsync.isLoading}, hasValue=${currentUserAsync.hasValue}, hasError=${currentUserAsync.hasError}');
    if (currentUserAsync.hasValue) {
      debugPrint('currentUser data: ${currentUserAsync.value?.displayName ?? 'null'} (${currentUserAsync.value?.uid ?? 'no uid'})');
    }
    debugPrint('couple: isLoading=${coupleAsync.isLoading}, hasValue=${coupleAsync.hasValue}, hasError=${coupleAsync.hasError}');
    debugPrint('partner: isLoading=${partnerAsync.isLoading}, hasValue=${partnerAsync.hasValue}, hasError=${partnerAsync.hasError}');
    if (partnerAsync.hasValue) {
      debugPrint('partner data: ${partnerAsync.value?.displayName ?? 'null'} (${partnerAsync.value?.uid ?? 'no uid'})');
    }
    if (partnerAsync.hasError) {
      debugPrint('partner error: ${partnerAsync.error}');
    }
    debugPrint('========================');

    // 3. Logika pro přesměrování (pokud není spárován)
    if (isPairedAsync.hasValue && isPairedAsync.value == false) {
       return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    // --- OPRAVA: Čekání na klíčová data ---
    // Pokud se načítá uživatel NEBO pár, zobrazíme loading celé obrazovky.
    // Tím zajistíme, že zbytek kódu už bude mít data k dispozici.
    if (currentUserAsync.isLoading || coupleAsync.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.colors.background,
        body: const Center( 
          child: CircularProgressIndicator(), 
        ),
      );

    }
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        backgroundColor: AppTheme.colors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              PhosphorIconsBold.gear,
              color: AppTheme.colors.text,
            ),
            onPressed: () {
              context.push('/settings');
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.text,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Widgety pro váš život',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: _StatusHeader(
                  coupleAsync: coupleAsync,
                  partnerAsync: partnerAsync,
                  currentUserAsync: currentUserAsync,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final crossAxisCount = isWide ? 3 : 2;
                    return MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: AppSpacing.lg,
                      crossAxisSpacing: AppSpacing.lg,
                      itemCount: _cards.length,
                      itemBuilder: (context, index) => _cards[index],
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
}

final _cards = <Widget>[  
  const _DaysTogetherCard(),
  const _CountdownCard(),
  const _QuickNoteCard(),
  const _IntimacySparkCard(),
  const _AnalyticsCard(),
];

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({
    required this.coupleAsync,
    required this.partnerAsync,
    required this.currentUserAsync,
  });

  final AsyncValue<CoupleModel?> coupleAsync;
  final AsyncValue<UserModel?> partnerAsync;
  final AsyncValue<UserModel?> currentUserAsync;

  @override
  Widget build(BuildContext context) {
    return coupleAsync.when(
      data: (couple) {
        if (couple == null) {
          // Not paired yet - show placeholder
          return BentoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: Text(
                'Spárujte se s partnerem pro zobrazení statusu',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Get current user and partner data
        return currentUserAsync.when(
          data: (currentUser) {
            final currentUserId = currentUser?.uid ?? '';
            
            // Get current user's status from couple document
            final currentUserStatus = (currentUserId.isNotEmpty && couple.status != null)
                ? couple.status![currentUserId]
                : null;
            
            // Get partner's status
            return partnerAsync.when(
              data: (partner) {
                final partnerStatus = (partner != null && partner.uid.isNotEmpty && couple.status != null)
                    ? couple.status![partner.uid]
                    : null;
                
                // Debug: print both names to see what we have
                debugPrint('Current user: ${currentUser?.displayName ?? 'null'} (${currentUser?.uid ?? 'no uid'})');
                debugPrint('Partner: ${partner?.displayName ?? 'null'} (${partner?.uid ?? 'no uid'})');
                debugPrint('Couple members: ${couple.members}');
                
                return BentoCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AvatarStatus(
                          name: currentUser?.displayName ?? 'You',
                          emoji: currentUserStatus?.emoji ?? '😊',
                          status: currentUserStatus?.text ?? 'Ready',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.colors.textSecondary.withOpacity(0.1),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _AvatarStatus(
                          name: partner?.displayName ?? 'Partner',
                          emoji: partnerStatus?.emoji ?? '😊',
                          status: partnerStatus?.text ?? 'Ready',
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => BentoCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: _AvatarStatus(
                        name: currentUser?.displayName ?? 'You',
                        emoji: currentUserStatus?.emoji ?? '😊',
                        status: currentUserStatus?.text ?? 'Ready',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.colors.textSecondary.withOpacity(0.1),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: _AvatarStatus(
                        name: 'Partner',
                        emoji: '😊',
                        status: 'Loading...',
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, stackTrace) {
                debugPrint('Partner error: $error');
                debugPrint('Stack trace: $stackTrace');
                return BentoCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AvatarStatus(
                          name: currentUser?.displayName ?? 'You',
                          emoji: currentUserStatus?.emoji ?? '😊',
                          status: currentUserStatus?.text ?? 'Ready',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.colors.textSecondary.withOpacity(0.1),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: _AvatarStatus(
                          name: 'Partner',
                          emoji: '😊',
                          status: 'Error',
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => BentoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => BentoCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: const _AvatarStatus(
              name: 'You',
              emoji: '😊',
              status: 'Error',
            ),
          ),
        );
      },
      loading: () => BentoCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => BentoCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const _AvatarStatus(
          name: 'You',
          emoji: '😊',
          status: 'Ready',
        ),
      ),
    );
  }
}

class _AvatarStatus extends StatelessWidget {
  const _AvatarStatus({
    required this.name,
    required this.emoji,
    required this.status,
  });

  final String name;
  final String emoji;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.colors.background,
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.colors.text,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.colors.textSecondary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DaysTogetherCard extends ConsumerWidget {
  const _DaysTogetherCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleAsync = ref.watch(currentCoupleProvider);
    
    return coupleAsync.when(
      data: (couple) {
        if (couple?.anniversaryDate == null) {
          return BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Days Together',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '0',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.colors.text,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Set your anniversary date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }
        
        final daysTogether = DateTime.now().difference(couple!.anniversaryDate!).inDays;
        
        return BentoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Days Together',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$daysTogether',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.colors.text,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Stronger every day.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
      loading: () => BentoCard(
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Days Together',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '0',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.colors.text,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard();

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next event',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '14 days',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.colors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Anniversary dinner',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.colors.text,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickNoteCard extends ConsumerWidget {
  const _QuickNoteCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestNoteAsync = ref.watch(latestSharedNoteProvider);
    
    return latestNoteAsync.when(
      data: (note) {
        return QuickNoteCard(
          content: note?.content ?? '',
          onTap: () {
            context.push('/add-note');
          },
        );
      },
      loading: () => const QuickNoteCard(
        content: '',
      ),
      error: (error, stackTrace) {
        debugPrint('Error loading latest note: $error');
        debugPrint('Stack trace: $stackTrace');
        return QuickNoteCard(
          content: '',
          onTap: () {
            context.push('/add-note');
          },
        );
      },
    );
  }
}

class _IntimacySparkCard extends StatelessWidget {
  const _IntimacySparkCard();

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.colors.love.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: AppTheme.colors.love,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               const SizedBox(height: AppSpacing.xs),
                Text(
                  'Last sync: 2 days ago 🔥',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.colors.text,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),               
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard();

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DYOS Analytics',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _Chip(
                  label: 'Peak day',
                  value: 'Tuesday',
                  color: AppTheme.colors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Chip(
                  label: 'Mood',
                  value: 'Stay gentle 💚',
                  color: AppTheme.colors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: 0.72,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: AppTheme.colors.background,
            color: AppTheme.colors.primary,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '72% aligned',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.colors.text,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
