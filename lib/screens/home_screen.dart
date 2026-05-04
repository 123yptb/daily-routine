import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../theme/app_theme.dart';
import 'package:confetti/confetti.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedDay = 10;
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
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDatePicker(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('My Journal'),
                  const SizedBox(height: 16),
                  _buildJournalCards(),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Today's Schedule"),
                  const SizedBox(height: 16),
                  _buildTaskList(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Quick Journal'),
                  const SizedBox(height: 16),
                  _buildQuickJournal(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2,
              maxBlastForce: 25,
              minBlastForce: 15,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
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
      ),
    );
  }

  Widget _buildHeader() {
    final profile = ref.watch(profileProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Hi, ${profile.name.split(' ')[0]}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    color: AppTheme.accentCyan,
                    size: 20,
                  ),
                ],
              ),
              Text(
                'ROUTINE TRACKER BY YBG',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.accentYellow,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentYellow,
              image: DecorationImage(
                image: profile.localImagePath != null
                    ? FileImage(File(profile.localImagePath!)) as ImageProvider
                    : NetworkImage(profile.avatarUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentYellow.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    final days = [
      {'day': 'Mon', 'date': 7},
      {'day': 'Tue', 'date': 8},
      {'day': 'Wed', 'date': 9},
      {'day': 'Thu', 'date': 10},
      {'day': 'Fri', 'date': 11},
      {'day': 'Sat', 'date': 12},
      {'day': 'Sun', 'date': 13},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final isSelected = days[index]['date'] == _selectedDay;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = days[index]['date'] as int;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Text(
                    days[index]['day'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accentYellow : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: AppTheme.accentYellow.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4))
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${days[index]['date']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const Text(
            'See all',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 220,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: _showComingSoon,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.accentYellow,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentYellow.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Let's start your day",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Begin with a mindful morning\nreflections.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textPrimary.withOpacity(0.8),
                          height: 1.3,
                        ),
                      ),
                      const Spacer(),
                      // Simulated Sun Graphic
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9D00).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF8A00),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 12),
                                Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: _showComingSoon,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.pastelSand,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'Evening',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickJournal() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildQuickCard(
            title: 'Pause & reflect 🌱',
            subtitle: 'What are you grateful\nfor today?',
            tag: 'Personal',
            tagColor: const Color(0xFFF0706A),
            bgColor: AppTheme.pastelPeach,
            onTap: _showComingSoon,
          ),
          const SizedBox(width: 12),
          _buildQuickCard(
            title: 'Set Intentions 😶',
            subtitle: 'How do you want to\nfeel?',
            tag: 'Family',
            tagColor: const Color(0xFF8B64FF),
            bgColor: AppTheme.pastelLavender,
            onTap: _showComingSoon,
          ),
          const SizedBox(width: 12),
          _buildQuickCard(
            title: 'Emotions 💭',
            subtitle: 'Let it out\nand let go.',
            tag: 'Mind',
            tagColor: AppTheme.accentGreen,
            bgColor: AppTheme.pastelGreen,
            onTap: _showComingSoon,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard({
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: tagColor,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final tasks = ref.watch(taskProvider);
    final todayTasks = tasks.where((t) => t.parentTaskId == null).toList();

    if (todayTasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.glassBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Column(
            children: const [
              Text('✨', style: TextStyle(fontSize: 24)),
              SizedBox(height: 8),
              Text(
                'No tasks scheduled for today.\nTap + to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: todayTasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          task: todayTasks[index],
          onSuccess: _triggerConfetti,
        );
      },
    );
  }

  void _showComingSoon() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Coming Soon'),
          content: const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('This feature is currently under development.'),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
