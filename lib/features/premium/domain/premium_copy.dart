/// DYOS+ subscription copy: benefits, pricing hints, and footer note.
/// Actual prices come from RevenueCat/store; these are display hints (CZK / USD).

class PremiumCopy {
  PremiumCopy._();

  /// Display price for monthly (when store price not available).
  static const String monthlyPrice = '\$4.99 / month';

  /// Display price for yearly (when store price not available).
  static const String yearlyPrice = '\$39.99 / year';

  /// Yearly savings note (e.g. "2 months free").
  static const String yearlySavings = '2 months free';

  /// Instant unlock benefits (same on landing and paywall).
  static const List<(String, String)> instantBenefits = [
    (
      'Unlocks ALL functional blocks from the Roadmap instantly',
      'Maps, Daily Questions, Taptic',
    ),
    (
      'Unlimited History',
      'Your full photo and chat history forever',
    ),
    (
      'Priority Support',
      'Priority bug fixes and support',
    ),
  ];

  /// Footer note: with Premium users still collect SP for cosmetics and Lifetime.
  static const String footerNoteWithRoadmap =
      'Even with a Premium account you still collect SP on the Roadmap for cosmetic rewards (badges, icons) and the final goal – Lifetime account.';
}
