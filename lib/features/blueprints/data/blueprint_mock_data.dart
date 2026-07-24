import '../domain/blueprint_question.dart';
import '../domain/blueprint_section.dart';

/// Blueprint section content: the seed source for the `blueprint_sections`
/// Firestore collection (see `scripts/seed_blueprint_sections.js`) and the
/// offline/pre-seed fallback used by [blueprintSectionsProvider] and
/// [blueprintSectionProvider] when Firestore has no data yet.
class BlueprintMockData {
  BlueprintMockData._();

  /// "Travel Config" category: Pace, Transport, Budget, Morning Person.
  static const String travelConfigSectionTitle = 'Travel Config';
  static const String travelConfigSectionEmoji = '✈️';

  static List<BlueprintSection> get allSections {
    final sections = <BlueprintSection>[
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
        BlueprintSection(
          id: 'date_night',
          title: 'Date Night',
          emoji: '🌙',
          questions: dateNightQuestions,
        ),
        BlueprintSection(
          id: 'weekend',
          title: 'Weekend Style',
          emoji: '📅',
          questions: weekendQuestions,
        ),
        BlueprintSection(
          id: 'music',
          title: 'Music & Playlists',
          emoji: '🎵',
          questions: musicQuestions,
        ),
        BlueprintSection(
          id: 'movies',
          title: 'Movies & Series',
          emoji: '🎬',
          questions: moviesQuestions,
        ),
        BlueprintSection(
          id: 'fitness',
          title: 'Fitness & Health',
          emoji: '💪',
          questions: fitnessQuestions,
        ),
        BlueprintSection(
          id: 'home',
          title: 'Home & Living',
          emoji: '🏠',
          questions: homeQuestions,
        ),
        BlueprintSection(
          id: 'pets',
          title: 'Pets',
          emoji: '🐾',
          questions: petsQuestions,
        ),
        BlueprintSection(
          id: 'family',
          title: 'Family & Kids',
          emoji: '👨‍👩‍👧',
          questions: familyQuestions,
        ),
        BlueprintSection(
          id: 'money',
          title: 'Money & Spending',
          emoji: '💰',
          questions: moneyQuestions,
        ),
        BlueprintSection(
          id: 'communication',
          title: 'Communication Style',
          emoji: '💬',
          questions: communicationQuestions,
        ),
        BlueprintSection(
          id: 'conflict',
          title: 'Conflict Resolution',
          emoji: '🤝',
          questions: conflictQuestions,
        ),
        BlueprintSection(
          id: 'intimacy',
          title: 'Intimacy & Affection',
          emoji: '💕',
          questions: intimacyQuestions,
        ),
        BlueprintSection(
          id: 'social',
          title: 'Social Life',
          emoji: '🎉',
          questions: socialQuestions,
        ),
        BlueprintSection(
          id: 'morning',
          title: 'Morning Routine',
          emoji: '☀️',
          questions: morningQuestions,
        ),
        BlueprintSection(
          id: 'sleep',
          title: 'Sleep Habits',
          emoji: '😴',
          questions: sleepQuestions,
        ),
        BlueprintSection(
          id: 'holidays',
          title: 'Holidays & Celebrations',
          emoji: '🎄',
          questions: holidaysQuestions,
        ),
        BlueprintSection(
          id: 'chores',
          title: 'Chores & Household',
          emoji: '🧹',
          questions: choresQuestions,
        ),
        BlueprintSection(
          id: 'tech',
          title: 'Tech & Screens',
          emoji: '📱',
          questions: techQuestions,
        ),
        BlueprintSection(
          id: 'future',
          title: 'Future Plans',
          emoji: '🔮',
          questions: futureQuestions,
        ),
        BlueprintSection(
          id: 'values',
          title: 'Values & Priorities',
          emoji: '⭐',
          questions: valuesQuestions,
        ),
        BlueprintSection(
          id: 'adventure',
          title: 'Adventure & Risk',
          emoji: '🏔️',
          questions: adventureQuestions,
        ),
        BlueprintSection(
          id: 'quality_time',
          title: 'Quality Time',
          emoji: '⏰',
          questions: qualityTimeQuestions,
        ),
        BlueprintSection(
          id: 'humor',
          title: 'Humor & Fun',
          emoji: '😂',
          questions: humorQuestions,
        ),
    ];
    return [
      for (var i = 0; i < sections.length; i++) sections[i].copyWith(order: i),
    ];
  }

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

  static List<BlueprintQuestion> get dateNightQuestions => [
        const BlueprintQuestion(
          id: 'date_frequency',
          title: 'Ideal date night frequency',
          type: BlueprintQuestionType.choiceChips,
          options: ['Weekly', 'Twice a month', 'Monthly', 'Whenever we feel like it'],
        ),
        const BlueprintQuestion(
          id: 'date_style',
          title: 'Preferred date style',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Cozy at home',
          sliderRightLabel: 'Out and about',
        ),
        const BlueprintQuestion(
          id: 'date_activities',
          title: 'Favorite date activities',
          type: BlueprintQuestionType.multiSelect,
          options: ['Dinner out', 'Movie', 'Walk', 'Cooking together', 'Games', 'Concert', 'Sport'],
        ),
      ];

  static List<BlueprintQuestion> get weekendQuestions => [
        const BlueprintQuestion(
          id: 'weekend_energy',
          title: 'Weekend energy level',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Rest & recharge',
          sliderRightLabel: 'Go go go',
        ),
        const BlueprintQuestion(
          id: 'weekend_social',
          title: 'Prefer weekends with',
          type: BlueprintQuestionType.choiceChips,
          options: ['Just us two', 'Friends', 'Family', 'Mix of both'],
        ),
        const BlueprintQuestion(
          id: 'weekend_planning',
          title: 'Plan weekends in advance?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get musicQuestions => [
        const BlueprintQuestion(
          id: 'music_genres',
          title: 'Favorite genres',
          type: BlueprintQuestionType.multiSelect,
          options: ['Pop', 'Rock', 'Electronic', 'Jazz', 'Classical', 'Hip-hop', 'Indie', 'Country'],
        ),
        const BlueprintQuestion(
          id: 'music_mood',
          title: 'Music when together',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Background',
          sliderRightLabel: 'Main focus',
        ),
        const BlueprintQuestion(
          id: 'music_concerts',
          title: 'Love live concerts?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get moviesQuestions => [
        const BlueprintQuestion(
          id: 'movies_genres',
          title: 'Favorite movie genres',
          type: BlueprintQuestionType.multiSelect,
          options: ['Comedy', 'Drama', 'Action', 'Romance', 'Thriller', 'Sci-fi', 'Documentary', 'Horror'],
        ),
        const BlueprintQuestion(
          id: 'movies_vs_series',
          title: 'Prefer',
          type: BlueprintQuestionType.choiceChips,
          options: ['Movies', 'TV series', 'Both equally'],
        ),
        const BlueprintQuestion(
          id: 'movies_subtitles',
          title: 'Subtitles on?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get fitnessQuestions => [
        const BlueprintQuestion(
          id: 'fitness_level',
          title: 'Activity level',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Couch potato',
          sliderRightLabel: 'Gym every day',
        ),
        const BlueprintQuestion(
          id: 'fitness_activities',
          title: 'Preferred activities',
          type: BlueprintQuestionType.multiSelect,
          options: ['Running', 'Gym', 'Yoga', 'Swimming', 'Hiking', 'Cycling', 'Team sports', 'Home workout'],
        ),
        const BlueprintQuestion(
          id: 'fitness_together',
          title: 'Work out together?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get homeQuestions => [
        const BlueprintQuestion(
          id: 'home_temperature',
          title: 'Ideal room temperature',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Cool',
          sliderRightLabel: 'Warm',
        ),
        const BlueprintQuestion(
          id: 'home_tidiness',
          title: 'Tidiness preference',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Relaxed',
          sliderRightLabel: 'Everything in place',
        ),
        const BlueprintQuestion(
          id: 'home_decor',
          title: 'Decor style',
          type: BlueprintQuestionType.choiceChips,
          options: ['Minimal', 'Cozy', 'Modern', 'Vintage', 'Colorful', 'No strong preference'],
        ),
      ];

  static List<BlueprintQuestion> get petsQuestions => [
        const BlueprintQuestion(
          id: 'pets_have',
          title: 'Want pets?',
          type: BlueprintQuestionType.choiceChips,
          options: ['Yes, already have', 'Yes, in future', 'Maybe', 'No'],
        ),
        const BlueprintQuestion(
          id: 'pets_type',
          title: 'Preferred pets',
          type: BlueprintQuestionType.multiSelect,
          options: ['Dog', 'Cat', 'Small animal', 'Bird', 'Fish', 'Reptile', 'None'],
        ),
        const BlueprintQuestion(
          id: 'pets_bed',
          title: 'Pets in bed?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get familyQuestions => [
        const BlueprintQuestion(
          id: 'family_kids',
          title: 'Want kids?',
          type: BlueprintQuestionType.choiceChips,
          options: ['Yes', 'Maybe', 'No', 'Already have'],
        ),
        const BlueprintQuestion(
          id: 'family_timing',
          title: 'When (if yes)',
          type: BlueprintQuestionType.choiceChips,
          options: ['Soon', 'In a few years', 'No rush', 'Not sure'],
        ),
        const BlueprintQuestion(
          id: 'family_visits',
          title: 'Family visit frequency',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Rarely',
          sliderRightLabel: 'Very often',
        ),
      ];

  static List<BlueprintQuestion> get moneyQuestions => [
        const BlueprintQuestion(
          id: 'money_style',
          title: 'Spending style',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Saver',
          sliderRightLabel: 'Spender',
        ),
        const BlueprintQuestion(
          id: 'money_joint',
          title: 'Prefer joint finances?',
          type: BlueprintQuestionType.choiceChips,
          options: ['Fully joint', 'Partly joint', 'Separate', 'Not decided'],
        ),
        const BlueprintQuestion(
          id: 'money_big_purchases',
          title: 'Discuss big purchases together?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get communicationQuestions => [
        const BlueprintQuestion(
          id: 'comm_style',
          title: 'Communication style',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Need time to process',
          sliderRightLabel: 'Talk it out immediately',
        ),
        const BlueprintQuestion(
          id: 'comm_texts',
          title: 'Texting frequency when apart',
          type: BlueprintQuestionType.choiceChips,
          options: ['All day', 'A few times', 'Once in a while', 'Rarely'],
        ),
        const BlueprintQuestion(
          id: 'comm_affection',
          title: 'Express affection verbally?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get conflictQuestions => [
        const BlueprintQuestion(
          id: 'conflict_style',
          title: 'When we disagree I tend to',
          type: BlueprintQuestionType.choiceChips,
          options: ['Take space first', 'Talk it through', 'Compromise quickly', 'Need time to think'],
        ),
        const BlueprintQuestion(
          id: 'conflict_apology',
          title: 'Apologizing is',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Hard for me',
          sliderRightLabel: 'Easy for me',
        ),
        const BlueprintQuestion(
          id: 'conflict_cool_off',
          title: 'Prefer cool-off before talking?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get intimacyQuestions => [
        const BlueprintQuestion(
          id: 'intimacy_love_language',
          title: 'Primary love language',
          type: BlueprintQuestionType.choiceChips,
          options: ['Words', 'Touch', 'Gifts', 'Acts of service', 'Quality time'],
        ),
        const BlueprintQuestion(
          id: 'intimacy_affection',
          title: 'Public affection',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Keep it private',
          sliderRightLabel: 'No problem with PDA',
        ),
        const BlueprintQuestion(
          id: 'intimacy_touch',
          title: 'Physical touch importance',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Nice but not essential',
          sliderRightLabel: 'Very important',
        ),
      ];

  static List<BlueprintQuestion> get socialQuestions => [
        const BlueprintQuestion(
          id: 'social_frequency',
          title: 'Going out with friends',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Rarely',
          sliderRightLabel: 'All the time',
        ),
        const BlueprintQuestion(
          id: 'social_parties',
          title: 'Party person?',
          type: BlueprintQuestionType.switchType,
        ),
        const BlueprintQuestion(
          id: 'social_new_people',
          title: 'Meeting new people',
          type: BlueprintQuestionType.choiceChips,
          options: ['Love it', 'Okay sometimes', 'Prefer close circle', 'Draining'],
        ),
      ];

  static List<BlueprintQuestion> get morningQuestions => [
        const BlueprintQuestion(
          id: 'morning_person',
          title: 'Morning person?',
          type: BlueprintQuestionType.switchType,
        ),
        const BlueprintQuestion(
          id: 'morning_routine',
          title: 'Morning routine',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Roll out of bed',
          sliderRightLabel: 'Strict routine',
        ),
        const BlueprintQuestion(
          id: 'morning_breakfast',
          title: 'Breakfast together?',
          type: BlueprintQuestionType.choiceChips,
          options: ['Always', 'Often', 'Sometimes', 'Rarely'],
        ),
      ];

  static List<BlueprintQuestion> get sleepQuestions => [
        const BlueprintQuestion(
          id: 'sleep_schedule',
          title: 'Bedtime preference',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Early bird',
          sliderRightLabel: 'Night owl',
        ),
        const BlueprintQuestion(
          id: 'sleep_shared',
          title: 'Same bed always?',
          type: BlueprintQuestionType.switchType,
        ),
        const BlueprintQuestion(
          id: 'sleep_environment',
          title: 'Sleep environment',
          type: BlueprintQuestionType.multiSelect,
          options: ['Dark', 'Quiet', 'Cool', 'White noise', 'No preference'],
        ),
      ];

  static List<BlueprintQuestion> get holidaysQuestions => [
        const BlueprintQuestion(
          id: 'holidays_celebrate',
          title: 'Which to celebrate together',
          type: BlueprintQuestionType.multiSelect,
          options: ['Christmas', 'New Year', 'Valentine\'s', 'Anniversary', 'Birthdays', 'Easter', 'Thanksgiving'],
        ),
        const BlueprintQuestion(
          id: 'holidays_style',
          title: 'Holiday style',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Low key',
          sliderRightLabel: 'Go all out',
        ),
        const BlueprintQuestion(
          id: 'holidays_family',
          title: 'Spend holidays with family?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get choresQuestions => [
        const BlueprintQuestion(
          id: 'chores_split',
          title: 'Chores should be',
          type: BlueprintQuestionType.choiceChips,
          options: ['50/50', 'Who has time', 'By preference', 'One does more'],
        ),
        const BlueprintQuestion(
          id: 'chores_clean',
          title: 'Cleanliness priority',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Good enough',
          sliderRightLabel: 'Spotless',
        ),
        const BlueprintQuestion(
          id: 'chores_cook',
          title: 'Who cooks more?',
          type: BlueprintQuestionType.choiceChips,
          options: ['Me', 'Partner', 'Both equally', 'Takeout often'],
        ),
      ];

  static List<BlueprintQuestion> get techQuestions => [
        const BlueprintQuestion(
          id: 'tech_screen_time',
          title: 'Screen time when together',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Phones away',
          sliderRightLabel: 'No problem',
        ),
        const BlueprintQuestion(
          id: 'tech_bed',
          title: 'Phones in bed?',
          type: BlueprintQuestionType.switchType,
        ),
        const BlueprintQuestion(
          id: 'tech_social',
          title: 'Social media sharing',
          type: BlueprintQuestionType.choiceChips,
          options: ['Share everything', 'Some things', 'Keep separate', 'Barely use'],
        ),
      ];

  static List<BlueprintQuestion> get futureQuestions => [
        const BlueprintQuestion(
          id: 'future_location',
          title: 'Where to live long-term',
          type: BlueprintQuestionType.choiceChips,
          options: ['Stay here', 'Move city', 'Move country', 'Flexible', 'Not sure'],
        ),
        const BlueprintQuestion(
          id: 'future_career',
          title: 'Career vs relationship priority',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Relationship first',
          sliderRightLabel: 'Career can lead',
        ),
        const BlueprintQuestion(
          id: 'future_bucket',
          title: 'Bucket list together',
          type: BlueprintQuestionType.multiSelect,
          options: ['Travel', 'House', 'Kids', 'Business', 'Adventure', 'Quiet life', 'Other'],
        ),
      ];

  static List<BlueprintQuestion> get valuesQuestions => [
        const BlueprintQuestion(
          id: 'values_trust',
          title: 'Most important in relationship',
          type: BlueprintQuestionType.choiceChips,
          options: ['Trust', 'Communication', 'Fun', 'Stability', 'Growth', 'Adventure'],
        ),
        const BlueprintQuestion(
          id: 'values_religion',
          title: 'Religion / spirituality',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Not important',
          sliderRightLabel: 'Very important',
        ),
        const BlueprintQuestion(
          id: 'values_politics',
          title: 'Political alignment matters?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get adventureQuestions => [
        const BlueprintQuestion(
          id: 'adventure_level',
          title: 'Adventure level',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Safe & familiar',
          sliderRightLabel: 'Try anything once',
        ),
        const BlueprintQuestion(
          id: 'adventure_activities',
          title: 'Want to try',
          type: BlueprintQuestionType.multiSelect,
          options: ['Skydiving', 'Scuba', 'Road trip', 'Camping', 'New cuisine', 'Learning new skill', 'Moving abroad'],
        ),
        const BlueprintQuestion(
          id: 'adventure_spontaneous',
          title: 'Spontaneous plans?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get qualityTimeQuestions => [
        const BlueprintQuestion(
          id: 'qt_quantity',
          title: 'How much quality time needed',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Some is enough',
          sliderRightLabel: 'As much as possible',
        ),
        const BlueprintQuestion(
          id: 'qt_definition',
          title: 'Quality time is',
          type: BlueprintQuestionType.choiceChips,
          options: ['Talking', 'Doing something', 'Just being together', 'All of the above'],
        ),
        const BlueprintQuestion(
          id: 'qt_screens',
          title: 'Screen-free time together?',
          type: BlueprintQuestionType.switchType,
        ),
      ];

  static List<BlueprintQuestion> get humorQuestions => [
        const BlueprintQuestion(
          id: 'humor_type',
          title: 'Humor style',
          type: BlueprintQuestionType.choiceChips,
          options: ['Silly', 'Sarcastic', 'Dark', 'Dad jokes', 'Witty', 'Mixed'],
        ),
        const BlueprintQuestion(
          id: 'humor_importance',
          title: 'Shared humor importance',
          type: BlueprintQuestionType.slider,
          sliderLeftLabel: 'Nice to have',
          sliderRightLabel: 'Essential',
        ),
        const BlueprintQuestion(
          id: 'humor_tease',
          title: 'Playful teasing okay?',
          type: BlueprintQuestionType.switchType,
        ),
      ];
}
