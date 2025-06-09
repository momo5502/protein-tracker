// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Protein Tracker';

  @override
  String get todayProgress => 'Heutiger Fortschritt';

  @override
  String get progressOf => 'von';

  @override
  String get complete => 'Abgeschlossen';

  @override
  String get todayEntries => 'Heutige Einträge';

  @override
  String get add => 'Hinzufügen';

  @override
  String get noEntriesToday => 'Keine Einträge heute';

  @override
  String get startTracking =>
      'Beginnen Sie mit der Verfolgung Ihrer Proteinaufnahme';

  @override
  String get addProtein => 'Protein hinzufügen';

  @override
  String get quickSelect => 'Schnellauswahl';

  @override
  String get proteinSource => 'Proteinquelle';

  @override
  String get proteinSourceHint => 'z.B. Hähnchenbrust, Proteinshake';

  @override
  String get proteinAmount => 'Proteinmenge (g)';

  @override
  String get proteinAmountHint => 'Geben Sie die Gramm Protein ein';

  @override
  String get addEntry => 'Eintrag hinzufügen';

  @override
  String get setDailyGoal => 'Tagesziel festlegen';

  @override
  String get dailyProteinGoal => 'Tägliches Proteinziel (g)';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get setGoal => 'Ziel festlegen';

  @override
  String get history => 'Verlauf';

  @override
  String get noHistory => 'Noch kein Verlauf vorhanden';

  @override
  String get today => 'Heute';

  @override
  String get settings => 'Einstellungen';

  @override
  String get save => 'Speichern';
}
