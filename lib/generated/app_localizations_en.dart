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
  String get complete => 'complete';

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
  String get proteinSourceHint => 'e.g., Chicken Breast';

  @override
  String get proteinAmount => 'Protein Amount';

  @override
  String get proteinAmountHint => 'e.g., 30';

  @override
  String get addEntry => 'Add Entry';

  @override
  String get setDailyGoal => 'Set Daily Goal';

  @override
  String get dailyProteinGoal => 'Daily Protein Goal';

  @override
  String get cancel => 'Cancel';

  @override
  String get setGoal => 'Set Goal';

  @override
  String get history => 'History';

  @override
  String get noHistory => 'No history available';

  @override
  String get today => 'Today';

  @override
  String get settings => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get editEntry => 'Edit Entry';

  @override
  String get deleteEntry => 'Delete Entry';

  @override
  String get deleteConfirmation =>
      'Are you sure you want to delete this entry?';

  @override
  String get recentEntries => 'Recent Entries';

  @override
  String get entry => 'Entry';
}
