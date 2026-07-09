import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../auth/domain/couple_model.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../gamification/presentation/user_stats_provider.dart';
import '../../data/blueprint_mock_data.dart';
import '../../domain/blueprint_question.dart';
import '../widgets/blueprint_question_card.dart';

/// Renders a Blueprint (preference questionnaire) section with dynamic questions.
/// When [sectionId] is set, answers are loaded/saved from Firestore and partner's answer is shown.
/// XP for completing is awarded only once per section per couple.
class BlueprintDetailScreen extends ConsumerStatefulWidget {
  const BlueprintDetailScreen({
    super.key,
    required this.sectionTitle,
    required this.sectionEmoji,
    required this.questions,
    this.sectionId,
    this.onSectionComplete,
  });

  final String sectionTitle;
  final String sectionEmoji;
  final List<BlueprintQuestion> questions;
  /// If set, answers are persisted and partner's answers shown. XP given only once per section.
  final String? sectionId;
  final VoidCallback? onSectionComplete;

  @override
  ConsumerState<BlueprintDetailScreen> createState() => _BlueprintDetailScreenState();
}

class _BlueprintDetailScreenState extends ConsumerState<BlueprintDetailScreen> {
  final Map<String, dynamic> _answers = {};
  bool _initialLoadDone = false;

  int get _answeredCount {
    var count = 0;
    for (final q in widget.questions) {
      final v = _answers[q.id];
      if (q.type == BlueprintQuestionType.multiSelect) {
        if (v is List && v.isNotEmpty) count++;
      } else if (v != null) {
        count++;
      }
    }
    return count;
  }

  double get _progress =>
      widget.questions.isEmpty ? 1.0 : _answeredCount / widget.questions.length;

  Map<String, dynamic>? _partnerAnswersForSection(CoupleModel? couple, String? currentUserId) {
    if (couple?.blueprintAnswers == null || widget.sectionId == null || currentUserId == null) return null;
    final bySection = couple!.blueprintAnswers![widget.sectionId!];
    if (bySection is! Map) return null;
    final other = couple.members.where((id) => id != currentUserId).toList();
    final partnerId = other.isEmpty ? null : other.first;
    if (partnerId == null) return null;
    final partner = bySection[partnerId];
    if (partner is! Map<String, dynamic>) return null;
    return Map<String, dynamic>.from(partner);
  }

  void _loadInitialAnswers(CoupleModel? couple, String? userId) {
    if (widget.sectionId == null || userId == null || _initialLoadDone) return;
    if (couple == null) return;
    _initialLoadDone = true;
    final bySection = couple.blueprintAnswers?[widget.sectionId!];
    if (bySection is Map) {
      final my = bySection[userId];
      if (my is Map<String, dynamic>) {
        setState(() => _answers.addAll(Map<String, dynamic>.from(my)));
      }
    }
  }

  Future<void> _onCompleteSection() async {
    final user = ref.read(currentUserDataProvider).valueOrNull;
    final coupleId = user?.coupleId;
    final sectionId = widget.sectionId;

    if (sectionId != null && coupleId != null) {
      final firebase = ref.read(firebaseServiceProvider);
      final serialized = _serializeAnswers(_answers);
      await firebase.saveBlueprintAnswers(
        coupleId: coupleId,
        sectionId: sectionId,
        userId: user!.uid,
        answers: serialized,
      );
      final xpGranted = await grantQuestXpIfEligible(
          ref, 'blueprint_$sectionId', 100);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              xpGranted
                  ? 'System Updated: +100 XP acquired! 🚀'
                  : 'Section saved. (XP already earned today.)',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Section complete!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
    widget.onSectionComplete?.call();
  }

  Map<String, dynamic> _serializeAnswers(Map<String, dynamic> answers) {
    final out = <String, dynamic>{};
    for (final e in answers.entries) {
      final v = e.value;
      if (v == null) continue;
      if (v is List) {
        out[e.key] = v.map((x) => x.toString()).toList();
      } else if (v is num || v is bool || v is String) {
        out[e.key] = v;
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    final total = widget.questions.length;
    final couple = ref.watch(coupleProvider).valueOrNull;
    final currentUserId = ref.watch(currentUserDataProvider).valueOrNull?.uid;
    _loadInitialAnswers(couple, currentUserId);
    final partnerAnswers = _partnerAnswersForSection(couple, currentUserId);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.text,
        elevation: 0,
        title: Text(
          '${widget.sectionTitle} ${widget.sectionEmoji}',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: c.text,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${widget.sectionTitle} ${widget.sectionEmoji}',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _progress,
                              minHeight: 8,
                              backgroundColor: c.background,
                              valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '$_answeredCount / $total',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: c.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final q = widget.questions[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.md,
                    ),
                    child: BlueprintQuestionCard(
                      question: q,
                      value: _answers[q.id],
                      onChanged: (v) => setState(() => _answers[q.id] = v),
                      partnerValue: partnerAnswers?[q.id],
                    ),
                  );
                },
                childCount: widget.questions.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: FilledButton(
                  onPressed: _onCompleteSection,
                  style: FilledButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Complete Section',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

/// Convenience screen for "Travel Config" using mock data.
class TravelConfigBlueprintScreen extends StatelessWidget {
  const TravelConfigBlueprintScreen({super.key, this.onSectionComplete});

  final VoidCallback? onSectionComplete;

  @override
  Widget build(BuildContext context) {
    return BlueprintDetailScreen(
      sectionTitle: BlueprintMockData.travelConfigSectionTitle,
      sectionEmoji: BlueprintMockData.travelConfigSectionEmoji,
      questions: BlueprintMockData.travelConfigQuestions,
      sectionId: 'travel',
      onSectionComplete: onSectionComplete,
    );
  }
}
