import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../domain/premium_copy.dart';
import '../premium_provider.dart';

/// Dark-mode paywall colors (Bento style).
class _PaywallColors {
  static const Color background = Color(0xFF1C1C1E);
  static const Color border = Color(0xFF3A3A3C);
  static const Color cardBackground = Color(0xFF2C2C2E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color primary = Color(0xFF5E5CE6);
}

/// Paywall modal: header, 3 benefits, 2 pricing cards (Monthly/Yearly).
/// Fetches offerings from RevenueCat; on purchase success syncs to Firestore so both partners get premium.
class PaywallModal extends ConsumerStatefulWidget {
  const PaywallModal({super.key, this.scrollController});

  /// Opens the paywall as a modal (bottom sheet).
  static Future<void> show(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 1,
        builder: (context, scrollController) => PaywallModal(
          scrollController: scrollController,
        ),
      ),
    );
  }

  final ScrollController? scrollController;

  @override
  ConsumerState<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallModalState extends ConsumerState<PaywallModal> {
  Offerings? _offerings;
  Object? _offeringsError;
  bool _loadingOfferings = true;
  bool _loadStarted = false;
  bool _purchasing = false;
  bool _restoring = false;
  String? _errorMessage;

  Future<void> _loadOfferings() async {
    setState(() {
      _loadingOfferings = true;
      _offeringsError = null;
      _offerings = null;
    });
    try {
      final service = ref.read(purchaseServiceProvider);
      final offerings = await service.getOfferings();
      if (mounted) {
        setState(() {
          _offerings = offerings;
          _loadingOfferings = false;
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

  Future<void> _purchase(Package package) async {
    setState(() {
      _purchasing = true;
      _errorMessage = null;
    });
    try {
      final service = ref.read(purchaseServiceProvider);
      await service.purchaseProduct(package.storeProduct);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _purchasing = false;
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
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _restoring = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadStarted) {
      _loadStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadOfferings());
    }
    return Container(
      decoration: const BoxDecoration(
        color: _PaywallColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _PaywallColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: ListView(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildBenefits(),
                  const SizedBox(height: AppSpacing.xl),
                  if (_loadingOfferings)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_offeringsError != null)
                    _buildOfferingsError()
                  else
                    _buildPricingCards(),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _errorMessage!,
                      style: GoogleFonts.inter(
                        color: Colors.red.shade300,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _buildRestoreButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      context.l10n.paywallModalTitle,
      style: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: _PaywallColors.textPrimary,
      ),
    );
  }

  Widget _buildBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: PremiumCopy.instantBenefits
          .map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: _PaywallColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _PaywallColors.border),
                    ),
                    child: Icon(
                      PhosphorIconsRegular.lockKeyOpen,
                      color: _PaywallColors.primary,
                      size: 24,
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
                            color: _PaywallColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          b.$2,
                          style: GoogleFonts.inter(
                            color: _PaywallColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildOfferingsError() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Text(
        context.l10n.paywallModalLoadError,
        style: GoogleFonts.inter(color: _PaywallColors.textSecondary),
      ),
    );
  }

  Widget _buildPricingCards() {
    final offering = _offerings?.current;
    if (offering == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          context.l10n.paywallModalNoPlansAvailable,
          style: GoogleFonts.inter(color: _PaywallColors.textSecondary),
        ),
      );
    }

    final monthly = offering.monthly;
    final annual = offering.annual;
    final packages = <Package>[];
    if (monthly != null) packages.add(monthly);
    if (annual != null) packages.add(annual);
    if (packages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          context.l10n.paywallModalNoPlansAvailable,
          style: GoogleFonts.inter(color: _PaywallColors.textSecondary),
        ),
      );
    }

    return Column(
      children: packages.map((package) {
        final isYearly = package.packageType == PackageType.annual;
        final title = isYearly ? context.l10n.paywallModalYearly : context.l10n.paywallModalMonthly;
        final subtitle = isYearly ? PremiumCopy.yearlySavings : context.l10n.paywallModalMonthlyBilling;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _purchasing
                  ? null
                  : () => _purchase(package),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: _PaywallColors.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isYearly
                        ? _PaywallColors.primary
                        : _PaywallColors.border,
                    width: isYearly ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              color: _PaywallColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              color: _PaywallColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      package.storeProduct.priceString,
                      style: GoogleFonts.inter(
                        color: _PaywallColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: _restoring ? null : _restore,
      child: _restoring
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              context.l10n.paywallModalRestorePurchases,
              style: GoogleFonts.inter(color: _PaywallColors.textSecondary),
            ),
    );
  }
}
