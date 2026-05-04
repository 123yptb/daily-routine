import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  String? _selectedCategory;
  bool _isHabitTask = false;
  DateTime _scheduledDate = DateTime.now();
  bool _isLoading = false;

  List<String> _categories = ['calls', 'sales', 'fitness', 'reading', 'work', 'personal'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.background.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0x1A000000), width: 0.5),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.back, color: AppTheme.textPrimary),
              Text('Back', style: TextStyle(color: AppTheme.textPrimary)),
            ],
          ),
        ),
        middle: Text(
          'New Task',
          style: GoogleFonts.nunito(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      child: SafeArea(
        child: Material(
          type: MaterialType.transparency, // Fixes yellow underlines
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const _SectionLabel('Task Title'),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _titleCtrl,
                  autofocus: true,
                  style: GoogleFonts.nunito(color: AppTheme.textPrimary, fontSize: 16),
                  placeholder: 'What do you need to do?',
                  placeholderStyle: GoogleFonts.nunito(color: AppTheme.textMuted),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Description
                const _SectionLabel('Description'),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _descCtrl,
                  style: GoogleFonts.nunito(color: AppTheme.textPrimary),
                  maxLines: 3,
                  placeholder: 'Add details...',
                  placeholderStyle: GoogleFonts.nunito(color: AppTheme.textMuted),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Category
                const _SectionLabel('Category'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ..._categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accentYellow : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.accentYellow : const Color(0xFFE0E0E0),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.accentYellow.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            cat.toUpperCase(),
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: _showAddCategoryDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.textMuted, style: BorderStyle.solid),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.add, size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'NEW',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Schedule
                const _SectionLabel('Schedule For'),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentYellow.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(CupertinoIcons.calendar,
                              color: AppTheme.accentYellow, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _formatDate(_scheduledDate),
                          style: GoogleFonts.nunito(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        const Icon(CupertinoIcons.chevron_right,
                            color: AppTheme.textMuted, size: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Habit Task Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBrown.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(CupertinoIcons.arrow_2_squarepath,
                            color: AppTheme.accentBrown, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Habit / Goal Task',
                              style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Track with quantity & buffering',
                              style: GoogleFonts.nunito(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoSwitch(
                        value: _isHabitTask,
                        onChanged: (v) => setState(() => _isHabitTask = v),
                        activeColor: AppTheme.accentYellow,
                      ),
                    ],
                  ),
                ),

                // Goal value (only for habit tasks)
                if (_isHabitTask) ...[
                  const SizedBox(height: 24),
                  const _SectionLabel('Goal Value (e.g. 10 pages, 30 minutes)'),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _goalCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.nunito(color: AppTheme.textPrimary),
                    placeholder: 'Enter goal quantity',
                    placeholderStyle: GoogleFonts.nunito(color: AppTheme.textMuted),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentYellow.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : Text(
                              'Create Task',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickDate() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('Done', style: TextStyle(color: AppTheme.accentYellow, fontWeight: FontWeight.w700)),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: CupertinoDatePicker(
                  initialDateTime: _scheduledDate,
                  minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                  maximumDate: DateTime.now().add(const Duration(days: 365)),
                  mode: CupertinoDatePickerMode.dateAndTime,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() => _scheduledDate = newDate);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Missing Title'),
          content: const Text('Please enter a task title.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK', style: TextStyle(color: AppTheme.accentYellow)),
              onPressed: () => Navigator.pop(ctx),
            )
          ],
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    double? goalValue;
    if (_isHabitTask && _goalCtrl.text.isNotEmpty) {
      goalValue = double.tryParse(_goalCtrl.text);
    }

    await ref.read(taskProvider.notifier).addTask(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          category: _selectedCategory,
          scheduledAt: _scheduledDate,
          goalValue: goalValue,
          isHabitTask: _isHabitTask,
        );

    // Schedule the reminder notification
    // We use a simple hash of the title to generate a unique int ID for the notification
    final notificationId = _titleCtrl.text.hashCode;
    await NotificationService().scheduleTaskReminder(
      id: notificationId,
      title: 'Time for your task! 🎯',
      body: _titleCtrl.text.trim(),
      scheduledDate: _scheduledDate,
    );

    if (mounted) Navigator.pop(context);
  }

  void _showAddCategoryDialog() {
    final TextEditingController newCatCtrl = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('New Category'),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: CupertinoTextField(
              controller: newCatCtrl,
              autofocus: true,
              placeholder: 'Category name',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add', style: TextStyle(color: AppTheme.accentYellow)),
              onPressed: () {
                final text = newCatCtrl.text.trim().toLowerCase();
                if (text.isNotEmpty && !_categories.contains(text)) {
                  setState(() {
                    _categories.add(text);
                    _selectedCategory = text;
                  });
                } else if (text.isNotEmpty) {
                  setState(() => _selectedCategory = text);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final timeString = DateFormat('h:mm a').format(date);
    
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today at $timeString';
    }
    
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow at $timeString';
    }
    
    return '${DateFormat('MMM d, yyyy').format(date)} at $timeString';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppTheme.textSecondary,
      ),
    );
  }
}
