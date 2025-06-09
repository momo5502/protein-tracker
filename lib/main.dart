import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math' as math;

// Custom color scheme class
class AppColors {
  static const Color primary = Color.fromARGB(255, 20, 116, 13);

  // Light theme colors
  static ColorScheme get lightColorScheme =>
      ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light);

  // Dark theme colors
  static ColorScheme get darkColorScheme =>
      ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark);

  // Common color variations
  static Color get primaryLight => primary.withOpacity(0.1);
  static Color get primaryMedium => primary.withOpacity(0.3);
  static Color get primaryDark => primary.withOpacity(0.8);
}

void main() {
  runApp(const ProteinTrackerApp());
}

class ProteinTrackerApp extends StatelessWidget {
  const ProteinTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Protein Tracker',
      debugShowCheckedModeBanner: false,
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
      home: const HomePage(),
    );
  }
}

class ProteinEntry {
  final String date;
  final double amount;
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
    amount: json['amount'].toDouble(),
    source: json['source'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    final entriesJson = _proteinEntries
        .map((e) => json.encode(e.toJson()))
        .toList();
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
    final percentage = _progressPercentage;
    if (percentage >= 1.0) return Colors.green;
    if (percentage >= 0.8) return Colors.orange;
    return AppColors.primary;
  }

  void _addProteinEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddProteinModal(
        onAdd: (amount, source) {
          final entry = ProteinEntry(
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            amount: amount,
            source: source,
            timestamp: DateTime.now(),
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
      ),
    );
  }

  void _showHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(entries: _proteinEntries),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Protein Tracker',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: _showHistory),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _setDailyGoal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_progressColor.withOpacity(0.8), _progressColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _progressColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Today\'s Progress',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
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
                          progress:
                              _progressAnimation.value * _progressPercentage,
                          strokeWidth: 12,
                          backgroundColor: Colors.white.withOpacity(0.2),
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
                                'of ${_dailyGoal.toInt()}g',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
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
                    '${(_progressPercentage * 100).toInt()}% Complete',
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

            // Today's Entries
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Entries',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addProteinEntry,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_todayEntries.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No entries today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start tracking your protein intake',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            else
              ..._todayEntries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.source,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                DateFormat('h:mm a').format(entry.timestamp),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${entry.amount.toInt()}g',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProteinEntry,
        icon: const Icon(Icons.add),
        label: const Text('Add Protein'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
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
  final Function(double, String) onAdd;

  const AddProteinModal({super.key, required this.onAdd});

  @override
  State<AddProteinModal> createState() => _AddProteinModalState();
}

class _AddProteinModalState extends State<AddProteinModal> {
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();

  final List<Map<String, dynamic>> _commonSources = [
    {'name': 'Chicken Breast', 'protein': 31},
    {'name': 'Salmon', 'protein': 25},
    {'name': 'Greek Yogurt', 'protein': 20},
    {'name': 'Eggs', 'protein': 13},
    {'name': 'Protein Shake', 'protein': 25},
    {'name': 'Tofu', 'protein': 17},
    {'name': 'Quinoa', 'protein': 14},
    {'name': 'Almonds', 'protein': 21},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Protein',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick select common sources
            const Text(
              'Quick Select',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonSources
                  .map(
                    (source) => GestureDetector(
                      onTap: () {
                        _sourceController.text = source['name'];
                        _amountController.text = source['protein'].toString();
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
                          style: const TextStyle(
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

            TextField(
              controller: _sourceController,
              decoration: InputDecoration(
                labelText: 'Protein Source',
                hintText: 'e.g., Chicken breast, Protein shake',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.restaurant_menu),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Protein Amount (g)',
                hintText: 'Enter grams of protein',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.fitness_center),
                suffixText: 'g',
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text);
                  final source = _sourceController.text.trim();

                  if (amount != null && amount > 0 && source.isNotEmpty) {
                    widget.onAdd(amount, source);
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
                child: const Text(
                  'Add Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  const SetGoalDialog({
    super.key,
    required this.currentGoal,
    required this.onSet,
  });

  @override
  State<SetGoalDialog> createState() => _SetGoalDialogState();
}

class _SetGoalDialogState extends State<SetGoalDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentGoal.toInt().toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Daily Goal'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Daily Protein Goal (g)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixText: 'g',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final goal = double.tryParse(_controller.text);
            if (goal != null && goal > 0) {
              widget.onSet(goal);
              Navigator.pop(context);
            }
          },
          child: const Text('Set Goal'),
        ),
      ],
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
    final sortedDates = _dailyTotals.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.transparent,
      ),
      body: sortedDates.isEmpty
          ? const Center(
              child: Text(
                'No history yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
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

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      isToday
                          ? 'Today'
                          : DateFormat('EEEE, MMM d').format(dateObj),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(dateObj)),
                    trailing: Text(
                      '${total.toInt()}g',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
