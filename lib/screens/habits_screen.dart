import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';

import 'package:confetti/confetti.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerConfetti() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitProvider);

    return Stack(
      children: [
        CupertinoPageScaffold(
          backgroundColor: AppTheme.navy,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: const Color(0xCC111432),
            border: const Border(
              bottom: BorderSide(color: AppTheme.glassBorder, width: 0.5),
            ),
            middle: const Text(
              'Habits',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            trailing: GestureDetector(
              onTap: () => _showAddHabitSheet(context),
              child: const Icon(
                CupertinoIcons.add,
                color: AppTheme.accentCyan,
                size: 24,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Adaptive buffering keeps you on track',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: habits.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: habits.length,
                          itemBuilder: (_, i) => _HabitCard(
                            key: ValueKey(habits[i].id),
                            habit: habits[i],
                            onCompleted: _triggerConfetti,
                          ).animate().fadeIn(delay: (i * 80).ms).slideY(begin: 0.1),
                        ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 / 2, // Straight down
            maxBlastForce: 25, // set a lower max blast force
            minBlastForce: 15, // set a lower min blast force
            emissionFrequency: 0.05,
            numberOfParticles: 30, // a lot of particles at once
            gravity: 0.2,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('🎯', style: TextStyle(fontSize: 52)),
          SizedBox(height: 16),
          Text('No habits yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          SizedBox(height: 8),
          Text(
            'Add a habit to start tracking\nyour daily progress',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => const _AddHabitSheet(),
    );
  }
}

class _HabitCard extends ConsumerStatefulWidget {
  final HabitModel habit;
  final VoidCallback onCompleted;
  const _HabitCard({super.key, required this.habit, required this.onCompleted});

  @override
  ConsumerState<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<_HabitCard> {
  bool _showLogInput = false;
  final _logCtrl = TextEditingController();
  final _today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void dispose() {
    _logCtrl.dispose();
    super.dispose();
  }

  Color get _habitColor {
    if (widget.habit.colorHex != null) {
      try {
        return Color(int.parse(widget.habit.colorHex!.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return AppTheme.accentCyan;
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final todayActual = habit.getProgressForDate(_today);
    final isCompleted = habit.isCompletedForDate(_today);
    final progressPct =
        (todayActual / habit.targetValue).clamp(0.0, 1.0);
    final deficit = habit.carryOverBuffer < 0 ? habit.carryOverBuffer.abs() : 0.0;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(0),
      borderColor: isCompleted
          ? AppTheme.accentGreen.withOpacity(0.4)
          : _habitColor.withOpacity(0.25),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _habitColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getHabitIcon(habit.iconName),
                        color: _habitColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(habit.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary)),
                          Text(
                            '${todayActual.toStringAsFixed(0)} / ${habit.targetValue.toStringAsFixed(0)} ${habit.unit}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text('🔥 ${habit.currentStreak}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accentAmber)),
                        const Text('streak',
                            style: TextStyle(
                                fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedProgressBar(
                  value: progressPct,
                  height: 8,
                  gradient: isCompleted
                      ? AppTheme.successGradient
                      : LinearGradient(colors: [_habitColor, _habitColor.withOpacity(0.5)]),
                  backgroundColor: AppTheme.charcoalLight,
                ),
                if (deficit > 0 || habit.carryOverBuffer > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        deficit > 0
                            ? CupertinoIcons.exclamationmark_triangle_fill
                            : CupertinoIcons.arrow_up_right_circle_fill,
                        size: 14,
                        color: deficit > 0
                            ? AppTheme.accentAmber
                            : AppTheme.accentGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        deficit > 0
                            ? 'Catch-up needed: ${deficit.toStringAsFixed(1)} ${habit.unit} extra today'
                            : 'Surplus: ${habit.carryOverBuffer.toStringAsFixed(1)} ${habit.unit} banked ✨',
                        style: TextStyle(
                          fontSize: 11,
                          color: deficit > 0
                              ? AppTheme.accentAmber
                              : AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                _buildMiniChart(habit),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: AppTheme.glassBorder, width: 1)),
            ),
            child: _showLogInput
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            controller: _logCtrl,
                            keyboardType: TextInputType.number,
                            autofocus: true,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            placeholder: 'How many ${habit.unit}?',
                            placeholderStyle: TextStyle(color: AppTheme.textMuted),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.glassBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.glassBorder),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                         GestureDetector(
                           onTap: () async {
                             final val = double.tryParse(_logCtrl.text);
                             if (val != null) {
                               final wasCompleted = habit.isCompletedForDate(_today);
                               ref
                                   .read(habitProvider.notifier)
                                   .logProgress(habit.id, val);
                               // Wait a tick for state to update then check
                               await Future.delayed(const Duration(milliseconds: 100));
                               final nowCompleted = widget.habit.isCompletedForDate(_today);
                               if (!wasCompleted && nowCompleted) {
                                 widget.onCompleted();
                               }
                             }
                             setState(() {
                               _showLogInput = false;
                               _logCtrl.clear();
                             });
                           },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: AppTheme.successGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Log',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _showLogInput = false),
                          child: const Icon(CupertinoIcons.clear_thick_circled,
                              color: AppTheme.textMuted, size: 20),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () => setState(() => _showLogInput = true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCompleted
                                ? CupertinoIcons.pencil
                                : CupertinoIcons.add_circled,
                            size: 16,
                            color: isCompleted
                                ? AppTheme.accentGreen
                                : _habitColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCompleted ? 'Update Progress' : 'Log Progress',
                            style: TextStyle(
                                color: isCompleted
                                    ? AppTheme.accentGreen
                                    : _habitColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChart(HabitModel habit) {
    final days = 7;
    final data = List.generate(days, (i) {
      final date =
          DateTime.now().subtract(Duration(days: days - 1 - i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final actual = habit.completionLog[key] ?? 0.0;
      return actual / habit.targetValue;
    });

    return Row(
      children: data.asMap().entries.map((e) {
        final pct = e.value.clamp(0.0, 1.0);
        final isToday = e.key == days - 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              children: [
                Container(
                  height: 32,
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: pct == 0 ? 0.05 : pct,
                    child: Container(
                      decoration: BoxDecoration(
                        color: pct >= 1
                            ? AppTheme.accentGreen
                            : pct > 0
                                ? _habitColor.withOpacity(0.6)
                                : AppTheme.charcoalLight,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        border: isToday
                            ? Border.all(color: _habitColor, width: 1.5)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _shortDay(e.key),
                  style: TextStyle(
                      fontSize: 8,
                      color: isToday
                          ? _habitColor
                          : AppTheme.textMuted),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _shortDay(int index) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final date = DateTime.now().subtract(Duration(days: 6 - index));
    return days[date.weekday % 7];
  }

  IconData _getHabitIcon(String? name) {
    switch (name) {
      case 'reading':
        return CupertinoIcons.book_fill;
      case 'fitness':
        return CupertinoIcons.heart_fill;
      case 'water':
        return CupertinoIcons.drop_fill;
      case 'meditation':
        return CupertinoIcons.leaf_arrow_circlepath;
      case 'writing':
        return CupertinoIcons.pencil;
      default:
        return CupertinoIcons.circle_grid_hex_fill;
    }
  }
}

class _AddHabitSheet extends ConsumerStatefulWidget {
  const _AddHabitSheet();

  @override
  ConsumerState<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<_AddHabitSheet> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  String? _selectedIcon;
  String? _selectedColor;
  bool _isLoading = false;

  final _icons = [
    ('reading', CupertinoIcons.book_fill),
    ('fitness', CupertinoIcons.heart_fill),
    ('water', CupertinoIcons.drop_fill),
    ('meditation', CupertinoIcons.leaf_arrow_circlepath),
    ('writing', CupertinoIcons.pencil),
    ('other', CupertinoIcons.circle_grid_hex_fill),
  ];

  final _colors = [
    '#00D4FF', '#7B4FFF', '#FF4FA0', '#00E5A0', '#FFB800', '#FF4F6B',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        padding: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: AppTheme.navyCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: const Border(top: BorderSide(color: AppTheme.glassBorder)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('New Habit',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(CupertinoIcons.clear_circled, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CupertinoTextField(
                  controller: _nameCtrl,
                  autofocus: true,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  placeholder: 'Habit name',
                  placeholderStyle: TextStyle(color: AppTheme.textMuted),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.glassBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.glassBorder),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _targetCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        placeholder: 'Target (e.g. 10)',
                        placeholderStyle: TextStyle(color: AppTheme.textMuted),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.glassBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.glassBorder),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CupertinoTextField(
                        controller: _unitCtrl,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        placeholder: 'Unit (pages, km...)',
                        placeholderStyle: TextStyle(color: AppTheme.textMuted),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.glassBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.glassBorder),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Icon', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: _icons.map((icon) {
                    final isSelected = _selectedIcon == icon.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon.$1),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accentCyan.withOpacity(0.15)
                                : AppTheme.glassBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.accentCyan
                                  : AppTheme.glassBorder,
                            ),
                          ),
                          child: Icon(icon.$2,
                              color: isSelected
                                  ? AppTheme.accentCyan
                                  : AppTheme.textMuted,
                              size: 20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Color', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: _colors.map((hex) {
                    final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                    final isSelected = _selectedColor == hex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedColor = hex),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2.5)
                                : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: AppTheme.accentCyan,
                    borderRadius: BorderRadius.circular(14),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CupertinoActivityIndicator(color: AppTheme.navy)
                        : const Text('Create Habit',
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.navy)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _targetCtrl.text.isEmpty) return;
    final target = double.tryParse(_targetCtrl.text) ?? 1.0;
    setState(() => _isLoading = true);
    await ref.read(habitProvider.notifier).addHabit(
          name: _nameCtrl.text.trim(),
          targetValue: target,
          unit: _unitCtrl.text.trim().isEmpty ? 'units' : _unitCtrl.text.trim(),
          iconName: _selectedIcon,
          colorHex: _selectedColor,
        );
    if (mounted) Navigator.pop(context);
  }
}
