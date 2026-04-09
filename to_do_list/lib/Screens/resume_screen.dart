import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tasks_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/summary_line_chart.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  bool _isMonthView = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TasksProvider>();
    final now = DateTime.now();

    final monthRate = provider.getMonthlySuccessRate(now.year, now.month);
    final overallRate = provider.overallSuccessRate;
    final stats = provider.getOverallStats();

    final totalRecurring = provider.recurringTasks.length;
    final completedRecurringToday = provider.recurringTasks.where((task) {
      final today = DateTime(now.year, now.month, now.day);
      return task.occursOn(today) && task.isCompletedOn(today);
    }).length;

    final chartValues = _isMonthView
        ? _last7Days(provider)
        : provider.getCurrentYearMonthlyPerformance();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            _ResumeHeader(
              isMonthView: _isMonthView,
              onToggle: (value) {
                setState(() => _isMonthView = value);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  children: [
                    _MainStatsCard(
                      successRate: _isMonthView ? monthRate : overallRate,
                      total: stats.total,
                      completed: stats.completed,
                      pending: stats.total - stats.completed,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SmallInfoCard(
                            icon: Icons.bolt,
                            iconBg: const Color(0xFFE8F0FE),
                            title: '${totalRecurring == 0 ? 0 : ((completedRecurringToday / totalRecurring) * 100).round()}%',
                            subtitle: 'Tarefas Recorrentes',
                            footer: '$completedRecurringToday/$totalRecurring mantidas',
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: _SmallInfoCard(
                            icon: Icons.workspace_premium_outlined,
                            iconBg: Color(0xFFFFEADF),
                            title: '6 dias',
                            subtitle: 'Sequência Atual 🔥',
                            footer: 'Máximo: 12 dias',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ChartCard(
                      title: _isMonthView
                          ? 'Atividade dos Últimos 7 Dias'
                          : 'Performance no Ano',
                      child: _isMonthView
                          ? _WeekBars(values: chartValues)
                          : SummaryLineChart(values: chartValues),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _last7Days(TasksProvider provider) {
    final now = DateTime.now();
    final List<double> values = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));

      int total = 0;
      int completed = 0;

      for (final task in provider.tasks) {
        if (task.occursOn(date)) {
          total++;
          if (task.isCompletedOn(date)) completed++;
        }
      }

      values.add(total == 0 ? 0 : completed.toDouble());
    }

    return values;
  }
}

class _ResumeHeader extends StatelessWidget {
  final bool isMonthView;
  final ValueChanged<bool> onToggle;

  const _ResumeHeader({
    required this.isMonthView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      decoration: const BoxDecoration(
        color: Color(0xFF06051B),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white, size: 32),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Performance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Resumo da sua produtividade',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _PeriodButton(
                  label: 'Este Mês',
                  selected: isMonthView,
                  onTap: () => onToggle(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PeriodButton(
                  label: 'Este Ano',
                  selected: !isMonthView,
                  onTap: () => onToggle(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? Colors.white : Colors.white.withOpacity(0.10);
    final fg = selected ? const Color(0xFF06051B) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _MainStatsCard extends StatelessWidget {
  final double successRate;
  final int total;
  final int completed;
  final int pending;

  const _MainStatsCard({
    required this.successRate,
    required this.total,
    required this.completed,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final rate = successRate.clamp(0, 100);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Taxa de Sucesso', style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 10),
                      Text(
                        '${rate.round()}%',
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF06051B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Text(
                            '↑ 67%',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'vs. mês anterior',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: CircularProgressIndicator(
                          value: rate / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade300,
                          color: const Color(0xFF06051B),
                        ),
                      ),
                      const Icon(
                        Icons.gps_fixed,
                        color: Colors.pinkAccent,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _BottomStatItem(value: '$total', label: 'Total')),
                Expanded(child: _BottomStatItem(value: '$completed', label: 'Concluídas')),
                Expanded(child: _BottomStatItem(value: '$pending', label: 'Pendentes')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomStatItem extends StatelessWidget {
  final String value;
  final String label;

  const _BottomStatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

class _SmallInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String footer;

  const _SmallInfoCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF4E5AA7)),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 4),
              Text(footer, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Icon(Icons.track_changes_outlined),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _WeekBars extends StatelessWidget {
  final List<double> values;

  const _WeekBars({
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final maxValue = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b).clamp(1, 9999);

    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(values.length, (index) {
          final value = values[index];
          final height = (value / maxValue) * 120 + 8;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (value > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06051B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              else
                const SizedBox(height: 24),
              Container(
                width: 34,
                height: height,
                decoration: BoxDecoration(
                  color: const Color(0xFF06051B),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(labels[index]),
            ],
          );
        }),
      ),
    );
  }
}