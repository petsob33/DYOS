/// DYOS+ subscription copy: benefits, pricing hints, and footer note.
/// Actual prices come from RevenueCat/store; these are display hints (CZK / USD).

class PremiumCopy {
  PremiumCopy._();

  /// Display price for monthly (when store price not available).
  static const String monthlyPrice = '79 Kč / month';

  /// Display price for yearly (when store price not available).
  static const String yearlyPrice = '599 Kč / year';

  /// Yearly savings note (e.g. "2 months free").
  static const String yearlySavings = '2 months free';

  /// Instant unlock benefits (same on landing and paywall).
  static const List<(String, String)> instantBenefits = [
    (
      'Memory Map',
      'See every memory you made together on the map',
    ),
    (
      'Unlimited Memories',
      'No 30-memory limit – keep your whole story',
    ),
    (
      'One plan for both of you',
      'One purchase unlocks DYOS+ for you and your partner',
    ),
    (
      'Priority Support',
      'Priority bug fixes and support',
    ),
  ];

  /// Footer note: with Premium users still collect SP for cosmetics and Lifetime.
  static const String footerNoteWithRoadmap =
      'With DYOS+ you still collect SP on the Roadmap for cosmetic rewards (badges, icons).';
}
