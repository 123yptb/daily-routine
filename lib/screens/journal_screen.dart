import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.background,
        border: null,
        leading: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.chevron_left, color: AppTheme.textPrimary, size: 20),
          ),
        ),
        middle: const Text(
          'My Journal',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.ellipsis, color: AppTheme.textPrimary, size: 20),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Text(
                '420',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Celebrate what made you smile today.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              _buildEmotionsCard(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: CupertinoButton(
                  color: AppTheme.accentYellow,
                  borderRadius: BorderRadius.circular(28),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: const Text(
                    'Create a New Journal',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emotions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Here are four core emotions for your journal',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF0F0F0), height: 1),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildEmotionBar('Happy', 0.85, '48%', AppTheme.accentYellow),
              _buildEmotionBar('Sad', 0.45, '33%', AppTheme.accentBrown),
              _buildEmotionBar('Calm', 0.35, '27%', AppTheme.accentGreen),
              _buildEmotionBar('Anxious', 0.55, '40%', AppTheme.accentOlive),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionBar(String label, double fillPercent, String percentLabel, Color color) {
    const double maxHeight = 160;
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 56,
              height: maxHeight,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F1EF),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            Container(
              width: 56,
              height: maxHeight * fillPercent,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                percentLabel,
                style: TextStyle(
                  color: color == AppTheme.accentYellow ? AppTheme.textPrimary : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
