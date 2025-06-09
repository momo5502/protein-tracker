import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:convert';
import 'dart:math' as math;

// Custom color scheme class
class AppColors {
  static Color primary = const Color.fromARGB(255, 20, 116, 13);

  // Light theme colors
  static ColorScheme get lightColorScheme =>
      ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light);

  // Dark theme colors
  static ColorScheme get darkColorScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E1E), // Slightly brighter than default dark
        background:
            const Color(0xFF242424), // Slightly brighter than default dark
        surfaceVariant:
            const Color(0xFF2C2C2C), // Slightly brighter than default dark
        onSurface: const Color(0xFFE0E0E0), // Slightly dimmer than pure white
        onBackground:
            const Color(0xFFE0E0E0), // Slightly dimmer than pure white
      );

  // Common color variations
  static Color get primaryLight => primary.withValues(alpha: 0.1);
  static Color get primaryMedium => primary.withValues(alpha: 0.3);
  static Color get primaryDark => primary.withValues(alpha: 0.8);
}

void main() {
  runApp(const ProteinTrackerApp());
}

class ProteinTrackerApp extends StatefulWidget {
  const ProteinTrackerApp({super.key});

  @override
  State<ProteinTrackerApp> createState() => _ProteinTrackerAppState();
}

class _ProteinTrackerAppState extends State<ProteinTrackerApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    _loadColor();
    _loadThemeMode();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString('locale');
    if (localeCode != null) {
      setState(() {
        _locale = Locale(localeCode);
      });
    }
  }

  Future<void> _loadColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('primary_color');
    if (colorValue != null) {
      setState(() {
        AppColors.primary = Color(colorValue);
      });
    }
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? ThemeMode.system.index;
    setState(() {
      _themeMode = ThemeMode.values[themeModeIndex];
    });
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale != null) {
      await prefs.setString('locale', locale.languageCode);
    } else {
      await prefs.remove('locale');
    }
    setState(() {
      _locale = locale;
    });
  }

  Future<void> setColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primary_color', color.value);
    setState(() {
      AppColors.primary = color;
    });
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Protein Tracker',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.lightColorScheme,
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.darkColorScheme,
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('de'), // German
        Locale('fr'), // French
        Locale('es'), // Spanish
        Locale('it'), // Italian
        Locale('pt'), // Portuguese
        Locale('ja'), // Japanese
      ],
      home: HomePage(
        onLocaleChanged: setLocale,
        onColorChanged: setColor,
        onThemeModeChanged: setThemeMode,
        currentLocale: _locale,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

class ProteinEntry {
  final String date;
  final int amount;
  final String source;
  final DateTime timestamp;

  ProteinEntry({
    required this.date,
    required this.amount,
    required this.source,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'amount': amount,
        'source': source,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ProteinEntry.fromJson(Map<String, dynamic> json) => ProteinEntry(
        date: json['date'],
        amount: json['amount'].toInt(),
        source: json['source'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class HomePage extends StatefulWidget {
  final Function(Locale?) onLocaleChanged;
  final Function(Color) onColorChanged;
  final Function(ThemeMode) onThemeModeChanged;
  final Locale? currentLocale;
  final ThemeMode currentThemeMode;

  const HomePage({
    super.key,
    required this.onLocaleChanged,
    required this.onColorChanged,
    required this.onThemeModeChanged,
    required this.currentLocale,
    required this.currentThemeMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<ProteinEntry> _proteinEntries = [];
  double _dailyGoal = 100.0; // Default 100g protein
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _loadData();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList('protein_entries') ?? [];
    final goal = prefs.getDouble('daily_goal') ?? 100.0;

    setState(() {
      _dailyGoal = goal;
      _proteinEntries = entriesJson
          .map((e) => ProteinEntry.fromJson(json.decode(e)))
          .toList();
    });

    _progressAnimationController.forward();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson =
        _proteinEntries.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('protein_entries', entriesJson);
    await prefs.setDouble('daily_goal', _dailyGoal);
  }

  double get _todayTotal {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _proteinEntries
        .where((entry) => entry.date == today)
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  List<ProteinEntry> get _todayEntries {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _proteinEntries.where((entry) => entry.date == today).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  double get _progressPercentage {
    return math.min(_todayTotal / _dailyGoal, 1.0);
  }

  Color get _progressColor {
    /*final percentage = _progressPercentage;
    if (percentage >= 1.0) return Colors.green;
    if (percentage >= 0.8) return Colors.orange;*/
    return AppColors.primary;
  }

  void _addProteinEntry() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddProteinModal(
        onAdd: (amount, source, timestamp) {
          final entry = ProteinEntry(
            date: DateFormat('yyyy-MM-dd').format(timestamp),
            amount: amount.toInt(),
            source: source,
            timestamp: timestamp,
          );
          setState(() {
            _proteinEntries.add(entry);
          });
          _saveData();
          _progressAnimationController.reset();
          _progressAnimationController.forward();
        },
      ),
    );
  }

  void _setDailyGoal() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => SetGoalDialog(
        currentGoal: _dailyGoal,
        onSet: (goal) {
          setState(() {
            _dailyGoal = goal;
          });
          _saveData();
        },
        onLocaleChanged: widget.onLocaleChanged,
        onColorChanged: widget.onColorChanged,
        onThemeModeChanged: widget.onThemeModeChanged,
        currentLocale: widget.currentLocale,
        currentThemeMode: widget.currentThemeMode,
      ),
    );
  }

  void _showHistory() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(entries: _proteinEntries),
      ),
    );
  }

  void _editProteinEntry(ProteinEntry entry) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddProteinModal(
        initialAmount: entry.amount.toDouble(),
        initialSource: entry.source,
        initialTimestamp: entry.timestamp,
        onAdd: (amount, source, timestamp) {
          setState(() {
            final index = _proteinEntries
                .indexWhere((e) => e.timestamp == entry.timestamp);
            if (index != -1) {
              _proteinEntries[index] = ProteinEntry(
                date: DateFormat('yyyy-MM-dd').format(timestamp),
                amount: amount.toInt(),
                source: source,
                timestamp: timestamp,
              );
            }
          });
          _saveData();
          _progressAnimationController.reset();
          _progressAnimationController.forward();
        },
      ),
    );
  }

  void _deleteProteinEntry(ProteinEntry entry) {
    HapticFeedback.heavyImpact();
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.deleteEntry,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.amount}g',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        entry.source.isEmpty ? l10n.entry : entry.source,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          HapticFeedback.heavyImpact();
                          _proteinEntries.removeWhere(
                              (e) => e.timestamp == entry.timestamp);
                        });
                        _saveData();
                        _progressAnimationController.reset();
                        _progressAnimationController.forward();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.delete,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecipeList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecipeListPage(),
      ),
    );

    if (result != null) {
      final entry = ProteinEntry(
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        amount: result['protein'],
        source: result['name'],
        timestamp: DateTime.now(),
      );
      setState(() {
        _proteinEntries.add(entry);
      });
      _saveData();
      _progressAnimationController.reset();
      _progressAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showHistory();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showRecipeList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _setDailyGoal();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(Colors.white, _progressColor, 0.8)!,
                        _progressColor,
                        Color.lerp(Colors.black, _progressColor, 0.8)!
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _progressColor.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.todayProgress,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(150, 150),
                            painter: CircularProgressPainter(
                              progress: _progressAnimation.value *
                                  _progressPercentage,
                              strokeWidth: 12,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.2),
                              progressColor: Colors.white,
                            ),
                            child: SizedBox(
                              width: 150,
                              height: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(_progressAnimation.value * _todayTotal).toInt()}g',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${l10n.progressOf} ${_dailyGoal.toInt()}g',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${(_progressPercentage * 100).toInt()}% ${l10n.complete}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.todayEntries,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addProteinEntry,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.add),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _todayEntries.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? colorScheme.surfaceVariant
                              : Color.lerp(
                                  colorScheme.surface, Colors.white, 0.7),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 48,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noEntriesToday,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.startTracking,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _todayEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _todayEntries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onLongPress: () {
                            HapticFeedback.mediumImpact();
                            final l10n = AppLocalizations.of(context)!;
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          l10n.editEntry,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          icon: const Icon(Icons.close),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      title: Text(
                                        l10n.edit,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        Navigator.pop(context);
                                        _editProteinEntry(entry);
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                      title: Text(
                                        l10n.delete,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
                                      ),
                                      onTap: () {
                                        HapticFeedback.heavyImpact();
                                        Navigator.pop(context);
                                        _deleteProteinEntry(entry);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? colorScheme.surfaceVariant
                                  : Color.lerp(
                                      colorScheme.surface, Colors.white, 0.7),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow
                                      .withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.source.isEmpty
                                            ? l10n.entry
                                            : entry.source,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? colorScheme.onSurfaceVariant
                                              : colorScheme.onSurface,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('h:mm a')
                                            .format(entry.timestamp),
                                        style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? colorScheme.onSurfaceVariant
                                                  .withValues(alpha: 0.6)
                                              : colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${entry.amount}g',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AddProteinModal extends StatefulWidget {
  final Function(double, String, DateTime) onAdd;
  final double? initialAmount;
  final String? initialSource;
  final DateTime? initialTimestamp;

  const AddProteinModal({
    super.key,
    required this.onAdd,
    this.initialAmount,
    this.initialSource,
    this.initialTimestamp,
  });

  @override
  State<AddProteinModal> createState() => _AddProteinModalState();
}

class _AddProteinModalState extends State<AddProteinModal> {
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  List<Map<String, dynamic>> _customSources = [];
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!.toInt().toString();
    }
    if (widget.initialSource != null) {
      _sourceController.text = widget.initialSource!;
    }
    _selectedDateTime = widget.initialTimestamp ?? DateTime.now();
    _loadCustomSources();
  }

  Future<void> _loadCustomSources() async {
    final prefs = await SharedPreferences.getInstance();
    final customSourcesJson = prefs.getStringList('custom_sources') ?? [];
    setState(() {
      _customSources = customSourcesJson.map((json) {
        final Map<String, dynamic> source = jsonDecode(json);
        // Ensure protein is stored as an integer
        source['protein'] = (source['protein'] as num).toInt();
        return source;
      }).toList();
    });
  }

  Future<void> _saveCustomSource(String name, int protein) async {
    final prefs = await SharedPreferences.getInstance();
    final newSource = {'name': name, 'protein': protein};

    // Remove if already exists to avoid duplicates
    _customSources.removeWhere((source) => source['name'] == name);

    // Add to the beginning of the list
    _customSources.insert(0, newSource);

    // Keep only the last 5 custom entries
    if (_customSources.length > 5) {
      _customSources = _customSources.sublist(0, 5);
    }

    // Save to SharedPreferences
    final customSourcesJson =
        _customSources.map((source) => jsonEncode(source)).toList();
    await prefs.setStringList('custom_sources', customSourcesJson);

    setState(() {});
  }

  Future<void> _deleteCustomSource(String name) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove the source from the list
    _customSources.removeWhere((source) => source['name'] == name);

    // Save to SharedPreferences
    final customSourcesJson =
        _customSources.map((source) => jsonEncode(source)).toList();
    await prefs.setStringList('custom_sources', customSourcesJson);

    setState(() {});
  }

  Future<void> _selectDateTime() async {
    HapticFeedback.mediumImpact();
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: colorScheme.copyWith(
                primary: AppColors.primary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.addProtein,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_customSources.isNotEmpty) ...[
              Text(
                l10n.recentEntries,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _customSources
                    .map(
                      (source) => GestureDetector(
                        onTap: () {
                          _sourceController.text = source['name'];
                          _amountController.text = source['protein'].toString();
                        },
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          l10n.deleteEntry,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(Icons.close,
                                              color: colorScheme.onSurface),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: colorScheme.outline
                                                .withValues(alpha: 0.5)),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${source['protein']}g',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              source['name'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: colorScheme.onSurface,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              Navigator.pop(context);
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              l10n.cancel,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              HapticFeedback.heavyImpact();
                                              _deleteCustomSource(
                                                  source['name']);
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              l10n.delete,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryMedium),
                          ),
                          child: Text(
                            '${source['name']} (${source['protein']}g)',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
            TextField(
              controller: _sourceController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: l10n.proteinSource,
                hintText: l10n.proteinSourceHint,
                labelStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
                hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.restaurant_menu,
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              style: TextStyle(color: colorScheme.onSurface),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.proteinAmount,
                hintText: l10n.proteinAmountHint,
                labelStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
                hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.fitness_center,
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
                suffixText: 'g',
                suffixStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectDateTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, d. MMMM yyyy, HH:mm')
                            .format(_selectedDateTime),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final amount = int.tryParse(_amountController.text);
                  final source = _sourceController.text.trim();
                  final timestamp = _selectedDateTime;

                  if (amount != null && amount > 0) {
                    if (source.isNotEmpty) {
                      _saveCustomSource(source, amount);
                    }
                    widget.onAdd(amount.toDouble(), source, timestamp);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.addEntry,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class SetGoalDialog extends StatefulWidget {
  final double currentGoal;
  final Function(double) onSet;
  final Function(Locale?) onLocaleChanged;
  final Function(Color) onColorChanged;
  final Function(ThemeMode) onThemeModeChanged;
  final Locale? currentLocale;
  final ThemeMode currentThemeMode;

  const SetGoalDialog({
    super.key,
    required this.currentGoal,
    required this.onSet,
    required this.onLocaleChanged,
    required this.onColorChanged,
    required this.onThemeModeChanged,
    required this.currentLocale,
    required this.currentThemeMode,
  });

  @override
  State<SetGoalDialog> createState() => _SetGoalDialogState();
}

class _SetGoalDialogState extends State<SetGoalDialog> {
  late TextEditingController _controller;
  late String _selectedLanguage;
  Color _selectedColor = AppColors.primary;
  ThemeMode _selectedThemeMode = ThemeMode.system;

  // Store original values
  late double _originalGoal;
  late String _originalLanguage;
  late Color _originalColor;
  late ThemeMode _originalThemeMode;

  @override
  void initState() {
    super.initState();
    _originalGoal = widget.currentGoal;
    _originalLanguage = widget.currentLocale?.languageCode ?? 'system';
    _originalColor = AppColors.primary;
    _originalThemeMode = widget.currentThemeMode;

    _controller = TextEditingController(
      text: widget.currentGoal.toInt().toString(),
    );
    _selectedLanguage = _originalLanguage;
    _selectedColor = _originalColor;
    _selectedThemeMode = _originalThemeMode;
  }

  void _cancelChanges() {
    HapticFeedback.lightImpact();
    // Revert all changes
    setState(() {
      _selectedLanguage = _originalLanguage;
      _selectedColor = _originalColor;
      _selectedThemeMode = _originalThemeMode;
      _controller.text = _originalGoal.toInt().toString();
    });

    // Revert color
    widget.onColorChanged(_originalColor);

    // Revert language
    if (_originalLanguage == 'system') {
      widget.onLocaleChanged(null);
    } else {
      widget.onLocaleChanged(Locale(_originalLanguage));
    }

    // Revert theme
    widget.onThemeModeChanged(_originalThemeMode);

    Navigator.pop(context);
  }

  void _showColorPicker() {
    HapticFeedback.mediumImpact();
    Color tempColor = _selectedColor;
    Color originalColor = _selectedColor;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pick a color',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedColor = originalColor;
                      });
                      widget.onColorChanged(originalColor);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ColorPicker(
                pickerColor: tempColor,
                onColorChanged: (color) {
                  setState(() {
                    tempColor = color;
                  });
                  widget.onColorChanged(color);
                },
                pickerAreaHeightPercent: 0.5,
                enableAlpha: false,
                labelTypes: const [],
                displayThumbColor: true,
                pickerAreaBorderRadius: BorderRadius.circular(12),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedColor = originalColor;
                        });
                        widget.onColorChanged(originalColor);
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _selectedColor = tempColor;
                        });
                        widget.onColorChanged(tempColor);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.settings,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _cancelChanges();
                  },
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dailyProteinGoal,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      style: TextStyle(color: colorScheme.onSurface),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: l10n.proteinAmountHint,
                        hintStyle: TextStyle(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.fitness_center,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.7)),
                        suffixText: 'g',
                        suffixStyle: TextStyle(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.7)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color:
                                  colorScheme.outline.withValues(alpha: 0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.appColor,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _showColorPicker();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  colorScheme.outline.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _selectedColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: colorScheme.outline
                                        .withValues(alpha: 0.5)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                l10n.tapToChangeColor,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.language,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: colorScheme.surface,
                        style: TextStyle(color: colorScheme.onSurface),
                        items: [
                          DropdownMenuItem(
                            value: 'system',
                            child: Text(l10n.systemDefault),
                          ),
                          const DropdownMenuItem(
                            value: 'en',
                            child: Text('English'),
                          ),
                          const DropdownMenuItem(
                            value: 'de',
                            child: Text('Deutsch'),
                          ),
                          const DropdownMenuItem(
                            value: 'fr',
                            child: Text('Français'),
                          ),
                          const DropdownMenuItem(
                            value: 'es',
                            child: Text('Español'),
                          ),
                          const DropdownMenuItem(
                            value: 'it',
                            child: Text('Italiano'),
                          ),
                          const DropdownMenuItem(
                            value: 'pt',
                            child: Text('Português'),
                          ),
                          const DropdownMenuItem(
                            value: 'ja',
                            child: Text('日本語'),
                          ),
                        ],
                        onChanged: (value) {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _selectedLanguage = value!;
                          });
                          if (value == 'system') {
                            widget.onLocaleChanged(null);
                          } else {
                            widget.onLocaleChanged(Locale(value!));
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.theme,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<ThemeMode>(
                        value: _selectedThemeMode,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: colorScheme.surface,
                        style: TextStyle(color: colorScheme.onSurface),
                        items: [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text(l10n.systemDefault),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text(l10n.light),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text(l10n.dark),
                          ),
                        ],
                        onChanged: (value) {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _selectedThemeMode = value!;
                          });
                          widget.onThemeModeChanged(value!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Fixed footer
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _cancelChanges();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      final goal = double.tryParse(_controller.text);
                      if (goal != null && goal > 0) {
                        widget.onSet(goal);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.save,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final List<ProteinEntry> entries;

  const HistoryPage({super.key, required this.entries});

  Map<String, double> get _dailyTotals {
    final Map<String, double> totals = {};
    for (final entry in entries) {
      totals[entry.date] = (totals[entry.date] ?? 0) + entry.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final sortedDates = _dailyTotals.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        backgroundColor: Colors.transparent,
      ),
      body: sortedDates.isEmpty
          ? Center(
              child: Text(
                l10n.noHistory,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final total = _dailyTotals[date]!;
                final dateObj = DateTime.parse(date);
                final isToday =
                    DateFormat('yyyy-MM-dd').format(DateTime.now()) == date;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? colorScheme.surfaceVariant
                          : Color.lerp(colorScheme.surface, Colors.white, 0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        isToday
                            ? l10n.today
                            : DateFormat('EEEE, MMM d').format(dateObj),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        DateFormat('yyyy-MM-dd').format(dateObj),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        '${total.toInt()}g',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  List<Map<String, dynamic>> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getStringList('recipes') ?? [];
    setState(() {
      _recipes = recipesJson
          .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
          .toList();
    });
  }

  Future<void> _saveRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = _recipes.map((recipe) => jsonEncode(recipe)).toList();
    await prefs.setStringList('recipes', recipesJson);
  }

  void _addRecipe() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AddRecipeDialog(
        onAdd: (name, protein) async {
          setState(() {
            _recipes.add({
              'name': name,
              'protein': protein,
            });
          });
          await _saveRecipes();
        },
      ),
    );
  }

  void _deleteRecipe(int index) {
    HapticFeedback.heavyImpact();
    setState(() {
      _recipes.removeAt(index);
    });
    _saveRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recipeList),
        backgroundColor: Colors.transparent,
      ),
      body: _recipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noRecipes,
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                final recipe = _recipes[index];
                return Dismissible(
                  key: Key(recipe['name']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) => _deleteRecipe(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? colorScheme.surfaceVariant
                          : Color.lerp(colorScheme.surface, Colors.white, 0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        recipe['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Text(
                        '${recipe['protein']}g',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context, recipe);
                      },
                      onLongPress: () {
                        HapticFeedback.mediumImpact();
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.editEntry,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.close),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                  title: Text(
                                    l10n.delete,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red,
                                    ),
                                  ),
                                  onTap: () {
                                    HapticFeedback.heavyImpact();
                                    Navigator.pop(context);
                                    _deleteRecipe(index);
                                  },
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecipe,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddRecipeDialog extends StatefulWidget {
  final Function(String, int) onAdd;

  const AddRecipeDialog({super.key, required this.onAdd});

  @override
  State<AddRecipeDialog> createState() => _AddRecipeDialogState();
}

class _AddRecipeDialogState extends State<AddRecipeDialog> {
  final _nameController = TextEditingController();
  final _proteinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.addRecipe,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: l10n.recipeName,
                hintText: l10n.recipeNameHint,
                labelStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
                hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.restaurant_menu,
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _proteinController,
              style: TextStyle(color: colorScheme.onSurface),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.proteinAmount,
                hintText: l10n.proteinAmountHint,
                labelStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
                hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.fitness_center,
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
                suffixText: 'g',
                suffixStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      final name = _nameController.text.trim();
                      final protein = int.tryParse(_proteinController.text);
                      if (name.isNotEmpty && protein != null && protein > 0) {
                        widget.onAdd(name, protein);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.add,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
