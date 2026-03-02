/// DYOS+ subscription copy: benefits, pricing hints, and footer note.
/// Actual prices come from RevenueCat/store; these are display hints (CZK / USD).

class PremiumCopy {
  PremiumCopy._();

  /// Display price for monthly (when store price not available).
  static const String monthlyPrice = '99 Kč / \$4.99';

  /// Display price for yearly (when store price not available).
  static const String yearlyPrice = '890 Kč / \$39.99';

  /// Yearly savings note (e.g. "2 měsíce zdarma").
  static const String yearlySavings = '2 měsíce zdarma';

  /// Instant unlock benefits (same on landing and paywall).
  static const List<(String, String)> instantBenefits = [
    (
      'Odemkne VŠECHNY funkční bloky z Roadmapy ihned',
      'Mapy, Blueprints, Taptic',
    ),
    (
      'Unlimited History',
      'Celá historie fotek a chatu navždy',
    ),
    (
      'Priority Support',
      'Přednostní řešení bugů',
    ),
  ];

  /// Footer note: with Premium users still collect SP for cosmetics and Lifetime.
  static const String footerNoteWithRoadmap =
      'I s Premium účtem stále sbíráte body na Roadmapě pro kosmetické odměny (odznaky, ikony) a pro finální cíl – Lifetime účtu.';
}
