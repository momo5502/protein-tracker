// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Protein Tracker';

  @override
  String get todayProgress => 'Today\'s Progress';

  @override
  String get progressOf => 'of';

  @override
  String get complete => 'Complete';

  @override
  String get todayEntries => 'Today\'s Entries';

  @override
  String get add => 'Add';

  @override
  String get noEntriesToday => 'No entries today';

  @override
  String get startTracking => 'Start tracking your protein intake';

  @override
  String get addProtein => 'Add Protein';

  @override
  String get quickSelect => 'Quick Select';

  @override
  String get proteinSource => 'Protein Source';

  @override
  String get proteinSourceHint => 'e.g., Chicken breast, Protein shake';

  @override
  String get proteinAmount => 'Protein Amount (g)';

  @override
  String get proteinAmountHint => 'Enter grams of protein';

  @override
  String get addEntry => 'Add Entry';

  @override
  String get setDailyGoal => 'Set Daily Goal';

  @override
  String get dailyProteinGoal => 'Daily Protein Goal (g)';

  @override
  String get cancel => 'Cancel';

  @override
  String get setGoal => 'Set Goal';

  @override
  String get history => 'History';

  @override
  String get noHistory => 'No history yet';

  @override
  String get today => 'Today';

  @override
  String get settings => 'Settings';

  @override
  String get save => 'Save';
}
