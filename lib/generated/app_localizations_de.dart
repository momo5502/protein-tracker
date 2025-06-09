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
  String get complete => 'abgeschlossen';

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
  String get proteinSourceHint => 'z.B. Hähnchenbrust';

  @override
  String get proteinAmount => 'Proteinmenge';

  @override
  String get proteinAmountHint => 'z.B. 30';

  @override
  String get addEntry => 'Eintrag hinzufügen';

  @override
  String get setDailyGoal => 'Tagesziel festlegen';

  @override
  String get dailyProteinGoal => 'Tagesziel für Protein';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get setGoal => 'Ziel festlegen';

  @override
  String get history => 'Verlauf';

  @override
  String get noHistory => 'Kein Verlauf verfügbar';

  @override
  String get today => 'Heute';

  @override
  String get settings => 'Einstellungen';

  @override
  String get save => 'Speichern';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get editEntry => 'Eintrag bearbeiten';

  @override
  String get deleteEntry => 'Eintrag löschen';

  @override
  String get deleteConfirmation =>
      'Möchten Sie diesen Eintrag wirklich löschen?';

  @override
  String get recentEntries => 'Letzte Einträge';

  @override
  String get entry => 'Eintrag';

  @override
  String get appColor => 'App-Farbe';

  @override
  String get selectColor => 'Farbe auswählen';
}
