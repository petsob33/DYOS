import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../models/note_item.dart';
import '../../../../models/notes_provider.dart';
import '../../../../widgets/home/quick_note_card.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../auth/domain/couple_model.dart';
import '../../../auth/domain/user_model.dart';
import '../../../events/presentation/add_event_sheet.dart';
import '../../../events/presentation/event_provider.dart';

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
        leading: currentUserAsync.when(
          data: (user) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  context.push('/profile');
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                  backgroundImage: user?.photoUrl != null
                      ? CachedNetworkImageProvider(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Icon(
                          PhosphorIconsBold.user,
                          size: 20,
                          color: AppTheme.colors.primary,
                        )
                      : null,
                ),
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(
                PhosphorIconsBold.user,
                color: AppTheme.colors.textSecondary,
              ),
              onPressed: () {
                context.push('/profile');
              },
            ),
          ),
        ),
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
                      'Widgets for your life',
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
  const _QuickNoteCard(),
  const _EventsCard(),
  const _ListsCard(),
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
                'Pair with your partner to view status',
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
                          photoUrl: currentUser?.photoUrl,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _AvatarStatus(
                          name: partner?.displayName ?? 'Partner',
                          emoji: partnerStatus?.emoji ?? '😊',
                          status: partnerStatus?.text ?? 'Ready',
                          photoUrl: partner?.photoUrl,
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
                      color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
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
                        color: AppTheme.colors.textSecondary.withValues(alpha: 0.1),
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
    this.photoUrl,
  });

  final String name;
  final String emoji;
  final String status;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.colors.background,
          backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
              ? CachedNetworkImageProvider(photoUrl!)
              : null,
          child: photoUrl == null || photoUrl!.isEmpty
              ? Text(emoji, style: const TextStyle(fontSize: 20))
              : null,
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

class _EventsCard extends ConsumerWidget {
  const _EventsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsStreamProvider);

    return eventsAsync.when(
      data: (events) {
        final upcomingEvents = events.where((event) {
          final today = DateTime.now();
          final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
          final todayDate = DateTime(today.year, today.month, today.day);
          return eventDate.isAfter(todayDate) || eventDate.isAtSameMomentAs(todayDate);
        }).toList();
        
        final totalCount = events.length;
        final upcomingCount = upcomingEvents.length;
        
        return BentoCard(
          child: InkWell(
            onTap: () {
              AddEventSheet.show(context);
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.colors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          PhosphorIconsBold.calendarPlus,
                          color: AppTheme.colors.primary,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        PhosphorIconsBold.plus,
                        color: AppTheme.colors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Add Event',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.colors.text,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Create a new event',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => BentoCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.colors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      PhosphorIconsBold.calendarPlus,
                      color: AppTheme.colors.primary,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    PhosphorIconsBold.plus,
                    color: AppTheme.colors.primary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Add Event',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.colors.text,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) {
        debugPrint('Error loading events: $error');
        return BentoCard(
          child: InkWell(
            onTap: () {
              AddEventSheet.show(context);
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.colors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          PhosphorIconsBold.calendarPlus,
                          color: AppTheme.colors.primary,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        PhosphorIconsBold.plus,
                        color: AppTheme.colors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Add Event',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.colors.text,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Create a new event',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ListsCard extends ConsumerWidget {
  const _ListsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketListNotesAsync = ref.watch(
      coupleNotesProvider(type: NoteType.bucketList),
    );

    return bucketListNotesAsync.when(
      data: (notes) {
        final totalCount = notes.length;
        final hasItems = totalCount > 0;
        
        return BentoCard(
          child: InkWell(
            onTap: () {
              context.push('/lists');
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.colors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          PhosphorIconsBold.listChecks,
                          color: AppTheme.colors.primary,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        PhosphorIconsBold.caretRight,
                        color: AppTheme.colors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Bucket List',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.colors.text,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (hasItems)
                    Text(
                      '$totalCount ${totalCount == 1 ? 'dream' : 'dreams'} to achieve',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                    )
                  else
                    Text(
                      'Start adding your dreams together',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => BentoCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.colors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      PhosphorIconsBold.listChecks,
                      color: AppTheme.colors.primary,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    PhosphorIconsBold.caretRight,
                    color: AppTheme.colors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Bucket List',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.colors.text,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) {
        debugPrint('Error loading lists: $error');
        return BentoCard(
          child: InkWell(
            onTap: () {
              context.push('/lists');
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.colors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          PhosphorIconsBold.listChecks,
                          color: AppTheme.colors.primary,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        PhosphorIconsBold.caretRight,
                        color: AppTheme.colors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Bucket List',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.colors.text,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tap to open',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


