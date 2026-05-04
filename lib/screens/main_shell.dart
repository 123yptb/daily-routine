import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'habits_screen.dart';
import 'analytics_screen.dart';
import 'journal_screen.dart';
import 'add_task_screen.dart'; // Ensure you have this
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HabitsScreen(), // Acting as 'Explore'
    const SizedBox(),     // Placeholder for FAB
    const JournalScreen(), // Acting as 'Journey'
    const ProfileScreen(), // Acting as 'Profile'
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: AppTheme.cardBg.withOpacity(0.95),
            activeColor: AppTheme.textPrimary,
            inactiveColor: AppTheme.textMuted,
            iconSize: 26,
            height: 65,
            border: const Border(
              top: BorderSide(color: Color(0x0A000000), width: 1),
            ),
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index != 2) {
                setState(() => _currentIndex = index);
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Icon(CupertinoIcons.house_fill),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Icon(CupertinoIcons.compass),
                ),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(), // Empty space for FAB
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Icon(CupertinoIcons.doc_text),
                ),
                label: 'Journey',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Icon(CupertinoIcons.person),
                ),
                label: 'Profile',
              ),
            ],
          ),
          tabBuilder: (context, index) {
            return CupertinoTabView(
              builder: (_) => _screens[index],
            );
          },
        ),
        // Overlapping Central FAB
        Positioned(
          bottom: 25,
          left: MediaQuery.of(context).size.width / 2 - 28,
          child: GestureDetector(
            onTap: () {
              // Action for FAB (e.g., add new item)
              showCupertinoModalPopup(
                context: context,
                builder: (_) => const AddTaskScreen(),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accentYellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentYellow.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.add,
                color: AppTheme.textPrimary,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
