import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';

class MemoryScreen extends StatelessWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsBold.mapPin),
            onPressed: () {
              // TODO: Navigate to map view
            },
            tooltip: 'Map view',
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChips(),
          Expanded(child: _TimelineFeed()),
        ],
      ),
    );
  }
}

class _FilterChips extends StatefulWidget {
  @override
  State<_FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<_FilterChips> {
  int _selectedIndex = 0;

  final _filters = ['All', 'Date Nights', 'Trips', 'Milestones'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            _filters.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                right: index < _filters.length - 1 ? AppSpacing.sm : 0,
              ),
              child: FilterChip(
                label: Text(_filters[index]),
                selected: _selectedIndex == index,
                onSelected: (selected) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                selectedColor: AppTheme.colors.primary.withOpacity(0.12),
                checkmarkColor: AppTheme.colors.primary,
                labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _selectedIndex == index
                      ? AppTheme.colors.primary
                      : AppTheme.colors.text,
                  fontWeight: _selectedIndex == index
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
                backgroundColor: AppTheme.colors.card,
                side: BorderSide(
                  color: _selectedIndex == index
                      ? AppTheme.colors.primary
                      : AppTheme.colors.textSecondary.withOpacity(0.2),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder feed until timeline is wired to Firestore.
const _mockMemories = <MemoryItem>[
  MemoryItem(
    caption: 'First date night',
    date: 'Feb 14, 2024',
    monthYear: 'February 2024',
    location: 'Downtown',
    tags: ['Date Nights'],
  ),
  MemoryItem(
    caption: 'Weekend trip',
    date: 'Mar 2, 2024',
    monthYear: 'March 2024',
    location: 'Mountains',
    tags: ['Trips'],
  ),
  MemoryItem(
    caption: 'One year together',
    date: 'Jan 10, 2024',
    monthYear: 'January 2024',
    tags: ['Milestones'],
  ),
];

class _TimelineFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Group memories by month
    final groupedMemories = <String, List<MemoryItem>>{};
    for (final memory in _mockMemories) {
      final monthKey = memory.monthYear;
      groupedMemories.putIfAbsent(monthKey, () => []).add(memory);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: groupedMemories.length,
      itemBuilder: (context, index) {
        final monthKey = groupedMemories.keys.elementAt(index);
        final memories = groupedMemories[monthKey]!;
        
        return _TimelineMonthSection(
          month: monthKey,
          memories: memories,
        );
      },
    );
  }
}

class _TimelineMonthSection extends StatelessWidget {
  const _TimelineMonthSection({
    required this.month,
    required this.memories,
  });

  final String month;
  final List<MemoryItem> memories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(
            month,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.colors.text,
            ),
          ),
        ),
        ...memories.map((memory) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: _TimelineMemoryCard(memory: memory),
        )),
      ],
    );
  }
}

class _TimelineMemoryCard extends StatelessWidget {
  const _TimelineMemoryCard({required this.memory});

  final MemoryItem memory;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: EdgeInsets.zero,
      onTap: () {
        // TODO: Navigate to memory detail
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Caption (title) above image
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Text(
              memory.caption,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.colors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Image placeholder
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: AppTheme.colors.textSecondary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    PhosphorIconsBold.image,
                    size: 64,
                    color: AppTheme.colors.textSecondary.withOpacity(0.4),
                  ),
                ),
                if (memory.location != null)
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.card.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsBold.mapPin,
                            size: 14,
                            color: AppTheme.colors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            memory.location!,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppTheme.colors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                // Date
                Text(
                  memory.date,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Tags
                if (memory.tags.isNotEmpty)
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: memory.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTagColor(tag).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: _getTagColor(tag),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'date':
      case 'date nights':
        return AppTheme.colors.love;
      case 'trip':
      case 'trips':
        return AppTheme.colors.primary;
      case 'milestone':
        return AppTheme.colors.warning;
      default:
        return AppTheme.colors.textSecondary;
    }
  }
}

class MemoryItem {
  const MemoryItem({
    required this.caption,
    required this.date,
    required this.monthYear,
    this.location,
    this.tags = const [],
  });

  final String caption;
  final String date;
  final String monthYear;
  final String? location;
  final List<String> tags;
}

