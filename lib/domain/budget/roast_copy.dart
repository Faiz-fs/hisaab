import '../models/enums.dart';

/// Template-based roast copy generator.
///
/// Returns a roast string for a given [RoastLevel] and top culprit [category].
abstract final class RoastCopy {
  static const _quips = <String, List<String>>{
    'Food Delivery': ['Your kitchen filed a missing-person report.', 'Delivery fee: the real main course.'],
    'Quick Commerce': ['10-minute delivery, 10-year regret.', 'You needed milk. You bought a lifestyle.'],
    'Shopping': ['Add to cart is not a personality.', 'The parcel was fast. Your savings were faster.'],
    'Dining': ['Eating out again? Bold of you.', 'The restaurant thanks you for your service.'],
    'Cafe': ['Caffeine is not a budget category.', 'That latte had a mortgage.'],
    'Transport': ['Going places. Mostly down.', 'Your commute has a commission.'],
    'Entertainment': ['Subscriptions are quietly eating you alive.', 'Watched anything worth the price?'],
    'Transfers': ['Money moved. Where did it go?', 'Big transfers, bigger questions.'],
  };

  static String generate({
    required RoastLevel level,
    required String category,
    required bool overBudget,
  }) {
    if (!overBudget) {
      return switch (level) {
        RoastLevel.gentle => "You're doing great today 🌿",
        RoastLevel.honest => 'Under budget. Keep it up.',
        RoastLevel.savage => "Surprisingly disciplined. Don't ruin it.",
      };
    }
    final quip = _quips[category];
    final extra = quip == null ? '' : ' ${quip[category.length % quip.length]}';
    return switch (level) {
      RoastLevel.gentle => 'Spent a bit on $category today — maybe go easier tomorrow?',
      RoastLevel.honest => 'You blew past budget on $category.$extra',
      RoastLevel.savage => '$category? Really? Your bank statement is a cry for help. 💀$extra',
    };
  }
}
