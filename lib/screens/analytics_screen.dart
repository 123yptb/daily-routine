import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _segmentedControlGroupValue = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.navy,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xCC111432),
        border: const Border(
          bottom: BorderSide(color: AppTheme.glassBorder, width: 0.5),
        ),
        middle: const Text(
          'Analytics',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _segmentedControlGroupValue,
                  backgroundColor: AppTheme.glassBackground,
                  thumbColor: AppTheme.charcoalLight,
                  children: {
                    0: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Weekly',
                        style: TextStyle(
                          color: _segmentedControlGroupValue == 0
                              ? AppTheme.accentCyan
                              : AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    1: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Monthly',
                        style: TextStyle(
                          color: _segmentedControlGroupValue == 1
                              ? AppTheme.accentCyan
                              : AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  },
                  onValueChanged: (value) {
                    setState(() {
                      if (value != null) {
                        _segmentedControlGroupValue = value;
                      }
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: _segmentedControlGroupValue == 0
                  ? _buildWeeklyView()
                  : _buildMonthlyView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final logs = ref.watch(allLogsProvider);
    final weekLogs = logs.length >= 7 ? logs.sublist(logs.length - 7) : logs;
    final avgScore = weekLogs.isEmpty
        ? 0.0
        : weekLogs.map((l) => l.computedScore).reduce((a, b) => a + b) /
            weekLogs.length;

    double? prevWeekAvg;
    if (logs.length >= 14) {
      final prevLogs = logs.sublist(logs.length - 14, logs.length - 7);
      prevWeekAvg = prevLogs.map((l) => l.computedScore).reduce((a, b) => a + b) /
          prevLogs.length;
    }

    final growth = prevWeekAvg != null && prevWeekAvg > 0
        ? ((avgScore - prevWeekAvg) / prevWeekAvg * 100)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your performance insights',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('7-Day Avg',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        '${avgScore.toStringAsFixed(1)}',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accentCyan),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  borderColor: growth >= 0
                      ? AppTheme.accentGreen.withOpacity(0.4)
                      : AppTheme.accentRed.withOpacity(0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Growth',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            growth >= 0
                                ? CupertinoIcons.arrow_up_right
                                : CupertinoIcons.arrow_down_right,
                            color: growth >= 0
                                ? AppTheme.accentGreen
                                : AppTheme.accentRed,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${growth.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: growth >= 0
                                  ? AppTheme.accentGreen
                                  : AppTheme.accentRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyView() {
    final logs = ref.watch(allLogsProvider);
    final weekLogs = logs.length >= 7 ? logs.sublist(logs.length - 7) : logs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Performance Line Chart
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Performance Score',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        fontSize: 15)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: weekLogs.isEmpty
                      ? _buildNoDataPlaceholder()
                      : LineChart(_buildWeeklyLineChart(weekLogs)),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 14),

          // Task Completion Bar Chart
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tasks Completed vs Failed',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        fontSize: 15)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 160,
                  child: weekLogs.isEmpty
                      ? _buildNoDataPlaceholder()
                      : BarChart(_buildCompletionBarChart(weekLogs)),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 14),

          // Weekly Summary cards
          _buildWeeklySummary(weekLogs).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    final logs = ref.watch(allLogsProvider);
    final monthLogs =
        logs.length >= 30 ? logs.sublist(logs.length - 30) : logs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('30-Day Score Trend',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        fontSize: 15)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: monthLogs.isEmpty
                      ? _buildNoDataPlaceholder()
                      : LineChart(_buildMonthlyLineChart(monthLogs)),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 14),

          // Best/Worst days
          _buildBestWorstRow(monthLogs).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  LineChartData _buildWeeklyLineChart(List logs) {
    final spots = logs.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.computedScore);
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: AppTheme.glassBorder, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              final idx = value.toInt();
              if (idx < 0 || idx >= logs.length) return const SizedBox();
              final date = logs[idx].date;
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  DateFormat('E').format(date),
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textMuted),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (value, _) => Text(
              value.toInt().toString(),
              style:
                  const TextStyle(fontSize: 10, color: AppTheme.textMuted),
            ),
          ),
        ),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (logs.length - 1).toDouble(),
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: const LinearGradient(
              colors: [AppTheme.accentCyan, AppTheme.accentPurple]),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 4,
              color: AppTheme.accentCyan,
              strokeWidth: 2,
              strokeColor: AppTheme.navy,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.accentCyan.withOpacity(0.2),
                AppTheme.accentPurple.withOpacity(0.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  BarChartData _buildCompletionBarChart(List logs) {
    return BarChartData(
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              final idx = value.toInt();
              if (idx < 0 || idx >= logs.length) return const SizedBox();
              return Text(
                DateFormat('E').format(logs[idx].date),
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textMuted),
              );
            },
          ),
        ),
        leftTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: logs.asMap().entries.map((e) {
        final log = e.value;
        return BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: log.completedTasks.toDouble(),
              gradient: const LinearGradient(
                  colors: [AppTheme.accentGreen, AppTheme.accentCyan],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter),
              width: 12,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            BarChartRodData(
              toY: log.failedTasks.toDouble(),
              gradient: const LinearGradient(
                  colors: [AppTheme.accentRed, AppTheme.accentPink],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter),
              width: 12,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      }).toList(),
    );
  }

  LineChartData _buildMonthlyLineChart(List logs) {
    final spots = logs.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.computedScore);
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: AppTheme.glassBorder, strokeWidth: 0.5),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            getTitlesWidget: (value, _) {
              final idx = value.toInt();
              if (idx < 0 || idx >= logs.length) return const SizedBox();
              return Text(
                DateFormat('d').format(logs[idx].date),
                style: const TextStyle(
                    fontSize: 9, color: AppTheme.textMuted),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, _) => Text(
              value.toInt().toString(),
              style:
                  const TextStyle(fontSize: 9, color: AppTheme.textMuted),
            ),
          ),
        ),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (logs.length - 1).toDouble(),
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: const LinearGradient(
              colors: [AppTheme.accentPurple, AppTheme.accentCyan]),
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.accentPurple.withOpacity(0.15),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySummary(List logs) {
    final totalCompleted = logs.fold(0, (s, l) => s + (l.completedTasks as int));
    final totalFailed = logs.fold(0, (s, l) => s + (l.failedTasks as int));
    final successRate = (totalCompleted + totalFailed) > 0
        ? (totalCompleted / (totalCompleted + totalFailed) * 100)
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: _SummaryTile(
              icon: CupertinoIcons.checkmark_circle_fill,
              color: AppTheme.accentGreen,
              label: 'Completed',
              value: '$totalCompleted',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: _SummaryTile(
              icon: CupertinoIcons.xmark_circle_fill,
              color: AppTheme.accentRed,
              label: 'Failed',
              value: '$totalFailed',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: _SummaryTile(
              icon: CupertinoIcons.percent,
              color: AppTheme.accentCyan,
              label: 'Success Rate',
              value: '${successRate.toStringAsFixed(0)}%',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBestWorstRow(List logs) {
    if (logs.isEmpty) return const SizedBox();
    final sorted = [...logs]..sort((a, b) =>
        a.computedScore.compareTo(b.computedScore));
    final worst = sorted.first;
    final best = sorted.last;

    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            borderColor: AppTheme.accentGreen.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🏆 Best Day',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d').format(best.date),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentGreen),
                ),
                Text(
                  '${best.computedScore.toStringAsFixed(0)} pts',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            borderColor: AppTheme.accentRed.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('😓 Worst Day',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d').format(worst.date),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentRed),
                ),
                Text(
                  '${worst.computedScore.toStringAsFixed(0)} pts',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('📊', style: TextStyle(fontSize: 32)),
          SizedBox(height: 8),
          Text(
            'Complete tasks to\nsee analytics',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _SummaryTile(
      {required this.icon,
      required this.color,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}
