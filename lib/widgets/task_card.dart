import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import 'glass_widgets.dart';
import 'star_rating_dialog.dart';

class TaskCard extends ConsumerStatefulWidget {
  final TaskModel task;
  final VoidCallback? onSuccess;
  final bool isSubTask;
  final int depth;

  const TaskCard({
    super.key,
    required this.task,
    this.onSuccess,
    this.isSubTask = false,
    this.depth = 0,
  });

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _expandController;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.task.status) {
      case TaskStatus.success:
        return AppTheme.accentGreen;
      case TaskStatus.failed:
        return AppTheme.accentRed;
      case TaskStatus.rescheduled:
        return AppTheme.accentAmber;
      case TaskStatus.pending:
        return AppTheme.accentCyan;
    }
  }

  IconData get _statusIcon {
    switch (widget.task.status) {
      case TaskStatus.success:
        return Icons.check_circle_rounded;
      case TaskStatus.failed:
        return Icons.cancel_rounded;
      case TaskStatus.rescheduled:
        return Icons.schedule_rounded;
      case TaskStatus.pending:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final subTasks = ref.watch(taskProvider.notifier).getSubTasks(task.id);
    final catColor = AppTheme.categoryColor(task.category);
    final isPending = task.status == TaskStatus.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          margin: EdgeInsets.only(
            left: widget.depth * 16.0,
            bottom: 10,
          ),
          padding: const EdgeInsets.all(0),
          borderColor: isPending
              ? catColor.withOpacity(0.3)
              : _statusColor.withOpacity(0.4),
          backgroundColor: isPending
              ? AppTheme.glassBackground
              : _statusColor.withOpacity(0.06),
          child: Column(
            children: [
              _buildHeader(task, catColor, isPending),
              if (_expanded) ...[
                const Divider(
                    height: 1, color: AppTheme.glassBorder, indent: 16, endIndent: 16),
                _buildExpandedContent(task, isPending),
              ],
              if (isPending) _buildActionRow(task),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

        // Sub tasks
        if (subTasks.isNotEmpty && _expanded)
          ...subTasks.map((st) => TaskCard(
                key: ValueKey(st.id),
                task: st,
                isSubTask: true,
                depth: widget.depth + 1,
                onSuccess: widget.onSuccess,
              )),
      ],
    );
  }

  Widget _buildHeader(TaskModel task, Color catColor, bool isPending) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          // Category Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: catColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              AppTheme.categoryIcon(task.category),
              color: catColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title & meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    decoration: task.status == TaskStatus.success
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: AppTheme.textSecondary,
                  ),
                ),
                if (task.description != null && task.description!.isNotEmpty)
                  Text(
                    task.description!,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (task.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          task.category!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: catColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    if (task.category != null) const SizedBox(width: 6),
                    if (task.isHabitTask && task.goalValue != null)
                      Text(
                        'Goal: ${task.goalValue!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Status icon
          GestureDetector(
            onTap: () => setState(() {
              _expanded = !_expanded;
              _expanded
                  ? _expandController.forward()
                  : _expandController.reverse();
            }),
            child: Row(
              children: [
                if (task.satisfactionRating != null)
                  Row(
                    children: List.generate(
                      task.satisfactionRating!.round(),
                      (_) => const Icon(Icons.star_rounded,
                          color: AppTheme.accentAmber, size: 10),
                    ),
                  ),
                const SizedBox(width: 6),
                Icon(_statusIcon, color: _statusColor, size: 22),
                const SizedBox(width: 4),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5)
                      .animate(_expandController),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(TaskModel task, bool isPending) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.description != null && task.description!.isNotEmpty)
            Text(task.description!, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                DateFormat('hh:mm a, MMM d').format(task.createdAt),
                style:
                    const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          if (task.isHabitTask && task.actualValue != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AnimatedProgressBar(
                    value: (task.actualValue! / (task.goalValue ?? 1)).clamp(0, 1),
                    height: 6,
                    gradient: task.hasDeficit
                        ? AppTheme.failGradient
                        : AppTheme.successGradient,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${task.actualValue!.toStringAsFixed(0)} / ${task.goalValue?.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            if (task.hasDeficit)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '⚠️ Deficit: ${task.deficitValue.toStringAsFixed(0)} — catch up tomorrow!',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.accentAmber),
                ),
              ),
          ],
          if (task.note != null && task.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '📝 ${task.note}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildActionRow(TaskModel task) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.glassBorder, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Success
          Expanded(
            child: _ActionButton(
              label: 'Done',
              icon: Icons.check_rounded,
              gradient: AppTheme.successGradient,
              onTap: () => _showRatingDialog(task),
            ),
          ),
          const SizedBox(width: 6),
          // Fail
          Expanded(
            child: _ActionButton(
              label: 'Fail',
              icon: Icons.close_rounded,
              gradient: AppTheme.failGradient,
              onTap: () => ref.read(taskProvider.notifier).failTask(task.id),
            ),
          ),
          const SizedBox(width: 6),
          // Reschedule
          Expanded(
            child: _ActionButton(
              label: 'Later',
              icon: Icons.schedule_rounded,
              color: AppTheme.accentAmber,
              onTap: () => _showReschedulePicker(task),
            ),
          ),
          const SizedBox(width: 6),
          // Add sub task
          _IconActionButton(
            icon: Icons.add_rounded,
            color: AppTheme.accentPurple,
            onTap: () => _showAddSubTaskDialog(task),
          ),
          const SizedBox(width: 4),
          // Delete
          _IconActionButton(
            icon: Icons.delete_outline_rounded,
            color: AppTheme.accentRed,
            onTap: () => ref.read(taskProvider.notifier).deleteTask(task.id),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(TaskModel task) {
    showDialog(
      context: context,
      builder: (_) => StarRatingDialog(
        task: task,
        onConfirm: (rating, actualValue, note) {
          ref.read(taskProvider.notifier).completeTask(
                task.id,
                rating: rating,
                actualValue: actualValue,
                note: note,
              );
          widget.onSuccess?.call();
        },
      ),
    );
  }

  void _showReschedulePicker(TaskModel task) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accentCyan,
            surface: AppTheme.navyCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      ref.read(taskProvider.notifier).rescheduleTask(task.id, picked);
    }
  }

  void _showAddSubTaskDialog(TaskModel parent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSubTaskSheet(parentId: parent.id),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient? gradient;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.gradient,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: gradient,
          color: color?.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: gradient == null
              ? Border.all(color: color!.withOpacity(0.4))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14,
                color: gradient != null ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: gradient != null ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconActionButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

class _AddSubTaskSheet extends ConsumerStatefulWidget {
  final String parentId;
  const _AddSubTaskSheet({required this.parentId});

  @override
  ConsumerState<_AddSubTaskSheet> createState() => _AddSubTaskSheetState();
}

class _AddSubTaskSheetState extends ConsumerState<_AddSubTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GlassCard(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Sub-Task',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'Sub-task title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'Description (optional)'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: AppTheme.navy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (_titleCtrl.text.trim().isEmpty) return;
                  ref.read(taskProvider.notifier).addTask(
                        title: _titleCtrl.text.trim(),
                        description: _descCtrl.text.trim().isEmpty
                            ? null
                            : _descCtrl.text.trim(),
                        parentTaskId: widget.parentId,
                      );
                  Navigator.pop(context);
                },
                child: const Text('Add Sub-Task',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
