import '../domain/blueprint_question.dart';

/// One Blueprint section (category) with title, emoji, and questions.
class BlueprintSection {
  const BlueprintSection({
    required this.id,
    required this.title,
    required this.emoji,
    required this.questions,
  });
  final String id;
  final String title;
  final String emoji;
  final List<BlueprintQuestion> questions;
}

/// Mock Blueprint sections for development and demo.
class BlueprintMockData {
  BlueprintMockData._();

  /// "Travel Config" category: Pace, Transport, Budget, Morning Person.
  static const String travelConfigSectionTitle = 'Travel Config';
  static const String travelConfigSectionEmoji = '✈️';

  static List<BlueprintSection> get allSections => [
        BlueprintSection(
          id: 'travel',
          title: travelConfigSectionTitle,
          emoji: travelConfigSectionEmoji,
          questions: travelConfigQuestions,
        ),
        BlueprintSection(
          id: 'gift',
          title: 'Gift Protocol',
          emoji: '🎁',
          questions: giftProtocolQuestions,
        ),
        BlueprintSection(
          id: 'food',
          title: 'Food Preferences',
          emoji: '🍽️',
          questions: foodPreferencesQuestions,
        ),
      ];

  static BlueprintSection? sectionById(String id) {
    try {
      return allSections.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<BlueprintQuestion> get travelConfigQuestions => [
        const BlueprintQuestion(
          id: 'travel_pace',
          title: 'Pace',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Relax',
          sliderRightLabel: 'Adventure',
        ),
        const BlueprintQuestion(
          id: 'travel_transport',
          title: 'Transport',
          type: BlueprintQuestionType.choiceChips,
          options: ['Plane', 'Car', 'Train'],
        ),
        const BlueprintQuestion(
          id: 'travel_budget',
          title: 'Budget Priority',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Food',
          sliderRightLabel: 'Accommodation',
        ),
        const BlueprintQuestion(
          id: 'travel_morning',
          title: 'Morning Person?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get giftProtocolQuestions => [
        const BlueprintQuestion(
          id: 'gift_style',
          title: 'Preferred style',
          type: BlueprintQuestionType.choiceChips,
          options: ['Silver', 'Gold', 'Rose Gold', 'No preference'],
        ),
        const BlueprintQuestion(
          id: 'gift_occasion',
          title: 'Important occasions',
          type: BlueprintQuestionType.multiSelect,
          options: ['Birthday', 'Anniversary', 'Christmas', 'Just because'],
        ),
      ];

  static List<BlueprintQuestion> get foodPreferencesQuestions => [
        const BlueprintQuestion(
          id: 'food_allergies',
          title: 'Allergies or avoid',
          type: BlueprintQuestionType.multiSelect,
          options: ['Nuts', 'Dairy', 'Gluten', 'Shellfish', 'None'],
        ),
        const BlueprintQuestion(
          id: 'food_favorite',
          title: 'Favorite cuisine',
          type: BlueprintQuestionType.choiceChips,
          options: ['Italian', 'Asian', 'Mexican', 'Home cooking', 'Mixed'],
        ),
      ];
}
