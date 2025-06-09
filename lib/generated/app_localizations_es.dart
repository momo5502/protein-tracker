// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Seguimiento de Proteínas';

  @override
  String get todayProgress => 'Progreso de hoy';

  @override
  String get progressOf => 'de';

  @override
  String get complete => 'completado';

  @override
  String get todayEntries => 'Entradas de hoy';

  @override
  String get add => 'Añadir';

  @override
  String get noEntriesToday => 'No hay entradas hoy';

  @override
  String get startTracking => 'Comienza a registrar tu ingesta de proteínas';

  @override
  String get editEntry => 'Editar entrada';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteEntry => 'Eliminar entrada';

  @override
  String get entry => 'Entrada';

  @override
  String get addProtein => 'Añadir proteína';

  @override
  String get recentEntries => 'Entradas recientes';

  @override
  String get proteinSource => 'Fuente de proteína';

  @override
  String get proteinSourceHint => 'ej. Pechuga de pollo';

  @override
  String get proteinAmount => 'Cantidad de proteína';

  @override
  String get proteinAmountHint => 'Ingresa la cantidad';

  @override
  String get addEntry => 'Añadir entrada';

  @override
  String get settings => 'Ajustes';

  @override
  String get dailyProteinGoal => 'Objetivo diario de proteínas';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get history => 'Historial';

  @override
  String get noHistory => 'No hay historial disponible';

  @override
  String get today => 'Hoy';
}
