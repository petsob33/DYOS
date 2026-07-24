import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../domain/premium_copy.dart';
import '../premium_provider.dart';

/// Premium / DYOS+ screen: same colors as app, Bento style, focused on purchase.
class PremiumLandingScreen extends ConsumerStatefulWidget {
  const PremiumLandingScreen({super.key});

  @override
  ConsumerState<PremiumLandingScreen> createState() =>
      _PremiumLandingScreenState();
}

class _PremiumLandingScreenState extends ConsumerState<PremiumLandingScreen> {
  Offerings? _offerings;
  bool _loadingOfferings = true;
  Object? _offeringsError;
  Package? _selectedPackage;
  Package? _purchasingPackage;
  bool _restoring = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOfferings());
  }

  Future<void> _loadOfferings() async {
    if (!mounted) return;
    setState(() {
      _loadingOfferings = true;
      _offeringsError = null;
      _offerings = null;
    });
    try {
      final service = ref.read(purchaseServiceProvider);
      final offerings = await service.getOfferings();
      if (mounted) {
        final offering = offerings.current;
        Package? defaultSelection;
        if (offering?.annual != null) {
          defaultSelection = offering!.annual;
        } else if (offering?.monthly != null) {
          defaultSelection = offering!.monthly;
        }
        setState(() {
          _offerings = offerings;
          _loadingOfferings = false;
          _selectedPackage = defaultSelection;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _offeringsError = e;
          _loadingOfferings = false;
        });
      }
    }
  }

  Future<void> _purchase(Package? package) async {
    if (package == null) return;
    setState(() {
      _purchasingPackage = package;
      _errorMessage = null;
    });
    try {
      final service = ref.read(purchaseServiceProvider);
      await service.purchaseProduct(package.storeProduct);
      if (mounted) setState(() => _purchasingPackage = null);
    } catch (e) {
      if (mounted) {
        setState(() {
          _purchasingPackage = null;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _restore() async {
    setState(() {
      _restoring = true;
      _errorMessage = null;
    });
    try {
      final service = ref.read(purchaseServiceProvider);
      await service.restorePurchases();
      if (mounted) setState(() => _restoring = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _restoring = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _openLegalUrl(String path) async {
    final uri = Uri.parse('https://dyos-520c2.web.app/$path');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;
    final c = context.colors;

    if (isPremium) {
      return Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          title: const Text('DYOS+'),
          leading: IconButton(
            icon: const Icon(PhosphorIconsBold.arrowLeft),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: BentoCard(
                background: c.primary.withValues(alpha: 0.08),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      PhosphorIconsBold.crown,
                      color: Color(0xFF5E5CE6),
                      size: 56,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'You have DYOS+',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'One subscription for both of you.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: c.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('DYOS+'),
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadOfferings,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    _buildHero(context, c),
                    const SizedBox(height: AppSpacing.xl),
                    _buildBenefitsCard(context, c),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Choose your plan',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_loadingOfferings)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xl,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(color: c.primary),
                        ),
                      )
                    else if (_offeringsError != null)
                      BentoCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Text(
                              'Could not load plans: $_offeringsError. Pull down to retry.',
                              style: GoogleFonts.inter(
                                color: c.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    else
                      _buildPlanCards(context, c),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(
                          color: c.love,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Cancel anytime. One subscription for both of you.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: c.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      PremiumCopy.footerNoteWithRoadmap,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: c.textSecondary,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
            _buildCtaSection(context, c),
          ],

        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppPalette c) {
    return BentoCard(
      background: c.primary.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIconsBold.sparkle,
                color: c.primary,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'DYOS+',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: c.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'More for the two of you',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: c.text,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Unlimited memories, insights, and no limits. One plan, both of you.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: c.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard(BuildContext context, AppPalette c) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instant benefits',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...PremiumCopy.instantBenefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: c.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      PhosphorIconsBold.lockKeyOpen,
                      size: 20,
                      color: c.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.$1,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: c.text,
                          ),
                        ),
                        Text(
                          b.$2,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    PhosphorIconsBold.checkCircle,
                    size: 20,
                    color: c.success,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCards(BuildContext context, AppPalette c) {
    final offering = _offerings?.current;
    if (offering == null) {
      return BentoCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'No plans available right now. Pull down to retry.',
            style: GoogleFonts.inter(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final annual = offering.annual;
    final monthly = offering.monthly;
    final packages = <Package>[];
    if (annual != null) packages.add(annual);
    if (monthly != null) packages.add(monthly);
    if (packages.isEmpty) {
      return BentoCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'No plans configured. Pull down to retry.',
            style: GoogleFonts.inter(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: packages.map((package) {
        final isYearly = package.packageType == PackageType.annual;
        final isSelected = _selectedPackage == package;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: BentoCard(
            onTap: () => setState(() => _selectedPackage = package),
            background: isSelected
                ? c.primary.withValues(alpha: 0.06)
                : null,
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? c.primary : c.textSecondary,
                      width: 2,
                    ),
                    color: isSelected ? c.primary : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          PhosphorIconsBold.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isYearly ? 'Yearly' : 'Monthly',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: c.text,
                            ),
                          ),
                          if (isYearly) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: c.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                PremiumCopy.yearlySavings,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: c.success,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        isYearly
                            ? 'Yearly billing'
                            : 'Monthly billing',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  package.storeProduct.priceString,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: c.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCtaSection(BuildContext context, AppPalette c) {
    final isPurchasing = _purchasingPackage != null;
    final canTap = !isPurchasing && _selectedPackage != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: c.background,
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: canTap ? () => _purchase(_selectedPackage) : null,
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: c.textSecondary.withValues(alpha: 0.3),
                elevation: canTap ? 4 : 0,
                shadowColor: c.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: isPurchasing
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Get DYOS+ now',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _footerLink('Restore', _restoring ? null : _restore, c),
              Text(
                ' · ',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: c.textSecondary,
                ),
              ),
              _footerLink(
                'Privacy',
                () => _openLegalUrl('privacy-policy.html'),
                c,
              ),
              Text(
                ' · ',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: c.textSecondary,
                ),
              ),
              _footerLink(
                'Terms',
                () => _openLegalUrl('terms-of-service.html'),
                c,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String label, VoidCallback? onTap, AppPalette c) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: c.textSecondary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
