import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import 'glass_widgets.dart';

class StarRatingDialog extends StatefulWidget {
  final TaskModel task;
  final void Function(double rating, double? actualValue, String? note) onConfirm;

  const StarRatingDialog({
    super.key,
    required this.task,
    required this.onConfirm,
  });

  @override
  State<StarRatingDialog> createState() => _StarRatingDialogState();
}

class _StarRatingDialogState extends State<StarRatingDialog> {
  double _rating = 3.0;
  final _actualCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task.goalValue != null) {
      _actualCtrl.text = widget.task.goalValue!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _actualCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String get _ratingLabel {
    if (_rating >= 5) return '🏆 Perfect!';
    if (_rating >= 4) return '🌟 Great Job!';
    if (_rating >= 3) return '👍 Good Work';
    if (_rating >= 2) return '😐 Could Be Better';
    return '💪 Keep Going';
  }

  Color get _ratingColor {
    if (_rating >= 4) return AppTheme.accentGreen;
    if (_rating >= 3) return AppTheme.accentCyan;
    if (_rating >= 2) return AppTheme.accentAmber;
    return AppTheme.accentRed;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _ratingColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emoji_events_rounded,
                  color: _ratingColor, size: 32),
            )
                .animate(key: ValueKey(_rating))
                .scale(duration: 300.ms, curve: Curves.elasticOut),

            const SizedBox(height: 16),
            Text(
              'Task Completed! 🎉',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              widget.task.title,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),

            const SizedBox(height: 20),

            // Star Rating
            Text('Rate your satisfaction',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 6),
              itemSize: 40,
              itemBuilder: (_, __) => const Icon(
                Icons.star_rounded,
                color: AppTheme.accentAmber,
              ),
              onRatingUpdate: (r) => setState(() => _rating = r),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _ratingLabel,
                key: ValueKey(_ratingLabel),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _ratingColor),
              ),
            ),

            // Actual value input (for habit tasks)
            if (widget.task.isHabitTask && widget.task.goalValue != null) ...[
              const SizedBox(height: 16),
              const Divider(color: AppTheme.glassBorder),
              const SizedBox(height: 12),
              Text(
                'How much did you actually do?',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _actualCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Actual value',
                        suffixText: '', // unit could go here
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/ ${widget.task.goalValue!.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              maxLines: 2,
              decoration:
                  const InputDecoration(hintText: 'Add a note (optional)...'),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: AppTheme.navy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  double? actualVal;
                  if (_actualCtrl.text.isNotEmpty) {
                    actualVal = double.tryParse(_actualCtrl.text);
                  }
                  widget.onConfirm(
                    _rating,
                    actualVal,
                    _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Confirm',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
