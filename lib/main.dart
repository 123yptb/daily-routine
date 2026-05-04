import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task_model.dart';
import 'models/journal_model.dart';
import 'models/habit_model.dart';
import 'screens/main_shell.dart';
import 'screens/profile_setup_screen.dart';
import 'providers/profile_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.navyCard,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await Hive.initFlutter();
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(JournalEntryAdapter());
  Hive.registerAdapter(DailyLogAdapter());
  Hive.registerAdapter(HabitFrequencyAdapter());
  Hive.registerAdapter(HabitModelAdapter());

  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<DailyLog>('daily_logs');
  await Hive.openBox<JournalEntry>('journal_entries');
  await Hive.openBox<HabitModel>('habits');
  await Hive.openBox('user_profile');

  runApp(
    const ProviderScope(
      child: DailyRoutineApp(),
    ),
  );
}

class DailyRoutineApp extends ConsumerWidget {
  const DailyRoutineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Routine tracker BY YBG',
      theme: AppTheme.materialFallback, // Material fallback
      home: CupertinoTheme(
        data: AppTheme.cupertinoTheme,
        child: profile.isSetup ? const MainShell() : const ProfileSetupScreen(),
      ),
    );
  }
}
